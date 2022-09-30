% in this code, we run simulink multiple times

% first run this for 3 consecutive sims

clc; clear all; 
close all

%% define sim start times and durations

test_num=6; % (sim1_1 = 2; sim_9 = 3), for each scenario run, first test below the headers is idx=1
Ts=1; % should agree with simulink outermost block setting
% 0 would be startng at midnight
%simStartTimes=[0:15:1440]; %in minutes
%simStartTimes=[670:15:701]; %in minutes
%simDur=8; % in minutes, number of sim iterations

Vang_ctrl=true; Vmag_ctrl=true; % boolean; % 1 for on


%% read init file
    numHead=4; % number of header rows in init file, dont change this
    [num txt raw]=xlsread('init_7.31_busListOrder.xlsx');
    % see row 4 of initilaization file to verify hardcoded index number 
    
    time=raw(test_num+numHead,5); time=time{1}; time=strsplit(time,'-');
    timeStart=time(1); timeEnd=time(2); % HH:MM format, for full day  use 23:59
    [minStart,minEnd,simTimestamps] = setSimTime(timeStart,timeEnd);
    simStartTimes=[minStart:15:minEnd]; %in minutes
    num_tarSets=length(simStartTimes)
    simDur=8; % you in minutes, number of sim iterations
    % we have 15 minute load data, so if your simStartTimes ranges across 60
    % minutes, expect to see 4 shifts in load data plotted
    assert(minEnd-minStart>simDur)
    assert(all(simDur<diff(simStartTimes)))

    testKey=raw(test_num+numHead,1); testKey=testKey{1}
    disp(strcat('---------- Initializing controller test',testKey,'----------'));
    PVpen=raw(test_num+numHead,4); PVpen=PVpen{1};
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

%% read TV load/gen data
    % this code expects second-wise data
    % use xlsread to obtain loadNames from header, then csvread to read data (too much data for xlsread to handle)
    n=295; % for each feeder, the number of cols in TV load/gen data (including time col), which is number of nodes*phases
    % parms for changing feeders: https://docs.google.com/document/d/1sW9_txbTIt1qRnV-qul3Sq5a_F1xBMD70WIAcUUA-SI/edit
    
    [loadData,~,~] = xlsread('123NF_mnt_PVpen125_NL.csv'); % PQloads has time vector
    numrep=15*60; foo=kron(loadData(:,2:end),ones(numrep,1)); % stretch data by 60 timesteps
    loadData2=[[1:length(foo)]' foo]; % secondwise
    assert(size(loadData2,1)>=86400,'load data is not secondwise across a full day') % assume the load data is secondwise across a whole day

    m=1;% modifier to scale the net load. With m=1, vmag very low (0.92pu)
    netLoadData=m*loadData2(simStartTimes(1)*60:simStartTimes(end)*60+simDur*60,:); % units of kW, kVAR
    % loadData formatted [PPP ... QQQ] LD_634/P1	LD_634/Q1	LD_634/P2	LD_634/Q2	LD_634/P3	LD_634/Q3	LD_671/P1
     
    % To keep tv load
        % get full

    % To make CONST load data:
    %     tvdata=netLoadData(:,2:end);
    %     netLoadData_snippet=[netLoadData(:,1) repmat(tvdata(1,:),size(tvdata,1),1)];
    %     loadData_noTS=netLoadData_snippet(:,2:end); % remove timestamp

    figure; plot(netLoadData(:,1),netLoadData(:,2:end)); title(strcat('load data for sim itvl, ',timeStart," to ",timeEnd)); xlabel('seconds'); ylabel('kW or kVAR');
    TVload_start=min(find(diff(netLoadData(:,2))>0))

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
    
%% setup cfg
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
    S=solve(PFset==cos(atan(Q/P)),P^2+Q^2==Sinv^2,[Q,P]);
    pf_P(i)=max(eval(S.P));
    pf_Q(i)=max(eval(S.Q)); % lagging so choose max
end

Options=[1 1]; % [Testing PBC_ctrl]

% read PV data  to get P_TOD
    timevec=[1:600]';
    P_TOD=[timevec (6*21)*ones(length(timevec),length(ctrl_idx)/2)];
    
%% run simulation iterations..


foo=diff(simStartTimes); startItvl=foo(1); % eachsim jumps fwd by this many minutes
for sim_iter=1:3
    %% set_TOD
    mnt_of_day=simStartTimes(sim_iter); 
    hr_min = @(mins) [fix(mins/60) rem(mins,60)]; startTime=hr_min(mnt_of_day);
    d=[];
    for i=1:2
        foo=num2str(startTime(i)); 
        if length(foo)==1
            foo=strcat('0',foo);
        end
        d=strcat(d,foo," ");
    end
    start_str = datestr(datetime(d,'InputFormat','hh mm '))
    minStart=mnt_of_day; minEnd=mnt_of_day+simDur;

    %% set_loaddata
    n=295; % for each feeder, the number of cols in TV load/gen data (including time col), which is number of nodes*phases
    st=1+(sim_iter-1)*startItvl*60; 
    netLoadData_snippet=netLoadData(st:st+simDur*60,:);
    figure; plot(netLoadData_snippet(:,1),netLoadData_snippet(:,2:end)); title(strcat('load data starting at',start_str(end-7:end-3))); xlabel('seconds'); ylabel('kW or kVAR');

    %% set_phTargets

    [Sbase,V1base,V2base] = computePU(); 
    perf_Vbase=V1base; % node 10 on primary side

    [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target_fullDay(sim_iter,sim_iter+simDur,Sbase,meas_idx,measStr,controlLoopAlign,test_num,num_tarSets); 

    %% set_kgains
    if Vmag_ctrl==true
        scale([1:7,18:20])=0.2;
        load(strcat('kgains/kgains_test',num2str(test_num),'_09-18.mat')); % gives us "kgains"
        scale(1)=0.3; scale(2)=0.2; scale(5)=0.2; scale(7)=0.4; scale(18:19)=0.2; % modifier, ideally would be 1
        scale(19)=0.3; % derate to avoid instability 
        scale(5)=0.3
        Fbar=scale(test_num)*Fbar_kgain_mid/5; % div by 5 because ephasorsim has 5s lag compared to linsim (see 'results 2' page in OneNote) 

        assert(size(controlLoopAlign,1)==size(Fbar,1))
        blk_1=size(Fbar,1)/2; blk_2=size(Fbar,2)/2;
        F11=1*Fbar(1:blk_1,1:blk_2);
        F21=1*Fbar(blk_1+1:end,1:blk_2); 
        F12=Fbar(1:blk_1,blk_2+1:end);
        F22=Fbar(blk_1+1:end,blk_2+1:end);
        %     Turn controllers off  
        sz1=length(ctrl_idx); sz2=length(unique(meas_idx,'stable'));
        F11=zeros(sz1/2,sz2); F12=F11; F21=F11; F22=F11;
        
        ctrl_start_lag=10; % time after tv load/gen begins to start controllers
        Vmag_ctrlStart=TVload_start+ctrl_start_lag; % check load data to see when stops being constant
        Vang_ctrlStart=TVload_start+ctrl_start_lag; 

    else
         Vang_ctrlStart = 0; % wait until after interval over which you tuned controller
         Vmag_ctrlStart = 0; % in seconds, time for turning on controllers
    end
    
    %% set disturbances
    
        loadData_noTS=netLoadData_snippet(TVload_start:end,2:end); % remove timestamp
         n=length(dbc_idx); Pidx=1:2:n-1; Qidx=2:2:n;
         actualDbcData =createActualDbc(0*loadData_noTS(:,dbc_idx(Pidx)),0*loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv, netLoadData,r);
         %actualDbcData =createActualDbc(loadData_noTS(:,dbc_idx(Pidx)),loadData_noTS(:,dbc_idx(Qidx)),Ts,dbc_idx,Sinv, netLoadData,r);     
        % save('dbcData_sunny2','actualDbcData');

         %actualDbcData(:,2:end)=0.7*actualDbcData(:,2:end);
        pload=loadData_noTS(:,dbc_idx(Pidx));
         testDbcData=[[0:Ts:length(pload)]' zeros(length(pload)/Ts+1,length(ctrl_idx))];

        % actualDbcData format = [P...P Q...Q]
       %figure; plot(actualDbcData(:,[2:6,8,11:12,14:15,17:23,25,28:29,31:32,34:35]),'LineWidth',1.5); title('Disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); 
       % figure; plot(testDbcData(1:200/Ts,2:end),'LineWidth',1.5); title('test disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); legend('P','Q');
     %   figure; plot(actualDbcData(:,[2:7]),'LineWidth',1.5); title('Disturbance'); xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('power (kW or kVAR)'); 
        %legend('Pa','Pb','Pc','Qa','Qb','Qc');

        assert(size(testDbcData,1)==size(actualDbcData,1))
    %% run_simulink
        % Options(1)=0; % turnonn rsc constr, notdoing step response tests
        Options(1)=1; % turnoff rsc constr
        % Options(2)=0; %const power factor, not PBC
        Options(2)=1; % PBC

        disp('------------------- Running simulink...');
        set_param('sim123NF_v2', 'StopTime', simDur*60)
        sim('sim123NF_v2.mdl')
        vmag_init_actual=vmag_new(40,:);
        vang_init_actual=vang_new(40,:);
        disp('finished simulink');  

    %% check_settle
%     if not_settle
%         save_non_settle_data
%     end
    %% save_ss_vals
end