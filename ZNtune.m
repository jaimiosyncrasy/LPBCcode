function [ZNcritMat,k_singlePh]=ZNtune() 
% change Ku and Tu values in here manually until get desired response
      Ku=9.5; Tu=2.2;% Q>Vmag control
    Kp_vmag = Ku;Ki_vmag=0;Kd_vmag=0; %Proportional only, use to det Ku,Tu  
ZNcritMat(:,1)=[Ku Tu]';
     Ku=0.17; Tu=2.3;% P>Vang control
    Kp_vang = Ku;Ki_vang=0;Kd_vang=0; %Proportional only, use to det Ku,Tu  
ZNcritMat(:,2)=[Ku Tu]';
k_singlePh=[Kp_vmag Ki_vmag Kp_vang Ki_vang]'; %4x1, kgains for single phase-actuator

end 