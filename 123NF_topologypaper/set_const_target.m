function [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target(minStart,minEnd,Sbase,meas_idx,measStr,test_num) 
    % be careful: when multiple actuators on the same phase the targets are
    % repeated so dont assign them to different values, this will cause
    % instability in all cases

    % Load targets from SPBC:
    [tarVmag,tarVang,Vang_nom] = process_targets(minStart,measStr,meas_idx,test_num)
    secList=[1:(minEnd-minStart)*60]'; % starts from 1, not actual second of the 
	
    Vmag_nom=ones(1,length(meas_idx));
   assert(all(abs(Vmag_nom-tarVmag)<0.3),'nominal tracking error and vmag target z.0.3Vpu apart') % tracking error shouldstart out less tahn 5 degrees
   assert(all(abs(Vang_nom-tarVang)<10),'nominal tracking error and vang target >5 degrees apart') % tracking error shouldstart out less tahn 5 degrees

    vang_ref=[secList, repmat(tarVang,length(secList),1)];
    vmag_ref=[secList, repmat(tarVmag,length(secList),1)];
    

%% initialization step for that first time run RT lab initialize voltages to be steady state values

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
   q_init=[110/(Sbase/1000) 90/(Sbase/1000) 90/(Sbase/1000)]; % set equal to init cond in excel file, needed for IC of delay block
   p_init=[160/(Sbase/1000) 120/(Sbase/1000) 120/(Sbase/1000)];  % set equal to init cond in excel file, needed for IC of delay block

    
end
