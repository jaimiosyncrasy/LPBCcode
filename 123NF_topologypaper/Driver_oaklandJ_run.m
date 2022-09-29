clc; clearvars -except test_num; close all;
load(strcat('stepdata/stepdata_test',num2str(test_num),'_9.21.mat')) % save all vars so can load them
%load(strcat('123NF_stepdata_',num2str(test_num),'9.10.mat')) % save all vars so can load them

    Vang_ctrl=true; % boolean
    Vmag_ctrl=true; % boolean
    
%% --------------------- Now ready to compute kgains -------------------------
% %   run GA code to compute kgains
%     %[Kp_vmag,Ki_vmag,Kp_vang,Ki_vang]=afunc(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,dvdp,ddeldq,Ts,r)
% 
%   %  lead_idx=[1 4 7 8 9 12]; % to set all kgains for phases of same node equal
%     lead_idx=[1 4 7 10 11 14 15 18 19];
%     controlLoopAlign(lead_idx,:) % check that first col has all /P1
%     assert(max(lead_idx)<size(controlLoopAlign,1)/2);
% 
%     % sensitivities are different for different act locs,  so only design kgain for each phase-act:
%     scale=1;
%     [a_,b_,c_,d_]=afunc(Vmag_ctrl,Vang_ctrl,dvdq(lead_idx)*scale,ddeldp(lead_idx)*scale*0.6,dvdp(lead_idx)*scale,ddeldq(lead_idx)*scale*0.6,Ts,1);
%     [a_,b_,c_,d_]
%     r=length(ctrl_idx)/2; % number of "phase-actuators", div by 2 because each phase actuator has P and Q control so control index has length 2*r
%     scale2=0.05; 
%     assert(length(lead_idx)==length(a_));

%% load kgains from file
scale=0.45*ones(1,30);
mode=1; % select 1 or 2

if mode==1 % Helou
    load(strcat('kgains_Helou/kgains_test',num2str(test_num),'_09-23.mat')); % gives us "kgains"
    Fbar=1.3*Fbar/5; % scale to 1.3x to show the system is unstable
elseif mode==2
    scale([1:7,18:20])=0.2;
    load(strcat('kgains/kgains_test',num2str(test_num),'_09-18.mat')); % gives us "kgains"
    scale(1)=0.3; scale(2)=0.2; scale(5)=0.2; scale(7)=0.4; scale(18:19)=0.2; % modifier, ideally would be 1
    scale(19)=0.3; % derate to avoid instability 
    scale(5)=0.3
    if test_num<=7 || test_num>17
        Fbar=scale(test_num)*Fbar_kgain_mid/5; % div by 5 because ephasorsim has 5s lag compared to linsim (see 'results 2' page in OneNote) 
    else
        Fbar=scale(test_num)*bestF_asmat/5; 
    end
end
% load(strcat('kgains/kgains_test',num2str(test_num),'_09-21_heatmap.mat')); % gives us "kgains"
%  Fbar=scale(test_num)*bestF_asmat/5; 


 %% assign kgains to F block matrices
    assert(size(controlLoopAlign,1)==size(Fbar,1))
    blk_1=size(Fbar,1)/2; blk_2=size(Fbar,2)/2;
    F11=1*Fbar(1:blk_1,1:blk_2);
    F21=1*Fbar(blk_1+1:end,1:blk_2); 
    F12=Fbar(1:blk_1,blk_2+1:end);
    F22=Fbar(blk_1+1:end,blk_2+1:end);

    % zero out vang control
  % F21=0*F21; F22=0*F22;
   
    % zero out vmag control
    %F11=0*F11; F12=0*F12;
        
% %     Turn controllers off  
%     sz=length(ctrl_idx);
%     F11=zeros(sz/2,sz/2); F12=F11; F21=F11; F22=F11;

%% --------------------- Controller kgains are now set -------------------------
  
%% Create power disturbance for controlled sim %comment out for 2.1 tests 
    % define disturbance directly in this function below 
   
    ctrl_start_lag=10; % time after tv load/gen begins to start controllers
    Vmag_ctrlStart=TVload_start+ctrl_start_lag; % check load data to see when stops being constant
    Vang_ctrlStart=TVload_start+ctrl_start_lag; 

    netLoadData_snippet=netLoadData; % for controlled sim, set load data to be TV from sigbuilder
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

 %%  Run sim with controllers ON
% Options(1)=0; % turnonn rsc constr, notdoing step response tests
Options(1)=1; % turnoff rsc constr
% Options(2)=0; %const power factor, not PBC
Options(2)=1; % PBC

        vmag_init_actual=vmag_new(40,:);
        vang_init_actual=vang_new(40,:);
    disp('------------------- Running controlled sim...');
    % Run simulink
      set_param('sim123NF_v2', 'StopTime', num2str(size(testDbcData,1)))
        sim('sim123NF_v2.mdl')
        disp('finished simulink');    


%% Save results 
    % Run PlotLocalCtrl in command prompt to see results

    % so that results tracking tool can compute performance metrics
    disp('------------------- Outputing results...');
    
    % save data into .mats
	%save(strcat('results/123NF_test',num2str(test_num),'_norsc_9.18.mat'),'vmag_new','vmag_all','vang_new','pnew','qnew','simTimestamps','vmag_ref_sig','vang_ref_sig','Fbar')
 
%% ------------------------- End of Code ----------------------------------
toc % print elapsed sim time
