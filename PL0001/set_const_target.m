function [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target(minStart,minEnd,Sbase,meas_idx) 
    % be careful: when multiple actuators on the same phase the targets are
    % repeated so dont assign them to different values, this will cause
    % instability in all cases

    secList=[1:(minEnd-minStart)*60]'; % starts from 1, not actual second of the day
%     a=randi(length(x),length(meas_idx));
%     tarVmag=x(diag(a));
   %   tarVmag=[0.99 1.01 1 0.99 1.01 1 0.99]; % mult Act sim
   % tarVmag=[0.99 1.01 1 1 1.01 1.02 0.98 0.99 1]; % full day sim
    %vmag_3ph=[0.97 0.98 0.99];
    %tarVmag=repmat(vmag_3ph,1,13); % 10 act for 1 perf node
    %tarVmag([9,13,26])=[]; %  10 act for 1 perf node,non-3ph perf nodes
    %tarVmag=[0.97        0.98        0.97        0.98        0.99        0.97        0.98        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.97        0.98        0.97        0.98        0.99        0.97        0.98        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.99]; %  10 act for 1 perf node,non-3ph perf nodes
    tarVmag=[0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.97        0.98        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.99];

    %tarVmag=[0.9 0.9];
    %tarVmag=[0.97 0.98 0.99];
    %tarVmag=[0.99 1.01 1 0.99 1.01 1 0.99 1 1.01 0.99 1 1.01 1];
    
    Vmag_nom=ones(1,length(meas_idx));
 %tarVang=[-3 -120-3 120-3 -3 -120-3 120-3 -3]; % mulAct sim
  %  tarVang=[-2 -120-2 120-2 -1 -120-1 120-1 1 -120+1 120+1]; % full day
   
 %    tarVang=[-3 -120-3 120-3 -120-3 -3 -1 -120-1 120-1 ]; % degrees
    %tarVang=[-3 -120-3 120-3 -120 -120 1 -2 -120-2 120-2 -1 -120-1 120-1]; % degrees
  %vang_3ph=[0-2 -120-2 120+2]; % degrees%
  %tarVang=repmat(vang_3ph,1,13); % 10 act for 1 perf node
  %tarVang([9,13,26])=[]; % 10 act for 1 perf node,non-3ph perf nodes
  %tarVang=[0-2 -120-2 120+2];
    tarVang=[-2 -122  122 -122  122   -2 -122  122   -2 -122  122   -2 -122  122   -2 -122   -2 -122  122   -2 -122   -2 -122  122   -2 -122  122   -2 -122  122 -122  122   -2  122]; %tarVang=[-3 -125 116];
  %  tarVang=[-3 -130]; % degrees

  % tarVang=[0-2 +120-2 -120+2]; % ONLY for AL0001 (b and c nom swapped)

    vang_ref=[secList, repmat(tarVang,length(secList),1)];
    vmag_ref=[secList, repmat(tarVmag,length(secList),1)];
%% initialization step for that first time run RT lab initialize voltages to be steady state values
  % Vang_nom=[0 -120 120 0 -120 120 0]; % mult act sim

   % Vang_nom=[0 -120 120 -120 0 0 -120 120];

  %Vang_nom=repmat([0 -120 120],1,10);
  %Vang_nom([9,13,26])=[]; % 10 act for 1 perf node,non-3ph perf nodes
  %Vang_nom=[0 -120 120];
  Vang_nom=[0 -120  120 -120  120    0 -120  120    0 -120  120    0 -120  120    0 -120    0 -120  120    0 -120    0 -120  120    0 -120  120    0 -120  120 -120  120    0  120];

  % Vang_nom=[0,-120,120,-120,-120,0,0,-120,120,0,-120,120]; % phase, values to settle to at beginning before step response
   % Vang_nom=[ 0 -120 1200 -120 120 0 -120 120]; % full day sim
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
