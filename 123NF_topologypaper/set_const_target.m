function [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual]  = set_const_target(minStart,minEnd,Sbase,meas_idx,measStr) 
    % be careful: when multiple actuators on the same phase the targets are
    % repeated so dont assign them to different values, this will cause
    % instability in all cases

    % Load targets from SPBC:
%      time=1; % choose the timestep for pulling phasor targets
%     [OPFsoln,header,raw]=xlsread('SPBC_tar_phbal_2.csv');  
%     OPFvmag=OPFsoln(time,2:2:end); % vmag
%     zeroPad_idx=find(abs(OPFvmag-0)<0.01); % delete off zero padding based on when vmag_tar=0
%     OPFvmag(zeroPad_idx)=[]; % delete off
%     OPFvang=OPFsoln(time,3:2:end); % vang
%     OPFvang(zeroPad_idx)=[]; % delete off
%     tarVmag=OPFvmag(meas_idx) % extract targets of perf nodes
%     tarVang=OPFvang(meas_idx)
    [tarVmag,tarVang] = process_targets(minStart,measStr,meas_idx)

    secList=[1:(minEnd-minStart)*60]'; % starts from 1, not actual second of the day
%     a=randi(length(x),length(meas_idx));
%     tarVmag=x(diag(a));
   %   tarVmag=[0.99 1.01 1 0.99 1.01 1 0.99]; % mult Act sim
   % tarVmag=[0.99 1.01 1 1 1.01 1.02 0.98 0.99 1]; % full day sim
   % vmag_3ph=[0.97 0.98 0.99];
    %tarVmag=repmat(vmag_3ph,1,1); % 10 act for 1 perf node
    %tarVmag([9,13,26])=[]; %  10 act for 1 perf node,non-3ph perf nodes
    %tarVmag=[0.97        0.98        0.97        0.98        0.99        0.97        0.98        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.97        0.98        0.97        0.98        0.99        0.97        0.98        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.99]; %  10 act for 1 perf node,non-3ph perf nodes
    
    % many actuator one
    %tarVmag=[0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.97        0.98        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.98        0.99        0.97        0.98        0.99        0.97        0.98        0.99        0.97        0.99];

    %tarVmag=[1.01 0.98 0.99];
    %tarVmag=[0.991 0.991 0.991 0.996 0.996 0.996 0.979 0.976 0.976 0.976 0.976 0.956 0.956 0.956];
    %tarVmag=[0.99 1.01 1];
    Vmag_nom=ones(1,length(meas_idx));
   assert(all(abs(Vmag_nom-tarVmag)<0.3),'nominal tracking error and vmag target z.0.3Vpu apart') % tracking error shouldstart out less tahn 5 degrees

 %tarVang=[-3 -120-3 120-3 -3 -120-3 120-3 -3]; % mulAct sim
  %  tarVang=[-2 -120-2 120-2 -1 -120-1 120-1 1 -120+1 120+1]; % full day
 %    tarVang=[-3 -120-3 120-3 -120-3 -3 -1 -120-1 120-1 ]; % degrees
    %tarVang=[-3 -120-3 120-3 -120 -120 1 -2 -120-2 120-2 -1 -120-1 120-1]; % degrees
    roundTo=[0 -120 120];
   Vang_nom = interp1(roundTo,roundTo,tarVang,'nearest')

  %tarVang=[-0.05 -120.05 119.95];
   assert(all(abs(Vang_nom-tarVang)<5),'nominal tracking error and vang target >5 degrees apart') % tracking error shouldstart out less tahn 5 degrees
  %tarVang([9,13,26])=[]; % 10 act for 1 perf node,non-3ph perf nodes
  %tarVang=[0-2 -120-2 120+2];
  
  % many actuator one
   % tarVang=[-2 -122  122 -122  122   -2 -122  122   -2 -122  122   -2 -122  122   -2 -122   -2 -122  122   -2 -122   -2 -122  122   -2 -122  122   -2 -122  122 -122  122   -2  122]; %tarVang=[-3 -125 116];
    %tarVang=[-1 -121 121]; % T3.3
    %tarVang=-1*ones(1,length(meas_idx)); % T12.3

  % tarVang=[0-2 +120-2 -120+2]; % ONLY for AL0001 (b and c nom swapped)

    vang_ref=[secList, repmat(tarVang,length(secList),1)];
    vmag_ref=[secList, repmat(tarVmag,length(secList),1)];
    

%% initialization step for that first time run RT lab initialize voltages to be steady state values
  % Vang_nom=[0 -120 120 0 -120 120 0]; % mult act sim

   % Vang_nom=[0 -120 120 -120 0 0 -120 120];

  %Vang_nom=repmat([0 -120 120],1,10);
  %Vang_nom([9,13,26])=[]; % 10 act for 1 perf node,non-3ph perf nodes
%  Vang_nom=repmat([0 -120 120],1,length(meas_idx)/3); % HIL convention
 % Vang_nom=[0 -120 120]; % in-silico convention

  %Vang_nom=[0 -120 120 0 -120 120 0 0 0 -120 120 120 0 0 0 0 0 -120 120 0 -120 120 0 -120 -120 120 0]; % test 12

  % many actuator one
  %Vang_nom=[0 -120  120 -120  120    0 -120  120    0 -120  120    0 -120  120    0 -120    0 -120  120    0 -120    0 -120  120    0 -120  120    0 -120  120 -120  120    0  120];

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
   q_init=[110/(Sbase/1000) 90/(Sbase/1000) 90/(Sbase/1000)]; % set equal to init cond in excel file, needed for IC of delay block
   p_init=[160/(Sbase/1000) 120/(Sbase/1000) 120/(Sbase/1000)];  % set equal to init cond in excel file, needed for IC of delay block

    
end
