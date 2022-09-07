clc; clear all; close all;
load('123NF_stepdata_3.18.mat') % save all vars so can load them

%% --------------------- Now ready to compute kgains -------------------------
%   run GA code to compute kgains
    Vang_ctrl=true; % boolean
    Vmag_ctrl=true; % boolean
    %[Kp_vmag,Ki_vmag,Kp_vang,Ki_vang]=afunc(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,dvdp,ddeldq,Ts,r)

  %  lead_idx=[1 4 7 8 9 12]; % to set all kgains for phases of same node equal
    lead_idx=[1 4 7 10 11 14 15 18 19];
    controlLoopAlign(lead_idx,:) % check that first col has all /P1
    assert(max(lead_idx)<size(controlLoopAlign,1)/2);

    % sensitivities are different for different act locs,  so only design kgain for each phase-act:
    scale=1;
    [a_,b_,c_,d_]=afunc(Vmag_ctrl,Vang_ctrl,dvdq(lead_idx)*scale,ddeldp(lead_idx)*scale*0.6,dvdp(lead_idx)*scale,ddeldq(lead_idx)*scale*0.6,Ts,1);
[a_,b_,c_,d_]
    r=length(ctrl_idx)/2; % number of "phase-actuators", div by 2 because each phase actuator has P and Q control so control index has length 2*r
    scale2=0.05; 
    assert(length(lead_idx)==length(a_));
%%
    j=0;
    for i=1:size(controlLoopAlign,1)/2
        if any(ismember(lead_idx,i))
            j=j+1; % increment counter
        end
        Kp_vmag(i)=a_(j)*0; 
        Ki_vmag(i)=b_(j)*(scale2); 
        Kp_vang(i)=c_(j)*0;
        Ki_vang(i)=d_(j)*(scale2);
    end

%[Kp_vmag(1) Ki_vmag(1) Kp_vang(1) Ki_vang(1)]
[Ki_vmag dvdq*1000]
%% load kgains from file
  %  load('ecoblock_kgains_12.2.mat'); % gives us "kgains"
    load('simLPBC1_wrsc_12.12.mat','kgains','scale2'); % gives us "kgains"
    Kp_vmag=kgains(:,1)
    Ki_vmag=kgains(:,2)
    Kp_vang=kgains(:,3)
    Ki_vang=kgains(:,4)

%% modify tuning so that community battery actuates more than others
kgains=[Kp_vmag Ki_vmag Kp_vang Ki_vang];
 Kp_vmag(4:6)=kgains(1,1)*3;
 Ki_vmag([1:3,7:end])=kgains(1,2)*0.9;
 Kp_vang([1:3,7:end])=kgains(1,3)*0.9;
 Ki_vang([1:3,7:end])=kgains(1,4)*0.9;
 
%  Kp_vmag=0;
%  Ki_vmag=0;
%  Kp_vang=0;
%  Ki_vang=0;

% save('ecoblock_kgains_test2_12.6.mat','Kp_vmag','Ki_vmag','Kp_vang','Ki_vang');
 Kp_vmag=Kp_vmag*(1/3);
 Ki_vmag=Ki_vmag*(1/3);
 Kp_vang=Kp_vang*(1/3);
 Ki_vang=Ki_vang*(1/3);
 

%% --------------------- Controller kgains are now set -------------------------
  
%% Create power disturbance for controlled sim %comment out for 2.1 tests 
    % define disturbance directly in this function below 
   
    ctrl_start_lag=10; % time after tv load/gen begins to start controllers
    maxnum_phAct=21; % get from writing_123NF_pins.m, good config
    %maxnum_phAct=25; % get from writing_123NF_pins.m, bad config
    Vmag_ctrlStart=(5+dbcDur*2*maxnum_phAct)+ctrl_start_lag; % check load data to see when stops being constant
    Vang_ctrlStart=(5+dbcDur*2*maxnum_phAct)+ctrl_start_lag; 

    netLoadData_snippet=netLoadData; % for controlled sim, set load data to be TV from sigbuilder
    loadData_noTS=netLoadData_snippet(:,2:end); % remove timestamp

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


 %%  Run sim with controllers ON
% Options(1)=0; % turnonn rsc constr, notdoing step response tests
Options(1)=1; % turnoff rsc constr
% Options(2)=0; %const power factor, not PBC
Options(2)=1; % PBC

        vmag_init_actual=vmag_new(40,:);
        vang_init_actual=vang_new(40,:);
    disp('------------------- Running controlled sim...');
    % Run simulink
      set_param('sim123NF', 'StopTime', num2str(size(testDbcData,1)))
        sim('sim123NF.mdl')
        disp('finished simulink');    


%% Save results 
    % Run PlotLocalCtrl in command prompt to see results

    % so that results tracking tool can compute performance metrics
    disp('------------------- Outputing results...');
    % save data into .mats
    kgains=[Kp_vmag Ki_vmag Kp_vang Ki_vang];
	%save('OaklandJ_6act_wrsc_1.1.mat','vmag_new','vang_new','pnew','qnew','simTimestamps','vmag_ref_sig','vang_ref_sig','kgains','scale2')
     % to check what you've saved away...
     %clear all; load('simData_001.mat'); whos
     
%% ------------------------- End of Code ----------------------------------
toc % print elapsed sim time
