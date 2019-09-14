function [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target(minStart,minEnd,Sbase,meas_idx) 
    % be careful: when multiple actuators on the same phase the targets are
    % repeated so dont assign them to different values, this will cause
    % instability in all cases

    secList=[1:(minEnd-minStart)*60]'; % starts from 1, not actual second of the day
    x=[0.96 0.97 0.98 0.99 1 1.01 1.02 1.03 1.04];
    a=randi(length(x),length(meas_idx));
    tarVmag=x(diag(a));
    %tarVmag=[0.99 1.01 1 0.99 1.01 1 0.99];
    Vmag_nom=ones(1,length(meas_idx));
  
    %tarVang=[-3 -120-3 120-3 -3 -120-3 120-3 -3]; % degrees
    tarVang=[-3 -120-3 120-3 -120+3 -120+3 1 -3 -120-3 120-3 -3 -120-3 120-3 120-3]; % degrees
    %tarVang=[-2 -120-2 120-2]; % degrees
    vang_ref=[secList, repmat(tarVang,length(secList),1)];
    vmag_ref=[secList, repmat(tarVmag,length(secList),1)];
%% initialization step for that first time run RT lab initialize voltages to be steady state values
  %Vang_nom=[0 -120 120 0 -120 120 0];
   Vang_nom=[0,-120,120,-120,-120,0,0,-120,120,0,-120,120,120]; % phase, values to settle to at beginning before step response
    %Vang_nom=[ 0 -120 120]; % phase, values to settle to at beginning before step response
    if (length(tarVmag)~=length(meas_idx) || length(Vmag_nom)~=length(meas_idx))
        error('phasor target or IC of meas wrong size');
    end
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
