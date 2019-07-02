function [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual,a_ang, a_mag] = set_SPBC_targets(minStart,minEnd,Sbase,V1base,V2base,measStr)
% Load minute-wise targets from S-PBC controller
% SPBC target data format
    % t is number of targets across sim, 3 is for max 3 phases on each node (zeros are inserted when a node has less than 3 phases), n is number of nodes
    % V_ang is dim tx3xn 
    % V_mag_pu is dim tx3xn 
    % V_mag_pu is in PU, with Vbase=2400 volts (for the 13NF circuit)
    % V_ang is in degrees
   load('vtargets_2_1_norm03_2_newformat.mat'); % includes phasor targets for all nodes on feeder, so need to isolate the target associated with the perf node
   idx=find(vec_nodes==str2num(measStr(1:3))) % index in SPBC target data for performance node
%    KVbase(isnan(KVbase)) = 0;
%    V_mag_pu = (V_mag_pu.*KVbase)*1000
   a_ang=V_ang(:,:,idx);
   a_mag=V_mag_pu(:,:,idx);

%    a_ang = a_ang.*KVbasevalues(1,:); 
%    a_mag = a_mag.*KVbasevalues(1,:); 
     % a_mag and a_ang are txp vectors
     
    Vmag_nom=[1 1 1]; % phase, values to settle to at beginning before step response
    Vang_nom=[0,-120,120]; % phase, values to settle to at beginning before step response
    
% convert connect-the-dot TV data to step signal (minute-wise)
    numDup=2; % duplicate each set of targets 2 times to create each "step"
    a=kron([0:60:(minEnd-minStart)*60]',ones(numDup,1));
    b=[Vang_nom;kron(a_ang,ones(numDup,1))];
    vang_ref=[a(1:end-1),b];
    vang_ref(2:2:end,1)=vang_ref(2:2:end,1)+1; % for first col (timestamp), make 0 0 60 60 into 0 1 60 61
    %vang_ref = vang_ref.*KVbasevalues(1,:); 
    
    a=kron([0:60:(minEnd-minStart)*60]',ones(numDup,1));
    b=[Vmag_nom;kron(a_mag,ones(numDup,1))];
    vmag_ref=[a(1:end-1),b];
    vmag_ref(2:2:end,1)=vmag_ref(2:2:end,1)+1; % for first col (timestamp), make 0 0 60 60 into 0 1 60 61


    
%% initialization step for that first time run RT lab initialize voltages to
% be steady state values  
   if ((exist('vmag_init_actual')) && (exist('vang_init_actual'))) % if already exists, dont set it to dummy vals
    else
        % dummy values the first time you run a sim, 1st sim's purpose is to store vmag_init_actual
        vmag_init_actual =Vmag_nom;
        vang_init_actual =Vang_nom;
    end

   % Initial Conditions 
   q_init=[110/Sbase 90/Sbase 90/Sbase]; % set equal to init cond in excel file, needed for IC of delay block
   p_init=[160/Sbase 120/Sbase 120/Sbase];  % set equal to init cond in excel file, needed for IC of delay block

    
end

