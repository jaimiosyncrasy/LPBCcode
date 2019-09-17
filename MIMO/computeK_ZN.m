function [Kpq_vmag,Kiq_vmag,Kpq_vang,Kiq_vang,Kpp_vmag,Kip_vmag,Kpp_vang,Kip_vang,...
    Vmag_ctrlStart,Vang_ctrlStart]=computeK_ZN(Vmag_ctrl,Vang_ctrl,k_singlePh,r)
    % k_singlePh is 4x1 and contains {kp ki kp ki} if only considering one
    % phase. Here we distribute kgains to r phase-actuators
    Vang_ctrlStart = 5; % 
    Vmag_ctrlStart = 5; % in seconds, time for turning on controllers
     Kmat=zeros(8,r); % dim 4xr, where r is number of phase actuators
      % Here we assign same {kp,ki] to each of r phase-actuators
     % Matrix of controller gains phases are across cols
     Kmat(:,:)=repmat(k_singlePh,1,r); % put scalars into matrix
         Kpp_vmag=Kmat(1,:); % row 1
         Kip_vmag=Kmat(2,:);
         Kiq_vmag=Kmat(3,:);
         Kpq_vmag=Kmat(4,:);
         Kpp_vang=Kmat(5,:);
         Kip_vang=Kmat(6,:);
         Kiq_vang=Kmat(7,:);
         Kpq_vang=Kmat(8,:);
   
    % Kp_vmag and the others are each 1xr vectors
    
    % If controller loop off, zero out kgains
     if Vmag_ctrl==false % % P&Q both work without vmag terms
         Kpp_vmag=zeros(1,r); Kip_vmag=zeros(1,r);
         Kpq_vmag=zeros(1,r); Kiq_vmag=zeros(1,r);
     end
     if Vang_ctrl==false % P&Q both work without vang terms
         Kpp_vang=zeros(1,r); Kip_vang=zeros(1,r);
         Kpq_vang=zeros(1,r); Kiq_vang=zeros(1,r);
     end
end