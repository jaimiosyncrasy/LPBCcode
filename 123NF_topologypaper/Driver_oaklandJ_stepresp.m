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
test_num=1; % (sim1_1 = 2; sim_9 = 3), for each scenario run, first test below the headers is idx=1

disp('Running Local Controller...');
tic % begin counting sim elapsed time

%% initialize(loaddata.init)
% check: impedance model pins are exactly 3 rows, and load list is same as
% TV load/gen data

    Ts=1; % should agree with simulink outermost block setting
    % 0.1 is more realistic, but hard to see conceptually on plots
    % 1 easier to see, but controller should be faster than this irl

% read initialization file
    numHead=4; % number of header rows in init file, dont change this
    [num txt raw]=xlsread('init_7.31_busListOrder.xlsx');
    % see row 4 of initilaization file to verify hardcoded index number 
    testKey=raw(test_num+numHead,1); testKey=testKey{1}
    disp(strcat('---------- Initializing controller test',testKey,'----------'));
    kgainCalcType=raw(test_num+numHead,2); kgainCalcType=kgainCalcType{1}
    PVpen=raw(test_num+numHead,4); PVpen=PVpen{1};
    time=raw(test_num+numHead,5); time=time{1}; time=strsplit(time,'-');
    timeStart=time(1); timeEnd=time(2); % HH:MM format, for full day  use 23:59
    [minStart,minEnd,simTimestamps] = setSimTime(timeStart,timeEnd);
    resultsName=raw(test_num+numHead,2); resultsName=resultsName{1};
    % 'raw LPBC output name' col not used by this code, instead used by results tracking tool
    measStr=raw(test_num+numHead,7); measStr=measStr{1}; % convert cell array to string
    actStr=raw(test_num+numHead,9); actStr=actStr{1};
    dbcStr=raw(test_num+numHead,12); dbcStr=dbcStr{1};
    Sinv_str=raw(test_num+numHead,11); Sinv_str=Sinv_str{1}; % inv limit, apparent pow
    ridxStr=raw(test_num+numHead,10); ridxStr=ridxStr{1}; 
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
    n=295; % for each feeder, the number of cols in TV load/gen data (including time col), which is number of nodes*phases
    % parms for changing feeders: https://docs.google.com/document/d/1sW9_txbTIt1qRnV-qul3Sq5a_F1xBMD70WIAcUUA-SI/edit
    r1=secStart; r2=secEnd; c1=0; c2=n-1; % col and row offset
    
% need diff TV load/gen data file if SPBC phasor targets vs. if just
% tracking constant phasor (when tracking SPBC phasor targets the load
% data needs to be scaled down)
    % netLoadData = csvread('sig0.3_001_phasor08_IEEE13_secondWise_sigBuilder_5min_normalized_03.csv',r1,c1,[r1 c1 r2 c2]); % includes first col as timestamp, needed for simulink loop
    %netLoadData = csvread('001_phasor08_IEEE13_time_sigBuilder_secondwise_norm03.csv',r1,c1,[r1 c1 r2 c2]); % includes first col as timestamp, needed for simulink loop
  %  loadData = csvread('123NF_sct700_PVpen125_NL.csv',r1,c1,[r1 c1 r2 c2]); % includes first col as timestamp, needed for simulink loop
    [loadData,~,~] = xlsread('123NF_sct670_PVpen125_NL.csv'); % PQloads has time vector
    
    m=1;% modifier to scale the net load. With m=1, vmag very low (0.92pu)
    netLoadData=m*loadData; % units of kW, kVAR
    % loadData formatted [PPP ... QQQ] LD_634/P1	LD_634/Q1	LD_634/P2	LD_634/Q2	LD_634/P3	LD_634/Q3	LD_671/P1
     
    % To keep tv load
        netLoadData_snippet=netLoadData;

    % To make CONST load data:
    %     tvdata=netLoadData(:,2:end);
    %     netLoadData_snippet=[netLoadData(:,1) repmat(tvdata(1,:),size(tvdata,1),1)];
    %     loadData_noTS=netLoadData_snippet(:,2:end); % remove timestamp

    figure; plot(netLoadData_snippet(:,1),netLoadData_snippet(:,2:end)); title('load data for sim itvl, one curve for each node'); xlabel('seconds'); ylabel('kW or kVAR');
    TVload_start=min(find(diff(netLoadData_snippet(:,2))>0))

    %r1 = 0; r2 = 1; c1 = 1; c2 = 35;
    % NOTE: starting pin must be B, not C! This is because we remove the
    % first col afterward
    [txt,num,raw] = xlsread('004_GB_IEEE123_OPAL_accur.xlsx','Pins','B1:KJ1'); % pick out load names
%     raw = csvread('impedMod_IEEE13_csv.csv',r1, c1, [r1 c1 r2 c2]);
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    loadNames =raw(1,2:end); % 
    loadNames = cellfun(@(S) S(4:end), loadNames, 'Uniform', 0); % clean up string format

    [txt,num,raw] = xlsread('004_GB_IEEE123_OPAL_accur.xlsx','Pins','B2:JP3'); % pick out bus names
    busNames=raw(1,2:end); % used to select meas node
    busNames=cellfun(@(S) S(1:end-5), busNames, 'Uniform', 0); % clean up string format
    % Assign node location indices, print to help with debugging  
%%
    meas_idx=strToIdx(measStr,busNames); uniq_meas_idx=get_unique_sorted(meas_idx,measStr);
 %   meas_idx=strToIdx(measStr,busNames); uniq_meas_idx=unique(meas_idx,'sorted');
    ctrl_idx_align=strToIdx(actStr,loadNames)
    dbc_idx=strToIdx(dbcStr,loadNames)
    Sinv=repmat(Sinv_str,1,length(ctrl_idx_align)/2); % TEMP, when multiple actuators need to use length of inv ctrl_idx, not whole ctrl_idx
    r=length(ctrl_idx_align)/2 % number of "phase-actuators", div by 2 because each phase actuator has P and Q control so control index has length 2*r
    
%     [netLoadData, PV_percent] = PV_Cloud_Disturbance(netLoadData, 200, 210);
%     figure; plot(netLoadData(:,1),netLoadData(:,2:end)); title('load data, after PV disturbance');

% Print which measurments alin with which actuators, each row is a meas-act
% loop
    controlLoopAlign=[loadNames(ctrl_idx_align)' repmat(busNames(meas_idx)',2,1)]
    
    [~,txt,~]=xlsread('123NF_busList.csv');
    busNames=txt(:,1); foo=split(busNames,'_'); busNames_short=foo(:,2); % get the node number only
    ctrl_idx=[make_busOrder(busNames_short,loadNames(ctrl_idx_align(1:length(ctrl_idx_align)/2)),ctrl_idx_align(1:length(ctrl_idx_align)/2))...
        make_busOrder(busNames_short,loadNames(ctrl_idx_align(length(ctrl_idx_align)/2+1:end)),ctrl_idx_align(length(ctrl_idx_align)/2+1:end))];
    loadNames(ctrl_idx)'
    
%% create table of controllable nodes, their resource type, and capacity
% 1 for battery+PV, 2 for battery only, 3 for EV
rsc_type=2*ones(1,length(ctrl_idx)/2) % all DERs are batteries
capacity=500*ones(1,length(ctrl_idx)/2) % 500kVA batteries
RscTable=[rsc_type' capacity'];

PFset=0.9 % you choose
for i=1:size(RscTable,1)
    Sinv=RscTable(i,2); % capacity for each phase actuator
    syms P Q
    S=solve(PFset==cos(atan(Q/P)),P^2+Q^2==Sinv^2,[Q,P])
    pf_P(i)=max(eval(S.P));
    pf_Q(i)=max(eval(S.Q)); % lagging so choose max
end

Options=[1 1]; % [Testing PBC_ctrl]

%% read PV data  to get P_TOD
    timevec=[1:600]';
    P_TOD=[timevec (6*21)*ones(length(timevec),length(ctrl_idx)/2)];
    
%% Set targets/reference for controller to  track
    [Sbase,V1base,V2base] = computePU(); 
% Vbase must match the base of the performance nodes
    %Vbase=[repmat(V1base,6,1); repmat(V2base,3,1); repmat(V1base,3,1);]; % for vvc compare
   % Vbase=[repmat(V1base,6,1); repmat(V2base,3,1); repmat(V1base,3,1)]; % for vvc compare
    %Vbase=[V1base V1base V1base];
    perf_Vbase=V1base; % node 10 on primary side
    
    %[vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_SPBC_targets(minStart,minEnd,Sbase,V1base,V2base,measStr); 
    %[vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_UD_targets(minStart,minEnd,Sbase,V1base,V2base) ;
    [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target(minStart,minEnd,Sbase,meas_idx,measStr,controlLoopAlign,test_num); 
   
%     vmag_ref
%     vang_ref
%% --------------------- Simulation is now initialized -------------------------
    disp( '------------------- Designing controller...');

%% step2: run simulation to collect step response data
   
%     Turn controllers off  
    sz1=length(ctrl_idx); sz2=length(unique(meas_idx,'stable'));
    F11=zeros(sz1/2,sz2); F12=F11; F21=F11; F22=F11;
    
     Vang_ctrlStart = 0; % wait until after interval over which you tuned controller
     Vmag_ctrlStart = 0; % in seconds, time for turning on controllers

    % CHANGES FOR WHEN r=numPhaseAct>24:
    %only create 24*2 step changes, not r*2 step changes
    % select these 24 out of r randomly
    % thus dvdq and sensMats are size 24 not r
    % kgains are size r not 24
    % write new func: afunc_manyact
    % in GA instead of indexing each dvdq(i), compute max dvdq, min dvdq
    % and use those for all UB and LBs
    
%% Create test disturbance to collect step response data
    % setup netload data to be const during step tests
    dbcDur=5; % in timesteps, not in seconds; to get seconds, multiply by Ts
    dbcTime=dbcDur*length(ctrl_idx)*2+5; 
    timevec=[1:dbcTime]';
    netLoadData_snippet=[timevec repmat(netLoadData(1,2:end),dbcTime,1)]; % set netLoadData to be constant just for uncontrolled sim
    loadData_noTS=netLoadData_snippet(:,2:end); % remove timestamp

    n=length(dbc_idx); dbcP_idx=1:2:n-1; dbcQ_idx=2:2:n; % dbc_idx is formatted PQPQ
    actualDbcData=createActualDbc(0*loadData_noTS(:,dbc_idx(dbcP_idx)),0*loadData_noTS(:,dbc_idx(dbcQ_idx)),Ts,dbc_idx,Sinv,netLoadData_snippet,r);    
    n=length(ctrl_idx); ctrlP_idx=1:n/2; ctrlQ_idx=n/2+1:n;
    %actualDbcData = actualDbcData*0;
    [testDbcData, dbcMeas, stepP, stepQ]=createTestDbc(loadData_noTS(:,ctrl_idx(ctrlP_idx)),loadData_noTS(:,ctrl_idx(ctrlQ_idx)),Ts,ctrl_idx,dbcDur,loadNames); % testDbcData is a load value
    %testDbcData(:,2:7)=0;
    assert(size(testDbcData,1)==size(actualDbcData,1))


   %% Run sim with controllers off to get sys ID data
     disp('------------------- Running uncontrolled sim...');
      set_param('sim123NF_v2', 'StopTime', num2str(size(testDbcData,1)))

    % Run simulink
        sim('sim123NF_v2.mdl')
        vmag_init_actual=vmag_new(40,:);
        vang_init_actual=vang_new(40,:);
        disp('finished simulink');    
        
    % Compute sensitivities
       [dvdq dvdp ddeldq ddeldp sensMats]=computeSens(dbcMeas, stepP, stepQ, dbcDur, vmag_new,vang_new, ctrl_idx,uniq_meas_idx,loadNames,Sbase)
        % units: [V/kVAR V/kW deg/kVar deg/kW]
if (any(diff(sign(dvdq(dvdq~=0)))) || any(diff(sign(ddeldp(ddeldp~=0))))) % if not all the same sign
    disp('warning: dvdq or ddeldp not all same sign across all phases. Check whether testDbc step size is exciting enouh (see plots)');
end
scale=1; [dvdq(1)*scale,dvdp(1)*scale,ddeldq(1)*scale,ddeldp(1)*scale] % expect 2nd smaller than 1st, 4th smaller than 3rd
%^ should be close to impedance vlaues!
%save(resultsName,'sensMats','dvdp','dvdq','ddeldq','ddeldp');

%% %% Plot step responses for each phase
%         % extra plot for way 3
% r=length(ctrl_idx)/2;
% plotr=min([r,8]);
% %close all
% % qnew and vmag_new are in pu
% if size(vmag_new,1)>150
%     itvl=1:150; % number of timesteps to plot
% else
%     itvl=1:size(vmag_new,1)-1;
% end
% figure;
% for i = 1:plotr
%     subplot(1,plotr,i);
%     for j=1:length(uniq_meas_idx)
%         [haxes hline1 hline2]=plotyy(itvl,vmag_new(itvl,j),itvl,testDbcData(itvl,i*2+1));
%         set(hline1,'LineWidth',1.5);
%     set(hline2,'LineWidth',1.5);
%         legend('vmag','q');
%     end
% end
% title('Q-->Vmag');
% figure;
% for i = 1:plotr
%     subplot(1,plotr,i);
%     for j=1:length(uniq_meas_idx)
%         [haxes hline1, hline2]=plotyy(itvl,vang_new(itvl,j),itvl,testDbcData(itvl,i*2));
%         set(hline1,'LineWidth',1.5);
%         set(hline2,'LineWidth',1.5);
%         legend('vang','p');
%     end
% end
% title('P-->Vang');
%         
% % figure; plot(allPQ(1:250,7:9),'LineWidth',1.5);
% % figure; plot(allPQ(1:250,34:36),'LineWidth',1.5);

save(strcat('stepdata/stepdata_test',num2str(test_num),'_9.21.mat')) % save all vars so can load them
 %%