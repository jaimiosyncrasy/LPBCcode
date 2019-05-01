function [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=computeK_ZNplus(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,Kp_vmag,Ki_vmag,Kp_vang,Ki_vang)
    % Kp_vmag and others are inputed as scalars, but are made to be 1x3
    % vectors for outputting
    Vang_ctrlStart = 5; % 
    Vmag_ctrlStart = 5; % in seconds, time for turning on controllers
    
     Kmat=zeros(4,3); 
     if Vmag_ctrl==false
         Kp_vmag=0; Ki_vmag=0;
     end
     if Vang_ctrl==false
         Kp_vang=0; Ki_ang=0;
     end
      % Here we assign differnent {kp,ki] to each of 3 phases
     % Matrix of controller gains phases are across cols
    Kmat(:,:)=...
    [dvdq(1)*[Kp_vmag Ki_vmag]' dvdq(2)*[Kp_vmag Ki_vmag]' dvdq(3)*[Kp_vmag Ki_vmag]'...
    ddeldp(1)*[Kp_vmag Ki_vmag]' ddeldp(2)*[Kp_vmag Ki_vmag]' ddeldp(3)*[Kp_vmag Ki_vmag]']
    % TEMP, make more elegant and let Kmat #col=r, not set at 3; r is number of
    % actuation-phases

    Kp_vmag=Kmat(1,:);
    Ki_vmag=Kmat(2,:);
    Kp_vang=Kmat(3,:);
    Ki_vang=Kmat(4,:);
    % Kp_vmag and the others are each 1x3 vectors
end