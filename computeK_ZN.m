function [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,...
    Vmag_ctrlStart,Vang_ctrlStart]=computeK_ZN(Vmag_ctrl,Vang_ctrl,k_singlePh,r,Ts)
    % k_singlePh is 4x1 and contains {kp ki kp ki} if only considering one
    % phase. Here we distribute kgains to r phase-actuators
    Vang_ctrlStart = (20+80*r)*Ts; % wait until after interval over which you tuned controller
    Vmag_ctrlStart = (20+80*r)*Ts; % in seconds, time for turning on controllers
     Kmat=zeros(4,r); % dim 4xr, where r is number of phase actuators
      % Here we assign same {kp,ki] to each of r phase-actuators
     % Matrix of controller gains phases are across cols
     Kmat(:,:)=repmat(k_singlePh,1,r); % put scalars into matrix
         Kp_vmag=Kmat(1,:); % row 1
         Ki_vmag=Kmat(2,:);
         Kp_vang=Kmat(3,:);
         Ki_vang=Kmat(4,:);
 
   
    % Kp_vmag and the others are each 1xr vectors
    
    % If controller loop off, zero out kgains
     if Vmag_ctrl==false % % P&Q both work without vmag terms
         Kp_vmag=zeros(1,r); Ki_vmag=zeros(1,r);
     end
     if Vang_ctrl==false % P&Q both work without vang terms
         Kp_vang=zeros(1,r); Ki_vang=zeros(1,r);
     end
end