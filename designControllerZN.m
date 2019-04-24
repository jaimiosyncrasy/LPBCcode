function [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart] = designControllerZN(Vmag_ctrl,Vang_ctrl)

 
   %% Controller Settings
    Vang_ctrlStart = 5; % 
    Vmag_ctrlStart = 5; % in seconds, time for turning on controllers

    %% Choose controller and PID gain constants
    % we use 0.4 and 0.5 for ZN tuning law instead of 0.45 and 0.54 because
    % turning both control loops on at the same time does cause some
    % coupling interference; hence detune slightly
    
    % For actuation node
    if (Vmag_ctrl==true)
      Ku=9.5; Tu=2.2;% Q>Vmag control
    %Kp_vmag = Ku;Ki_vmag=0;Kd_vmag=0; %Proportional only, use to det Ku,Tu  
    Kp_vmag = 0.4*Ku;Ki_vmag=0.5*Ku/Tu;Kd_vmag=0; %PI, ZN method

    else % set all to zero
        Kp_vmag = 0;Ki_vmag=0;Kd_vmag=0; 

    end
    
    if (Vang_ctrl==true)
     Ku=0.17; Tu=2.3;% P>Vang control
    %Kp_vang = Ku;Ki_vang=0;Kd_vang=0; %Proportional only, use to det Ku,Tu  
    Kp_vang = 0.4*Ku;Ki_vang=0.5*Ku/Tu;Kd_vang=0; %PI, ZN method

    else
        Kp_vang = 0;Ki_vang=0;Kd_vang=0; % must tune manually, Simulink PID autotuner cannot linearize the 13-bus model, rule of thumb = 1/n
    end

    %if doing full PID control (not PI control)
    % Kp=0.6*Ku;
    % Ki = 1.2*Ku/Tu; % if set to zero, no integrator
    % Kd = 3*Ku*Tu/40;

 % Above we det kp and ki for two control loops, but each control loop is
 % on 3ph
 % Here we assign same {kp,ki] to each of 3 phases
 % Matrix of controller gains phases are across cols
 Kmat=zeros(4,3); 
 Kmat(:,:)=repmat([Kp_vmag Ki_vmag Kp_vang Ki_vang]',1,3); % put scalars into matrix
 Kp_vmag=Kmat(1,:);
Ki_vmag=Kmat(2,:);
Kp_vang=Kmat(3,:);
Ki_vang=Kmat(4,:);
% each output vec will have only 1 nonzero entry, since controlling 1 phase at a time

