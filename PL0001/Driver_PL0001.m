% Jaimie Swartz, PI local controller code, 4/28/20

clc; clear all; close all;
disp('Running Local Controller...');
tic % begin counting sim elapsed time
%% initialize(loaddata.init)

Ts=0.1; % should agree with simulink outermost block setting
% 0.1 is more realistic, but hard to see conceptually on plots
% 1 easier to see, but controller should be faster than this irl

% read initialization file
    testIdx=68; % TEMP (sim1_1 = 2; sim_9 = 3), for each scenario run, first test below the headers is idx=1
    numHead=4; % number of header rows in init file
    [num txt raw]=xlsread('init.xlsx');
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
    n=607; % for each feeder, the number of cols in TV load/gen data (including time col), which is number of nodes*phases
    % TEMP:^ fix n assignment to allow feeders of diff sizes
    % IEEE13 unbal has n=35
    % IEEE13 bal has n=55
        
% need diff TV load/gen data file if SPBC phasor targets vs. if just
% tracking constant phasor (when tracking SPBC phasor targets the load
% data needs to be scaled down), thus the "norm03" in laod data filename
    r1=secStart; r2=secEnd; c1=0; c2=n-1; % needed for csvread, col and row offset so that extract snippet
    %loadData = csvread('PL0001_July_secondwise_norm03.csv',r1,c1,[r1 c1 r2 c2]); % secondwise, includes first col as timestamp, needed for simulink loop
    load('loaddata_PL0001unbal_tv.mat'); % populates "data" avr
    a=data'; loadData=a(1:length(secStart:secEnd),:);
    
    m=1;% modifier to scale the net load. With m=1, vmag very low (0.92pu)
    netLoadData=m*loadData; % units of kW, kVAR
    % loadData formatted [PPP ... QQQ] LD_634/P1	LD_634/Q1	LD_634/P2	LD_634/Q2	LD_634/P3	LD_634/Q3	LD_671/P1
 
% To keep tv load
%     netLoadData_snippet=netLoadData;
%     loadData_noTS=netLoadData(:,2:end); % remove timestamp

% To make CONST load data:
    tvdata=netLoadData(:,2:end);
    netLoadData_snippet=[netLoadData(:,1) repmat(tvdata(1,:),size(tvdata,1),1)];
    loadData_noTS=netLoadData_snippet(:,2:end); % remove timestamp

figure; plot(netLoadData_snippet(:,1),netLoadData_snippet(:,2:end)); title('load data for sim itvl, one curve for each node'); xlabel('seconds'); ylabel('kW or kVAR');

%read impedance model to get loadnames and busnames from header in column chunks
    [txt,num,raw] = xlsread('PL0001_OPAL_working_simple.xlsx','Pins','B1:IV1');
%     raw = csvread('impedMod_IEEE13_csv.csv',r1, c1, [r1 c1 r2 c2]);
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    loadNames1 =raw(1,2:end); % 
    loadNames1 = cellfun(@(S) S(8:end), loadNames1, 'Uniform', 0); % clean up string format

    [txt,num,raw] = xlsread('PL0001_OPAL_working_simple.xlsx','Pins','B4:IV4');
%     raw = csvread('impedMod_IEEE13_csv.csv',r1, c1, [r1 c1 r2 c2]);
    loadNames2 =raw(1,2:end); % 
    loadNames2 = cellfun(@(S) S(8:end), loadNames2, 'Uniform', 0); % clean up string format
    
    [txt,num,raw] = xlsread('PL0001_OPAL_working_simple.xlsx','Pins','B7:CV7');
%     raw = csvread('impedMod_IEEE13_csv.csv',r1, c1, [r1 c1 r2 c2]);
    loadNames3 =raw(1,2:end); % 
    loadNames3 = cellfun(@(S) S(8:end), loadNames3, 'Uniform', 0); % clean up string format
    
    loadNames = [loadNames1 loadNames2 loadNames3];
    
    [txt,num,raw] = xlsread('PL0001_OPAL_working_simple.xlsx','Pins','B2:IV3');
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    busNames1=raw(1,2:end); % used to select meas node
    busNames1=cellfun(@(S) S(3:end-5), busNames1, 'Uniform', 0); % clean up string format
    % Assign node location indices, print to help with debugging  
    
    [txt,num,raw] = xlsread('PL0001_OPAL_working_simple.xlsx','Pins','B5:IV6');
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    busNames2=raw(1,2:end); % used to select meas node
    busNames2=cellfun(@(S) S(3:end-5), busNames2, 'Uniform', 0); % clean up string format
    % Assign node location indices, print to help with debugging 
    
    [txt,num,raw] = xlsread('PL0001_OPAL_working_simple.xlsx','Pins','B8:IV9');
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    busNames3=raw(1,2:end); % used to select meas node
    busNames3=cellfun(@(S) S(3:end-5), busNames3, 'Uniform', 0); % clean up string format
    % Assign node location indices, print to help with debugging   
    
    [txt,num,raw] = xlsread('PL0001_OPAL_working_simple.xlsx','Pins','B10:FR11');
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    busNames4=raw(1,2:end); % used to select meas node
    busNames4=cellfun(@(S) S(3:end-5), busNames4, 'Uniform', 0); % clean up string format
    % Assign node location indices, print to help with debugging 
    
    busNames = [busNames1 busNames2 busNames3 busNames4];
    
    meas_idx=strToIdx(measStr,busNames)
    ctrl_idx=strToIdx(actStr,loadNames)
    dbc_idx=strToIdx(dbcStr,loadNames)
    Sinv=repmat(Sinv_str,1,length(ctrl_idx)/2) % TEMP, when multiple actuators need to use length of inv ctrl_idx, not whole ctrl_idx
    r=length(ctrl_idx)/2 % number of "phase-actuators", div by 2 because each phase actuator has P and Q control so control index has length 2*r
    
%     [netLoadData, PV_percent] = PV_Cloud_Disturbance(netLoadData, 200, 210);
%     figure; plot(netLoadData(:,1),netLoadData(:,2:end)); title('load data, after PV disturbance');
        controlLoopAlign=[loadNames(ctrl_idx)' repmat(busNames(meas_idx)',2,1)]
% to find idx of certain node: find(ismember(busNames,'300033983_A'))

%% Set targets/reference for controller to  track
    [Sbase,V1base,V2base] = computePU();
     Vbase=repmat(V1base,1,length(meas_idx));
    %[vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_SPBC_targets(minStart,minEnd,Sbase,V1base,V2base,measStr); 
    %[vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_UD_targets(minStart,minEnd,Sbase,V1base,V2base) ;
    [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target(minStart,minEnd,Sbase,meas_idx); 
   
%% --------------------- Simulation is now initialized -------------------------
    disp( '------------------- Designing controller...');

%% step2: run simulation to collect step response data
   
%     Turn controllers off    
    Kp_vmag=zeros(r,1);
    Ki_vmag=zeros(r,1);
    Kp_vang=zeros(r,1);
    Ki_vang=zeros(r,1);
    
    Vang_ctrlStart = (20+80*r)*Ts; % wait until after interval over which you tuned controller
    Vmag_ctrlStart = (20+80*r)*Ts; % in seconds, time for turning on controllers

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
    actualDbcData=createActualDbc(0*loadData_noTS(:,dbc_idx(Pidx)),0*loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv*Sbase,netLoadData_snippet,r);    
    n=length(ctrl_idx); Pidx=1:2:n-1; Qidx=2:2:n;
    %actualDbcData = actualDbcData*0;
    [testDbcData, dbcMeas, stepP, stepQ, dbcDur]=createTestDbc(loadData_noTS(:,ctrl_idx(Pidx)),loadData_noTS(:,ctrl_idx(Qidx)),Ts,ctrl_idx,Sbase); % testDbcData is a load value
    %testDbcData(:,2:7)=0;

    % testDbcData is in kW, not pu

     % Run sim with controllers off to get sys ID data
         disp('------------------- Running uncontrolled sim...');

    % Run simulink
        sim('Sim_v19_PL0001.mdl')
        set_param('Sim_v19_PL0001','AlgebraicLoopSolver','LineSearch'); % so that derivative term in discrete PID controller doesn't have error
        vmag_init_actual=vmag_new(4,:);
        vang_init_actual=vang_new(4,:);
        disp('finished simulink');    
        

   %% Compute sensitivities
       [dvdq dvdp ddeldq ddeldp sensMats]=computeSens(dbcMeas, stepP, stepQ, dbcDur, vmag_new,vang_new, ctrl_idx,loadNames,Sbase)
        % sensitivity values are in pu, sens=Vpu/Spu, deg/Spu
    if (any(diff(sign(dvdq(dvdq~=0)))) || any(diff(sign(ddeldp(ddeldp~=0))))) % if not all the same sign
        error('dvdq or ddeldp not all same sign across all phases. Check whether testDbc step size is exciting enouh (see plots)');
    end
    
    
%% Plot step responses for each phase
            % extra plot for way 3
    r=length(ctrl_idx)/2;
    %close all
    % qnew and vmag_new are in pu
    itvl=1:230; % timesteps
    figure;
    for i = 1:r
        subplot(1,r,i);
        [haxes hline1 hline2]=plotyy(itvl,vmag_new(itvl,i),itvl,testDbcData(itvl,i*2+1));
        set(hline1,'LineWidth',1.5);
    set(hline2,'LineWidth',1.5);
        legend('vmag','q load');
        xlabel('timesteps, Ts=0.1');
        ylabel('kW or kVAR, Vpu');
    end
    title('Q-->Vmag');
    figure;
    for i = 1:r
        subplot(1,r,i);
        [haxes hline1, hline2]=plotyy(itvl,vang_new(itvl,i),itvl,testDbcData(itvl,i*2));
        set(hline1,'LineWidth',1.5);
        set(hline2,'LineWidth',1.5);
        legend('vang','p load');
        xlabel('timesteps, Ts=0.1');
        ylabel('kW or kVAR, degrees');
    end
    title('P-->Vang');

    
    Vang_ctrl=true; % boolean
    Vmag_ctrl=true; % boolean
    
%% --------------------- Now ready to compute kgains -------------------------
% (to choose methdof ro computing controller gains)

% 1 - simplest, traditional Zeigler nichols method
% 2 - modified version of Zeigler nichols, using sensitivities of each
% phase-actuator
% 3 - new method, involving automatic tuning of controller to minimize a
% cost function

%kgainCalcType=2; % temp, for debugging


     [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang]=afunc(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,dvdp,ddeldq,Ts,r)

%% If want to load kgains instead to computing them
%     load('simtenNode_8_way3.mat','kgains'); % gives us "kgains"
%      Kp_vmag=kgains(1,:)
%      Ki_vmag=kgains(2,:)
%      Kp_vang=kgains(3,:)
%      Ki_vang=kgains(4,:)
% % 
 Kp_vmag=Kp_vmag*5;
 Ki_vmag=Ki_vmag*5;
 Kp_vang=Kp_vang*5;
 Ki_vang=Ki_vang*5;

% nomk=[0.8832 3.6299 0.0183 0.0617]; % pull from GA, min of each phase
% m=3.5; % inc starting at 1 until marg stability
% Kp_vmag=m*nomk(1)*ones(1,3);
% Ki_vmag=m*nomk(2)*ones(1,3);
% Kp_vang=m*nomk(3)*ones(1,3);
% Ki_vang=m*nomk(4)*ones(1,3);

%% --------------------- Controller kgains are now set -------------------------
%% Create disturbance for controlled sim %comment out for 2.1 tests 
    % define disturbance directly in this function below 
%     
     n=length(dbc_idx); Pidx=1:2:n-1; Qidx=2:2:n;
     actualDbcData=createActualDbc(0*loadData_noTS(:,dbc_idx(Pidx)),0*loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv*Sbase,netLoadData_snippet,r);    

     %actualDbcData(:,2:end)=0.7*actualDbcData(:,2:end);
     
    % n=length(ctrl_idx); Pidx=1:2:n-1; Qidx=2:2:n;
   % [testDbcData, dbcMeas, stepP, stepQ, dbcDur]=createTestDbc(0*loadData_noTS(:,ctrl_idx(Pidx)),0*loadData_noTS(:,ctrl_idx(Qidx)),Ts,ctrl_idx);
    testDbcData(:,2:end)=0;

    % actualDbcData format = [P...P Q...Q]
   %figure; plot(actualDbcData(:,[2:6,8,11:12,14:15,17:23,25,28:29,31:32,34:35]),'LineWidth',1.5); title('Disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); 
   % figure; plot(testDbcData(1:200/Ts,2:end),'LineWidth',1.5); title('test disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); legend('P','Q');
  %  figure; plot(actualDbcData(:,[2:7]),'LineWidth',1.5); title('Disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); 
% legend('Pa','Pb','Pc','Qa','Qb','Qc');

    
%%  Run sim with controllers ON

    disp('------------------- Running controlled sim...');
    % Run simulink
        sim('Sim_v19_PL0001.mdl')
        set_param('Sim_v19_PL0001','AlgebraicLoopSolver','LineSearch'); % so that derivative term in discrete PID controller doesn't have error
        vmag_init_actual=vmag_new(4,:);
        vang_init_actual=vang_new(4,:);
        disp('finished simulink');    


%% Save results 
    % Run PlotLocalCtrl in command prompt to see results

    % so that results tracking tool can compute performance metrics
    disp('------------------- Outputing results...');
    % save data into .mats
   kgains=[Kp_vmag; Ki_vmag; Kp_vang; Ki_vang];
	 save(resultsName,'vmag_new','vang_new','pnew','qnew','simTimestamps','vmag_ref_sig','vang_ref_sig','kgains','controlLoopAlign')
     %clear all; load('simData_001.mat'); whos
     
%% ------------------------- End of Code ----------------------------------
toc % print elapsed sim time
%% Version Control Log
% sim_v19 simulink .mdl
% revamp of PI control blocks

% phasor08_IEEE13_v18_PIDofflineCalc
% code revamp, added meas selector and update powers MATLAB function
% blocks, deleted inverter delay blocks

% phasor08_IEEE13_v17_PIDofflineCalc
% added back dbc block, most blocks still manually connected together

% phasor08_IEEE13_v16_PIDofflineCalc
% added back TV load/gen block

% phasor08_IEEE13_v15_PIDofflineCalc
% does not have TV load and generation data, solver block has ref to GB_IEEE13_balance all.xls, not unbalanced like before

% phasor08_IEEE13_v14_PIDofflineCalc
% does not have non-PV disturbance nor PV disturbance block, does not have
% actuator limit block, does have TV load and generation data

% phasor08_IEEE13_v13_PIDofflineCalc
% has non-PV disturbance and PV disturbance block