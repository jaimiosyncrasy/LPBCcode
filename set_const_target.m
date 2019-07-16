function [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target(minStart,minEnd,Sbase,V1base) 
    secList=[1:(minEnd-minStart)*60]'; % starts from 1, not actual second of the day
    tarVmag=[0.975 0.975 0.975]; % pu
    tarVang=[-2.4 -120-2.4 120-2.4]; % degrees
    vang_ref=[secList, repmat(tarVang,length(secList),1)];
    vmag_ref=[secList, repmat(tarVmag,length(secList),1)];
%% initialization step for that first time run RT lab initialize voltages to be steady state values
    Vmag_nom=[1 1 1]; % phase, values to settle to at beginning before step response
    Vang_nom=[0,-120,120]; % phase, values to settle to at beginning before step response
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
