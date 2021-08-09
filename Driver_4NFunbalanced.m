% uses files Driver_4NFunbalanced and loaddata_4NF_sigBuilder
% 1. add new entry to the file 'computePU()'; Sbase=5 (MW), Vbase=2.4 (kV)
% 2. specify set constant target
% 3. run without dbc
% 4. put d_timeseries into simulink like your netload data 'from workspace' variable
% 5. once running, update change feeder doc: https://docs.google.com/document/d/1sW9_txbTIt1qRnV-qul3Sq5a_F1xBMD70WIAcUUA-SI/edit
%------------------------------
% Jaimie Swartz, PBC PI local controller code, 7/19/21
%clc; clearvars -except myVars sensCell powCell e; close all;
clc; clear all; 
%close all;

disp('Running Local Controller...');
tic % begin counting sim elapsed time
%% initialize(loaddata.init)
% check: impedance model pins are exactly 3 rows, and load list is same as
% TV load/gen data

Ts=1; % should agree with simulink outermost block setting
% 0.1 is more realistic, but hard to see conceptually on plots
% 1 easier to see, but controller should be faster than this irl
numNodes=3; % number without the slack

% read initialization file
    % CHECK THIS
    testIdx=2; % (sim1_1 = 2; sim_9 = 3), for each scenario run, first test below the headers is idx=1
    numHead=4; % number of header rows in init file, constant
    [num txt raw]=xlsread('init_4NF.xlsx');
    % see row 4 of initilaization file to verify hardcoded index number 
    testKey=raw(testIdx+numHead,1); testKey=testKey{1}
    disp(strcat('---------- Initializing controller test',testKey,'----------'));
    kgainCalcType=raw(testIdx+numHead,2); kgainCalcType=kgainCalcType{1}
    PVpen=raw(testIdx+numHead,3); PVpen=PVpen{1};
    time=raw(testIdx+numHead,4); time=time{1}; time=strsplit(time,'-');
    timeStart=time(1); timeEnd=time(2); % HH:MM format, for full day  use 23:59
    [minStart,minEnd,simTimestamps] = setSimTime(timeStart,timeEnd);
    resultsName=raw(testIdx+numHead,5); resultsName=resultsName{1};
    % 'raw LPBC output name' col not used by this code, instead used by results tracking tool
    measStr=raw(testIdx+numHead,6); measStr=measStr{1}; % convert cell array to string
    actStr=raw(testIdx+numHead,7); actStr=actStr{1};
    dbcStr=raw(testIdx+numHead,9); dbcStr=dbcStr{1};
    Sinv_str=raw(testIdx+numHead,10); Sinv_str=Sinv_str{1}; % inv limit, apparent pow
    ridxStr=raw(testIdx+numHead,8); ridxStr=ridxStr{1}; 
    if isa(ridxStr,'double') % if already a double, no need to convert string to double
       ridx=ridxStr;
    else
       ridx=str2double(strsplit(ridxStr,',')); ridx = ridx(~isnan(ridx)); % split string of nodes by comma delimiter, yielding cell array
    end 
   % vars read in from initialization that are not used yet: PVpen
% may need later: strcmp(kgainCalcType,'ZN')

%% read TV load/gen data
    % this code expects second-wise data
    % use xlsread to obtain loadNames from header, then csvread to read data (too much data for xlsread to handle)
    secStart=minStart*60+1; secEnd=minEnd*60; % use exact index as in first col of the .csv
    n=19; % for each feeder, the number of cols in TV load/gen data (including time col), which is number of nodes*phases
    % parms for changing feeders: https://docs.google.com/document/d/1sW9_txbTIt1qRnV-qul3Sq5a_F1xBMD70WIAcUUA-SI/edit
    r1=secStart; r2=secEnd; c1=0; c2=n-1; % col and row offset
    
% need diff TV load/gen data file if SPBC phasor targets vs. if just
% tracking constant phasor (when tracking SPBC phasor targets the load
% data needs to be scaled down)
    % netLoadData = csvread('sig0.3_001_phasor08_IEEE13_secondWise_sigBuilder_5min_normalized_03.csv',r1,c1,[r1 c1 r2 c2]); % includes first col as timestamp, needed for simulink loop
    %netLoadData = csvread('001_phasor08_IEEE13_time_sigBuilder_secondwise_norm03.csv',r1,c1,[r1 c1 r2 c2]); % includes first col as timestamp, needed for simulink loop
    loadData = csvread('loaddata_4NF_sigBuilder_insideIC.csv',r1,c1,[r1 c1 r2 c2]); % includes first col as timestamp, needed for simulink loop
   m=1;% modifier to scale the net load. With m=1, vmag very low (0.92pu)
    netLoadData=m*loadData; % units of kW, kVAR
    % loadData formatted [PPP ... QQQ] LD_634/P1	LD_634/Q1	LD_634/P2	LD_634/Q2	LD_634/P3	LD_634/Q3	LD_671/P1
 
    % To keep tv load
        netLoadData_snippet=netLoadData;
        loadData_noTS=netLoadData(:,2:end); % remove timestamp

    % To make CONST load data:
    %     tvdata=netLoadData(:,2:end);
    %     netLoadData_snippet=[netLoadData(:,1) repmat(tvdata(1,:),size(tvdata,1),1)];
    %     loadData_noTS=netLoadData_snippet(:,2:end); % remove timestamp

    figure; plot(netLoadData_snippet(:,1),netLoadData_snippet(:,2:end)); title('load data for sim itvl, one curve for each node'); xlabel('seconds'); ylabel('kW or kVAR');


    %r1 = 0; r2 = 1; c1 = 1; c2 = 35;
    [txt,num,raw] = xlsread('my4bus_Yconn_unbal.xls','Pins','B1:T1'); % pick out load names
%     raw = csvread('impedMod_IEEE13_csv.csv',r1, c1, [r1 c1 r2 c2]);
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    loadNames =raw(1,2:end); % 
    loadNames = cellfun(@(S) S(4:end), loadNames, 'Uniform', 0); % clean up string format

    [txt,num,raw] = xlsread('my4bus_Yconn_unbal.xls','Pins','B2:K3'); % pick out bus names
    busNames=raw(1,2:end); % used to select meas node
    busNames=cellfun(@(S) S(1:end-5), busNames, 'Uniform', 0); % clean up string format
    % Assign node location indices, print to help with debugging  
       
    meas_idx=strToIdx(measStr,busNames)
    ctrl_idx=strToIdx(actStr,loadNames)
    dbc_idx=strToIdx(dbcStr,loadNames)
    Sinv=repmat(Sinv_str,1,length(ctrl_idx)/2) % TEMP, when multiple actuators need to use length of inv ctrl_idx, not whole ctrl_idx
    r=length(ctrl_idx)/2 % number of "phase-actuators", div by 2 because each phase actuator has P and Q control so control index has length 2*r
    
%     [netLoadData, PV_percent] = PV_Cloud_Disturbance(netLoadData, 200, 210);
%     figure; plot(netLoadData(:,1),netLoadData(:,2:end)); title('load data, after PV disturbance');

% Print which measurments alin with which actuators, each row is a meas-act
% loop
    controlLoopAlign=[loadNames(ctrl_idx)' repmat(busNames(meas_idx)',2,1)]
%% Set targets/reference for controller to  track
    [Sbase,V1base,V2base] = computePU(); 
% Vbase must match the base of the performance nodes
    %Vbase=[repmat(V1base,6,1); repmat(V2base,3,1); repmat(V1base,3,1);]; % for vvc compare
   % Vbase=[repmat(V1base,6,1); repmat(V2base,3,1); repmat(V1base,3,1)]; % for vvc compare
    %Vbase=[V1base V1base V1base];
    Vbase=[repmat(V1base,6,1);]; % multAct sim

    
    %[vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_SPBC_targets(minStart,minEnd,Sbase,V1base,V2base,measStr); 
    %[vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_UD_targets(minStart,minEnd,Sbase,V1base,V2base) ;
    [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target(minStart,minEnd,Sbase,meas_idx); 
   
%     vmag_ref
%     vang_ref
%% --------------------- Simulation is now initialized -------------------------
    disp( '------------------- Designing controller...');

%% step2: run simulation to collect step response data
   
%     Turn controllers off    
    Kp_vmag=zeros(r,1);
    Ki_vmag=zeros(r,1);
    Kp_vang=zeros(r,1);
    Ki_vang=zeros(r,1);
    
%     Vang_ctrlStart = (20+80*r)*Ts; % wait until after interval over which you tuned controller
%     Vmag_ctrlStart = (20+80*r)*Ts; % in seconds, time for turning on controllers
    Vang_ctrlStart = 60; % wait until after interval over which you tuned controller
    Vmag_ctrlStart = 60; % in seconds, time for turning on controllers

    % CHANGES FOR WHEN r=numPhaseAct>24:
    %only create 24*2 step changes, not r*2 step changes
    % select these 24 out of r randomly
    % thus dvdq and sensMats are size 24 not r
    % kgains are size r not 24
    % write new func: afunc_manyact
    % in GA instead of indexing each dvdq(i), compute max dvdq, min dvdq
    % and use those for all UB and LBs
    
%%
    % Create test disturbance to collect step response data
    n=length(dbc_idx); Pidx=1:2:n-1; Qidx=2:2:n;
    actualDbcData=createActualDbc(0*loadData_noTS(:,dbc_idx(Pidx)),0*loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv,netLoadData_snippet,r);    
    n=length(ctrl_idx); Pidx=1:2:n-1; Qidx=2:2:n;
    %actualDbcData = actualDbcData*0;
    [testDbcData, dbcMeas, stepP, stepQ, dbcDur]=createTestDbc(loadData_noTS(:,ctrl_idx(Pidx)),loadData_noTS(:,ctrl_idx(Qidx)),Ts,ctrl_idx,Sbase); % testDbcData is a load value
    %testDbcData(:,2:7)=0;
    
    timevec=1:size(loadData_noTS,1);
    vdbc=[timevec; zeros(numNodes*3,length(timevec))]';

   %% Run sim with controllers off to get sys ID data
         disp('------------------- Running uncontrolled sim...');

    % Run simulink
    % CHECK THIS
        tau=5;

        sim('sim_4NF.mdl')
        set_param('sim_4NF','AlgebraicLoopSolver','LineSearch'); % so that derivative term in discrete PID controller doesn't have error
        vmag_init_actual=vmag_new(40,:);
        vang_init_actual=vang_new(40,:);
        disp('finished simulink');    
        
    % Compute sensitivities
       [dvdq dvdp ddeldq ddeldp sensMats]=computeSens(dbcMeas, stepP, stepQ, dbcDur, vmag_new,vang_new, ctrl_idx,loadNames,Sbase)
        % units: [V/kVAR V/kW deg/kVar deg/kW]
if (any(diff(sign(dvdq(dvdq~=0)))) || any(diff(sign(ddeldp(ddeldp~=0))))) % if not all the same sign
    error('dvdq or ddeldp not all same sign across all phases. Check whether testDbc step size is exciting enouh (see plots)');
end

%	 save(resultsName,'sensMats','dvdp','dvdq','ddeldq','ddeldp');

%% Plot step responses for each phase
        % extra plot for way 3
r=length(ctrl_idx)/2;
%close all
% qnew and vmag_new are in pu
itvl=1:230; % number of timesteps to plot
figure;
for i = 1:r
    subplot(1,r,i);
    [haxes hline1 hline2]=plotyy(itvl,vmag_new(itvl,i),itvl,testDbcData(itvl,i*2+1));
    set(hline1,'LineWidth',1.5);
set(hline2,'LineWidth',1.5);
    legend('vmag','q');
end
title('Q-->Vmag');
figure;
for i = 1:r
    subplot(1,r,i);
    [haxes hline1, hline2]=plotyy(itvl,vang_new(itvl,i),itvl,testDbcData(itvl,i*2));
    set(hline1,'LineWidth',1.5);
    set(hline2,'LineWidth',1.5);
    legend('vang','p');
end
title('P-->Vang');
        
% figure; plot(allPQ(1:250,7:9),'LineWidth',1.5);
% figure; plot(allPQ(1:250,34:36),'LineWidth',1.5);

%% --------------------- Now ready to compute kgains -------------------------
% for 4-bus network, already designed kgains in reachability code
f2=0.8; % good to have higher gains further up the feedr
f3=0.5;
changePow_per_vdev=f3*0.1*Sbase*1000 % in kW, see if reasonable
%Ki_vmag=[f2*ones(3,1)];
Ki_vmag=[f2*ones(3,1); f3*ones(3,1)];
Kp_vmag=zeros(r,1);
Ki_vang=zeros(r,1);
Kp_vang=zeros(r,1);


%% --------------------- Controller kgains are now set -------------------------
% CHECK THIS
%load('sim_PBC.mat','kgains'); % gives us "kgains"
% load('twoPerf.mat','kgains'); % gives us "kgains"
% Kp_vmag=kgains(1,:)
% Ki_vmag=kgains(2,:)
% Kp_vang=kgains(3,:)
% Ki_vang=kgains(4,:)

% %detune due to multiple perf nodes
%  Kp_vmag=0.33*Kp_vmag
%  Ki_vmag=0.33*Ki_vmag
%  Ki_vang=0.33*Ki_vang
%  Kp_vang=0.33*Kp_vang

  
%% Create power disturbance for controlled sim %comment out for 2.1 tests 
    % define disturbance directly in this function below 
%     
     n=length(dbc_idx); Pidx=1:2:n-1; Qidx=2:2:n;
     
  % CHECK THIS
     actualDbcData =createActualDbc(0*loadData_noTS(:,dbc_idx(Pidx)),0*loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv, netLoadData,r);
     %actualDbcData =createActualDbc(loadData_noTS(:,dbc_idx(Pidx)),loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv, netLoadData,r);     
     save('dbcData_sunny2','actualDbcData');
 %   load('dbcData_sunny1.mat');
%     load('dbcData_multAct2.mat');
%      save('dbcData_multAct2.mat','actualDbcData');
    % load('dbcData_sim_multAct_way3.mat');

     %actualDbcData(:,2:end)=0.7*actualDbcData(:,2:end);
     
    % n=length(ctrl_idx); Pidx=1:2:n-1; Qidx=2:2:n;
   % [testDbcData, dbcMeas, stepP, stepQ, dbcDur]=createTestDbc(0*loadData_noTS(:,ctrl_idx(Pidx)),0*loadData_noTS(:,ctrl_idx(Qidx)),Ts,ctrl_idx);
    testDbcData(:,2:end)=0;
    %3.1 for PV gen cut in half: 
    %%%[PV_Disturbance]=PV_Cloud_Disturbance(netLoadData);
    %%%%3.1 PV disturbance 
    %%%%figure; plot(PV_Disturbance(:,1),PV_Disturbance(:,2:end)); title('cloud disturbance for PV generation'); %3.1 test figure 
    
    % actualDbcData format = [P...P Q...Q]
   %figure; plot(actualDbcData(:,[2:6,8,11:12,14:15,17:23,25,28:29,31:32,34:35]),'LineWidth',1.5); title('Disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); 
   % figure; plot(testDbcData(1:200/Ts,2:end),'LineWidth',1.5); title('test disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); legend('P','Q');
 %   figure; plot(actualDbcData(:,[2:7]),'LineWidth',1.5); title('Disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); 
%legend('Pa','Pb','Pc','Qa','Qb','Qc');

%% create voltage disturbance timeseries d-timseries
rng(4); % set rng seed so reproducable
%d_timeseries = (dbc_ub-dbc_lb).*rand(numNodes,length(timevec)) + dbc_lb % uniform distribution

% create normal distribution with bounds
duration=secEnd-secStart+1; % TEMP - check this number
nsamp=duration*(numNodes*3); % at all nodes and phases
%nsamp=500;
%randSamp = dbc_lb + (dbc_ub - dbc_lb)*sum(rand(nsamp,p),2)/p; % vector of rand nums

% create 3-mode binomial distribution, peaks at rightevent, leftevent, and
% zero
rightevent=0.0056; leftevent=-0.0125; % bases on pmu data
sigma=rightevent/4; % need sigma small enough to get distinct peaks
for i=1:nsamp
    alpha=rand;
    if alpha<0.33
      randSamp(i)=normrnd(leftevent,sigma,[1,1]); 
    elseif alpha<0.66
      randSamp(i)=normrnd(rightevent,sigma,[1,1]);
    else
      randSamp(i)=normrnd(0,sigma,[1,1]); % gaussian
    end
end
% figure; hist(randSamp,50); title('gaussian distr of dbcs'); ylabel('frequency'); xlabel('dbc value');
clear reshape;
d_timeseries=reshape(randSamp,[numNodes*3,duration]); % reshape into array of random

% figure; 
% subplot(2,1,1);
% plot(d_timeseries); title('dbc over time');
% subplot(2,1,2);
% plot(cumsum(d_timeseries)); title('dbc accumulated');

% convert to three phase and append timvec as first row
vdbc=[timevec; d_timeseries]';
%vdbc=[timevec; zeros(numNodes*3,length(timevec))]';
    
%% Zero out the power disturbance
    r=length(ctrl_idx)/2; % number of "phase-actuators", div by 2 because each phase actuator has P and Q control so control index has length 2*r 
     n=length(dbc_idx); Pidx=1:2:n-1; Qidx=2:2:n;
     actualDbcData=createActualDbc(0*loadData_noTS(:,dbc_idx(Pidx)),0*loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv,netLoadData_snippet,r);    
%%  Run sim with controllers ON

    disp('------------------- Running controlled sim...');
    % Run simulink
    % CHECK THIS
        sim('sim_4NF.mdl')
        set_param('sim_4NF','AlgebraicLoopSolver','LineSearch'); % so that derivative term in discrete PID controller doesn't have error
        vmag_init_actual=vmag_new(40,:);
        vang_init_actual=vang_new(40,:);
        disp('finished simulink');    


%% Save results 
    % Run PlotLocalCtrl in command prompt to see results

    % so that results tracking tool can compute performance metrics
    disp('------------------- Outputing results...');
    % save data into .mats
    kgains=[Kp_vmag; Ki_vmag; Kp_vang; Ki_vang];
	% save('sim4bus_inX0_wdbc.mat','vmag_new','vang_new','pnew','qnew','simTimestamps','vmag_ref_sig','vang_ref_sig','kgains')
     % to check what you've saved away...
     %clear all; load('simData_001.mat'); whos
     
%% ------------------------- End of Code ----------------------------------
toc % print elapsed sim time
