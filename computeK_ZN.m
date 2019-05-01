function [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=computeK_ZN(Vmag_ctrl,Vang_ctrl,Kp_vmag,Ki_vmag,Kp_vang,Ki_vang)
    % Kp_vmag and others are inputed as scalars, but are made to be 1x3
    % vectors for outputting
    Vang_ctrlStart = 5; % 
    Vmag_ctrlStart = 5; % in seconds, time for turning on controllers
     Kmat=zeros(4,3); 
     if Vmag_ctrl==false
         Kp_vmag=0; Ki_vmag=0;
     end
     if Vang_ctrl==false
         Kp_vang=0; Ki_vang=0;
     end
      % Here we assign same {kp,ki] to each of 3 phases
     % Matrix of controller gains phases are across cols
     Kmat(:,:)=repmat([Kp_vmag Ki_vmag Kp_vang Ki_vang]',1,3); % put scalars into matrix

     Kp_vmag=Kmat(1,:);
    Ki_vmag=Kmat(2,:);
    Kp_vang=Kmat(3,:);
    Ki_vang=Kmat(4,:);
    % Kp_vmag and the others are each 1x3 vectors
end