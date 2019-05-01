% check: impedance model pins are exactly 3 rows, and load list is same as
% TV load/gen data

% Jaimie Swartz, PI local controller code, 3/28/19
clc; clear all; close all;
disp('Running Local Controller...');
tic % begin counting sim elapsed time
%% initialize(loaddata.init)

Ts=0.1; % should agree with simulink outermost block setting
% 0.1 is more realistic, but hard to see conceptually on plots
% 1 easier to see, but controller should be faster than this irl

% read initialization file
    testIdx=3; % TEMP, for each scenario run, first test below the headers is idx=1
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
    dbcStr=raw(testIdx+numHead,8); dbcStr=dbcStr{1};
    Sinv_str=raw(testIdx+numHead,9); Sinv_str=Sinv_str{1}; % inv limit, apparent pow

% vars read in from initialization that are not used yet: PVpen
% may need later: strcmp(kgainCalcType,'ZN')

%% read TV load/gen data
    % this code expects second-wise data
    % use xlsread to obtain loadNames from header, then csvread to read data (too much data for xlsread to handle)
    secStart=minStart*60+1; secEnd=minEnd*60; % use exact index as in first col of the .csv
    n=910; % for each feeder, the number of cols in TV load/gen data, which is number of nodes*phases
    % TEMP:^ fix n assignment to allow feeders of diff sizes
    
    r1=secStart; r2=secEnd; c1=0; c2=n-1; % col and row offset
    netLoadData = csvread('sig03_PL0001_April_1sheet.csv',r1,c1,[r1 c1 r2 c2]); % includes first col as timestamp, needed for simulink loop
    loadData_noTS=netLoadData(:,2:end); % remove timestamp
    netLoadData=[[1:size(loadData_noTS,1)]' loadData_noTS]; % append timestamp starting at 1 so simulink can parse timseries properly
    figure; plot(netLoadData(:,1),netLoadData(:,2:end)); title('load data, one curve for each node');
    
    [txt,num,raw] = xlsread('PL0001_v4.xls','Pins','B1:WJ1');
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    loadNames=raw(2:end); % 
    loadNames = cellfun(@(S) S(4:end), loadNames, 'Uniform', 0); % clean up string format
    
    [txt,num,raw] = xlsread('PL0001_v4.xls','Pins','B2:ALH3');
    % TEMP: ^replace 'B1:AJ2'hardcoding to allow for feeders of diff sizes
    busNames=raw(1,2:end); % used to select meas node
    busNames=cellfun(@(S) S(1:end-5), busNames, 'Uniform', 0); % clean up string format

    % Assign node location indices, print to help with debugging
    meas_idx=strToIdx(measStr,busNames)
    ctrl_idx=strToIdx(actStr,loadNames)
    dbc_idx=strToIdx(dbcStr,loadNames)
    Sinv=repmat(Sinv_str,1,length(ctrl_idx)/2) % TEMP, when multiple actuators need to use length of inv ctrl_idx, not whole ctrl_idx

%% Set targets/reference for controller to  track
     [Sbase,V1base,V2base] = computePU();
    %[vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_SPBC_targets(minStart,minEnd,Sbase,V1base,V2base); 
    [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_UD_targets(minStart,minEnd,Sbase,V1base,V2base) ;
    %[vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target(minStart,minEnd,Sbase,V1base,V2base); 
%% --------------------- Simulation is now initialized -------------------------
    disp( '------------------- Designing controller...');

%% Ability1: det Ku by running this over and over
    [ZNcritMat,Kp_vmag,Ki_vmag,Kp_vang,Ki_vang]=ZNtune()   
    Vang_ctrl=true; % boolean
    Vmag_ctrl=true; % boolean
[Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=computeK_ZN(Vmag_ctrl,Vang_ctrl,Kp_vmag,Ki_vmag,Kp_vang,Ki_vang)

    
%% Ability2: det sensitivities by running this
   
    % Turn controllers off    
        Vang_ctrl=false; % boolean
        Vmag_ctrl=false; % boolean
        [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=computeK_ZN(Vmag_ctrl,Vang_ctrl,Kp_vmag,Ki_vmag,Kp_vang,Ki_vang)

    % Create test disturbance
    % inialize actual dbc to 0, only run test dbc
    n=length(dbc_idx); Pidx=1:2:n-1; Qidx=2:2:n;
    actualDbcData=createActualDbc(0*loadData_noTS(:,dbc_idx(Pidx)),0*loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv*Sbase);
    n=length(ctrl_idx); Pidx=1:2:n-1; Qidx=2:2:n;
    [testDbcData, dbcMeas, stepP, stepQ, dbcDur]=createTestDbc(loadData_noTS(:,ctrl_idx(Pidx)),loadData_noTS(:,ctrl_idx(Qidx)),Ts,ctrl_idx);
    

     % Run sim with controllers off to get sys ID data
         disdelta_u_vmagp('------------------- Running uncontrolled sim...');

    % Run simulink
        sim('Sim_v18.mdl')
        set_param('Sim_v18','AlgebraicLoopSolver','LineSearch'); % so that derivative term in discrete PID controller doesn't have error
        vmag_init_actual=vmag_new(4,:);
        vang_init_actual-vang_new(4,:);
        disp('finished simulink');    
        
    % Compute sensitivities
        [dvdq dvdp ddeldq ddeldp]=computeSens(dbcMeas, stepP, stepQ, dbcDur, vmag_new,vang_new, Sbase,ctrl_idx,loadNames)
        [dvdq dvdp ddeldq ddeldp] % print
        % units: [pu/pu pu/pu deg/pu deg/pu]
        
%% --------------------- Now ready to compute kgains -------------------------
kgain_method=1; % USER SETS THIS MANUALLY 
% (to choose methdof ro computing controller gains)
% 1 - simplest, traditional Zeigler nichols method
% 2 - modified version of Zeigler nichols, using sensitivities of each
% phase-actuator
% 3 - new method, involving automatic tuning of controller to minimize a
% cost function

%% -------------------
switch kgain_method
case 1
    %% Set kgains using way 1, save as test1_way1.mat
    [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang]=ZNset(ZNcritMat)  
        Vang_ctrl=true; % boolean
        Vmag_ctrl=true; % boolean
    [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=computeK_ZN(Vmag_ctrl,Vang_ctrl,Kp_vmag,Ki_vmag,Kp_vang,Ki_vang)

case 2
    %% Set kgains using way 2, save as test1_way2.mat
    [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang]=ZNset(ZNcritMat)  
        Vang_ctrl=true; % boolean
        Vmag_ctrl=true; % boolean    
    [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=computeK_ZNplus(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,Kp_vmag,Ki_vmag,Kp_vang,Ki_vang)
case 3 
    %% Set kgains using way 3, save as test1_way3.mat 
        Vang_ctrl=true; % boolean
        Vmag_ctrl=true; % boolean
    [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=computeK_way3(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,Ts)

end
%% --------------------- Controller kgains are now set -------------------------
%% Create disturbance for controlled sim
    % define disturbance directly in this function below
    n=length(dbc_idx); Pidx=1:2:n-1; Qidx=2:2:n;
    actualDbcData=createActualDbc(loadData_noTS(:,dbc_idx(Pidx)),loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv*Sbase);
    n=length(ctrl_idx); Pidx=1:2:n-1; Qidx=2:2:n;
    [testDbcData, dbcMeas, stepP, stepQ, dbcDur]=createTestDbc(0*loadData_noTS(:,ctrl_idx(Pidx)),0*loadData_noTS(:,ctrl_idx(Qidx)),Ts,ctrl_idx);
    
    figure; plot(actualDbcData(1:200/Ts,2:end),'LineWidth',1.5); title('actual disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); legend('P','Q');
    figure; plot(testDbcData(1:200/Ts,2:end),'LineWidth',1.5); title('test disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); legend('P','Q');
   
%%  Run sim with controllers ON

    disp('------------------- Running controlled sim...');
    % Run simulink
        sim('Sim_v18.mdl')
        set_param('Sim_v18','AlgebraicLoopSolver','LineSearch'); % so that derivative term in discrete PID controller doesn't have error
        vmag_init_actual=vmag_new(4,:);
        vang_init_actual=vang_new(4,:);
        disp('finished simulink');    


%% Save results 
    % Run PlotLocalCtrl in command prompt to see results

    % so that results tracking tool can compute performance metrics
    disp('------------------- Outputing results...');
    % save data into .mats
	 save(resultsName,'vmag_new','vang_new','pnew','qnew','simTimestamps','vmag_ref','vang_ref')
     % to check what you've saved away...
     %clear all; load('simData_001.mat'); whos
     
%% ------------------------- End of Code ----------------------------------
toc % print elapsed sim time
%% Version Control Log
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