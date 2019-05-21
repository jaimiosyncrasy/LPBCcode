function [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=computeK_ZNplus(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,k_singlePh)
    % Kp_vmag and others are inputed as scalars, but are made to be 1x3
    % vectors for outputting
    Vang_ctrlStart = 5; % 
    Vmag_ctrlStart = 5; % in seconds, time for turning on controllers
    r=size(dvdq,1) % dvdq is dim rx1, where r is the number of phase-actuators
     Kmat=zeros(4,r); 
     
      % Here we assign differnent {kp,ki] to each of r phase-actuators, the
      % difference coming from the scaling sensitivity vectors dvdq and ddeldp
    % -1 is for fixing sign convention
    for i=1:r
        Kmat(:,i)=-[dvdq(i)*k_singlePh(1:2);...
                ddeldp(i)*k_singlePh(3:4)];
    end
    % NEED FIX: multiplying kgains by sensitivity seems too crude to be
    % useful, may need to come up with a modifier close to 1 that is a func
    % of sensitivity, so that the kgain is close to ZN but different on
    % each phase
    
    Kp_vmag=Kmat(1,:); % first row
    Ki_vmag=Kmat(2,:);
    Kp_vang=Kmat(3,:);
    Ki_vang=Kmat(4,:);
    % Kp_vmag and the others are each 1x3 vectors
    
        % If controller loop off, zero out kgains
     if Vmag_ctrl==false
         Kp_vmag=zeros(1,r); Ki_vmag=zeros(1,r);
     end
     if Vang_ctrl==false
         Kp_vang=zeros(1,r); Ki_vang=zeros(1,r);
     end
end