
% Jaimie Swartz, PI local controller code, 1/30/20
%clc; clearvars -except myVars sensCell powCell e; close all;
clc; clear all; close all;

disp('Running Local Controller...');
tic % begin counting sim elapsed time
%% initialize(loaddata.init)
% check: impedance model pins are exactly 3 rows, and load list is same as
% TV load/gen data

Ts=0.1; % should agree with simulink outermost block setting
% 0.1 is more realistic, but hard to see conceptually on plots
% 1 easier to see, but controller should be faster than this irl

% read initialization fil
    % CHECK THIS
    testIdx=1; % TEMP (sim1_1 = 2; sim_9 = 3), for each scenario run, first test below the headers is idx=1
    numHead=4; % number of header rows in init file, constant
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
    n=35; % for each feeder, the number of cols in TV load/gen data (including time col), which is number of nodes*phases
    % TEMP:^ fix n assignment to allow feeders of diff sizes
    % IEEE13 unbal has n=35
    % IEEE13 bal has n=55
    
    r1=secStart; r2=secEnd; c1=0; c2=n-1; % col and row offset
    
% need diff TV load/gen data file if SPBC phasor targets vs. if just
% tracking constant phasor (when tracking SPBC phasor targets the load
% data needs to be scaled down)
    % for sim1_1 and others:
    % netLoadData = csvread('sig0.3_001_phasor08_IEEE13_secondWise_sigBuilder_5min_normalized_03.csv',r1,c1,[r1 c1 r2 c2]); % includes first col as timestamp, needed for simulink loop
    % for adam1 sim:
    %netLoadData = csvread('001_phasor08_IEEE13_time_sigBuilder_secondwise_norm03.csv',r1,c1,[r1 c1 r2 c2]); % includes first col as timestamp, needed for simulink loop
    out = csvread('001_IEEE13_secondWise_sigBuilder.csv',r1,c1,[r1 c1 r2 c2]); % includes first col as timestamp, needed for simulink loop
    m=1;% modifier to scale the net load. With m=1, vmag very low (0.92pu)
    netLoadData=m*out;
    loadData_noTS=netLoadData(:,2:end); % remove timestamp
%     loadData_noTS=loadData_noTS*0;
    netLoadData=[[1:size(loadData_noTS,1)]' loadData_noTS]; % append timestamp starting at 1 so simulink can parse timseries properly
    figure; plot(netLoadData(:,1),netLoadData(:,2:end)); title('load data, one curve for each node'); xlabel('seconds'); ylabel('kW or kVAR');
    
    %r1 = 0; r2 = 1; c1 = 1; c2 = 35;
    [txt,num,raw] = xlsread('impedMod_IEEE13.xls','Pins','B1:AJ1');
%     raw = csvread('impedMod_IEEE13_csv.csv',r1, c1, [r1 c1 r2 c2]);
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    loadNames =raw(1,2:end); % 
    loadNames = cellfun(@(S) S(4:end), loadNames, 'Uniform', 0); % clean up string format

%     [txt,num,raw] = xlsread('004_GB_IEEE123_pins.xls','Pins','A5:IV5');
% %     raw = csvread('impedMod_IEEE13_csv.csv',r1, c1, [r1 c1 r2 c2]);
%     % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
%     loadNames2 =raw(1,1:end); % 
%     loadNames2 = cellfun(@(S) S(4:end), loadNames2, 'Uniform', 0); % clean up string format
    
%     loadNames = [loadNames1 loadNames2];

    [txt,num,raw] = xlsread('impedMod_IEEE13.xls','Pins','B2:AK3');
 %   [txt,num,raw] = xlsread('016_GB_IEEE13_balance_all_ver2_OPAL2.xls','Pins','B2:AK3');
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    busNames=raw(1,2:end); % used to select meas node
    busNames=cellfun(@(S) S(1:end-5), busNames, 'Uniform', 0); % clean up string format
    % Assign node location indices, print to help with debugging  
    %TEMP for longer feeder 
%     [txt,num,raw] = xlsread('004_GB_IEEE123_pins.xls','Pins','B6:S7');
%     % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
%     busNames2=raw(1,2:end); % used to select meas node
%     busNames2=cellfun(@(S) S(1:end-5), busNames2, 'Uniform', 0); % clean up string format
%     % Assign node location indices, print to help with debugging 
%     busNames = [busNames1 busNames2];
    
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
    Vbase=[V1base V1base V1base];
    %Vbase=[repmat(V1base,7,1);]; % multAct sim

    
    %[vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_SPBC_targets(minStart,minEnd,Sbase,V1base,V2base,measStr); 
    %[vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_UD_targets(minStart,minEnd,Sbase,V1base,V2base) ;
    [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target(minStart,minEnd,Sbase,meas_idx); 

%% --------------------- Simulation is now initialized -------------------------
    disp( '------------------- Designing controller...');

%% step2: run simulation to collect step response data
   
%     Turn controllers off    
        Vang_ctrl=false; % boolean
        Vmag_ctrl=false; % boolean
    
    % TEMP: this snippet of code allows you to produce PI control sim
    load('sunny_2_PIway3.mat','kgains')
    Vang_ctrlStart = (20+80*r)*Ts; % wait until after interval over which you tuned controller
    Vmag_ctrlStart = (20+80*r)*Ts; % in seconds, time for turning on controllers
    Kp_vmag=kgains(1,:);
    Ki_vmag=kgains(2,:);
    Kp_vang=kgains(3,:);
    Ki_vang=kgains(4,:);
%%
    
    % Create test disturbance to collect step response data
    n=length(dbc_idx); Pidx=1:2:n-1; Qidx=2:2:n;
    actualDbcData=createActualDbc(0*loadData_noTS(:,dbc_idx(Pidx)),0*loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv*Sbase,netLoadData,r);    
    n=length(ctrl_idx); Pidx=1:2:n-1; Qidx=2:2:n;
    %actualDbcData = actualDbcData*0;
    [testDbcData, dbcMeas, stepP, stepQ, dbcDur]=createTestDbc(loadData_noTS(:,ctrl_idx(Pidx)),loadData_noTS(:,ctrl_idx(Qidx)),Ts,ctrl_idx,Sbase);
    % testDbcData is in kW, not pu
    
     % Run sim with controllers off to get sys ID data
         disp('------------------- Running uncontrolled sim...');

    % Run simulink

        sim('sunny2_PI.mdl')
        set_param('sunny2_PI','AlgebraicLoopSolver','LineSearch'); % so that derivative term in discrete PID controller doesn't have error
        vmag_init_actual=vmag_new(40,:);
        vang_init_actual-vang_new(40,:);
        disp('finished simulink');    

%% --------------------- Now ready to compute kgains -------------------------


% Adam: set controller gains/design here

%% --------------------- Controller kgains are now set -------------------------

%% Create disturbance for controlled sim %comment out for 2.1 tests 
    % define disturbance directly in this function below 
%     
     n=length(dbc_idx); Pidx=1:2:n-1; Qidx=2:2:n;
     %actualDbcData =createActualDbc(0*loadData_noTS(:,dbc_idx(Pidx)),0*loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv*Sbase, netLoadData,r);
     
     % CHECK THIS
   %  actualDbcData =createActualDbc(loadData_noTS(:,dbc_idx(Pidx)),loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv*Sbase, netLoadData,r);     
    % save('dbcData_sunny2','actualDbcData');
    load('dbcData_sunny2.mat');
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
    figure; plot(actualDbcData(:,[2:7]),'LineWidth',1.5); title('Disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); 
legend('Pa','Pb','Pc','Qa','Qb','Qc');

%%  Run sim with controllers ON

    disp('------------------- Running controlled sim...');
    % Run simulink
    % CHECK THIS
        sim('sunny2_PI.mdl')
        set_param('sunny2_PI','AlgebraicLoopSolver','LineSearch'); % so that derivative term in discrete PID controller doesn't have error
        vmag_init_actual=vmag_new(40,:);
        vang_init_actual=vang_new(40,:);
        disp('finished simulink');    


%% Save results 
    % Run PlotLocalCtrl in command prompt to see results

    % so that results tracking tool can compute performance metrics
    disp('------------------- Outputing results...');
    % save data into .mats
    kgains=[Kp_vmag; Ki_vmag; Kp_vang; Ki_vang];
	 save(resultsName,'vmag_new','vang_new','pnew','qnew','simTimestamps','vmag_ref_sig','vang_ref_sig','kgains')
     % to check what you've saved away...
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