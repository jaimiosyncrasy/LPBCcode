function [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang]=ZNset(ZNcritMat)  
% ZNcritMat=[Ku_vmag Ku_vang; Tu_vmag Tu_vang];
Ku=ZNcritMat(1,1); Tu=ZNcritMat(2,1);
    Kp_vmag = 0.4*Ku;Ki_vmag=0.5*Ku/Tu;Kd_vmag=0; %PI, ZN method
Ku=ZNcritMat(1,2); Tu=ZNcritMat(2,2);
    Kp_vang = 0.4*Ku;Ki_vang=0.5*Ku/Tu;Kd_vang=0; %PI, ZN method
end