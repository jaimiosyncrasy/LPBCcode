function [vmag_ref,vang_ref,p_init,q_init,vmag_init_actual, vang_init_actual] = set_UD_targets(minStart,minEnd,Sbase,V1base,V2base)
% Set user-defined targets for step response
% Because ZN method assumes the process is LTI (finding critical gain Ku),
% the emag of the setpoit change to det Ku shouldnt matter, i.e. different
% size steps should yield the same Ku

Vmag_nom=[1 1 1]; % phase, values to settle to at beginning before step response
Vang_nom=[0,-120,120]; % phase, values to settle to at beginning before step response

Vmag_SP_change=0.05; % setpoints up to +- this value
Vang_SP_change=5; % setpoints up to +- this value

% Setpoints are chosen randomly within realistic ranges
     numTarget=minEnd-minStart; % assuming 1 target per minute
     a_mag=repmat(Vmag_nom-Vmag_SP_change,numTarget,1)+(repmat(2*Vmag_SP_change,numTarget,3).*rand(numTarget,3));
     a_ang=repmat(Vang_nom-Vang_SP_change,numTarget,1)+(repmat(2*Vang_SP_change,numTarget,3).*rand(numTarget,3));

% convert connect-the-dot TV data to step signal (minute-wise)
    numDup=2; % duplicate each set of targets 2 times to create each "step"
    a=kron([0:60:(minEnd-minStart)*60]',ones(numDup,1));
    b=[Vang_nom;kron(a_ang,ones(numDup,1))];
    vang_ref=[a(1:end-1),b];
    vang_ref(2:2:end,1)=vang_ref(2:2:end,1)+1; % for first col (timestamp), make 0 0 60 60 into 0 1 60 61

    a=kron([0:60:(minEnd-minStart)*60]',ones(numDup,1));
    b=[Vmag_nom;kron(a_mag,ones(numDup,1))];
    vmag_ref=[a(1:end-1),b];
    vmag_ref(2:2:end,1)=vmag_ref(2:2:end,1)+1; % for first col (timestamp), make 0 0 60 60 into 0 1 60 61


% Aodd = A(1:2:end);          % Odd-Indexed ElementsAodd = A(1:2:end);          % Odd-Indexed Elements
%  numDup=2; % duplicate each set of targets 2 times to create each "step"
%   vang_ref=[[0:60:(minEnd-minStart)*60]',kron([Vang_nom;a_ang],ones(numDup,1))]
%  vmag_ref=[[0:60:(minEnd-minStart)*60]',kron([Vmag_nom;a_mag],ones(numDup,1))]
% 
%             % convert connect-the-dot TV data to step signal
%         a=[vang_ref(:,1)+59,vang_ref(:,2:4)];b=[];
%         for i=(1:minEnd-minStart+1)
%             b=[b; vang_ref(i,:);a(i,:)];
%         end
%         vang_ref=b;
%         a=[vmag_ref(:,1)+59,vmag_ref(:,2:4)];b=[];
%         for i=(1:minEnd-minStart+1)
%             b=[b; vmag_ref(i,:);a(i,:)];
%         end
%         vmag_ref=b;

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

