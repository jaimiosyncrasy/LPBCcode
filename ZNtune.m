function [ZNcritMat,Kp_vmag,Ki_vmag,Kp_vang,Ki_vang]=ZNtune()   
      Ku=9.5; Tu=2.2;% Q>Vmag control
    Kp_vmag = Ku;Ki_vmag=0;Kd_vmag=0; %Proportional only, use to det Ku,Tu  
ZNcritMat(:,1)=[Ku Tu]';
     Ku=0.17; Tu=2.3;% P>Vang control
    Kp_vang = Ku;Ki_vang=0;Kd_vang=0; %Proportional only, use to det Ku,Tu  
ZNcritMat(:,2)=[Ku Tu]';
% ZNcritMat=[Ku_vmag Ku_vang; Tu_vmag Tu_vang];
end