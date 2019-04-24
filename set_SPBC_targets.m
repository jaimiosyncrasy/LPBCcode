function [vmag_ref,vang_ref,p_init,q_init] = set_SPBC_targets(minStart,minEnd,Sbase,V1base,V2base)
    % Load minute-wise targets from SPBC
%     load('1m_expVmag.mat'); % 14x3x1440, Angles
%     load('1m_expVang.mat'); % 14x3x1440, Mags
%     load('1m_expS.mat'); % 3x1x1440, Svalues
    
    load('vtargets_S1_1.mat'); 

% SPBC target data format
    % t is number of targets across sim, p is number of phases of perf node, n is number of nodes
    % V_ang is dim txpxn 
    % V_mag is dim txpxn 
    % V_mag is in PU, with Vbase=2400 volts (for the 13NF circuit)
    % V_ang is in degrees
    
    % Processing of SPBC Data
        vmag_targets675=Mags(9,:,:); % node 671 is 8th index, 675 is 9th
        temp=permute(vmag_targets675,[3 2 1]); % make 1440x3x1
        target_vmag=temp/V1base+0.04; % convert to pu, TEMPORARILY ADD 0.04 for 0.95 to 1.05 RANGE
        vang_targets675=Angles(9,:,:);
        target_vang=permute(vang_targets675,[3 2 1]);
    %     target_vmag=[0 0 0;1 1 1;1 1 1];
    %     target_vang=[0 120 -120; 0 120 -120;0 120 -120];

    % Extract snippet of data across all TV data 
        vang_ref=[[0:60:(minEnd-minStart)*60]',target_vang((minStart+1):(minEnd+1),1:3)] 
        vmag_ref=[[0:60:(minEnd-minStart)*60]',target_vmag((minStart+1):(minEnd+1),1:3)]; 

    % convert connect-the-dot TV data to step signal
        a=[vang_ref(:,1)+59,vang_ref(:,2:4)];b=[];
        for i=(1:minEnd-minStart+1)
            b=[b; vang_ref(i,:);a(i,:)];
        end
        vang_ref=b;
        a=[vmag_ref(:,1)+59,vmag_ref(:,2:4)];b=[];
        for i=(1:minEnd-minStart+1)
            b=[b; vmag_ref(i,:);a(i,:)];
        end
        vmag_ref=b;

        
        
    % Putting in step change for PI offline calc
    % % vmag_step = 0.065; % max change in setpoint across day for vmag
    % % vmag_ref([1,2],2:4)=[0.9772 1.0019 0.9408;0.9772 1.0019 0.9408];
    % % vmag_ref([3,4],2:4)=vmag_ref([1,2],2:4)+vmag_step
    % % 
    % % vang_step = 5.7; % max change in setpoint across day for vang
    % % vang_ref([1,2],2:4)=[-3.5246 -121.2445 116.7068;-3.5246 -121.2445 116.7068];
    % % vang_ref([3,4],2:4)=vang_ref([1,2],2:4)+vang_step

    
%% initialization step for that first time run RT lab initialize voltages to
% be steady state values
    if ((exist('vmag_init_actual')) && (exist('vang_init_actual'))) % if already exists, dont set it to dummy vals
    else
        vmag_init_actual =[[0:60:(minEnd-minStart)*60]',ones(minEnd-minStart+1,3)]; % dummy values the first time you run a sim, 1st sim's purpose is to store vmag_init_actual
        a=[10 -130 130];
        vang_init_actual =[[0:60:(minEnd-minStart)*60]',repmat(a,minEnd-minStart+1,1)]; % dummy values the first time you run a sim, 1st sim's purpose is to store vmag_init_actual
    end

   % Initial Conditions
   q_init=[110/Sbase 90/Sbase 90/Sbase]; % set equal to init cond in excel file, needed for IC of delay block
   p_init=[160/Sbase 120/Sbase 120/Sbase];  % set equal to init cond in excel file, needed for IC of delay block

    
end

