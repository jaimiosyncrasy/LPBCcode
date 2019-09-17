function [ZNcritMat,k_singlePh]=ZNtune(V1base, Sbase) 
% change Ku and Tu values in here manually until get desired response
    Ku=14; Tu=2.2; % Q>Vmag control
    %Ku=0.005*3; Tu=1; % Q>Vmag control
    Kpq_vmag = Ku;Kiq_vmag=0; %Proportional only, use to det Ku,Tu  
ZNcritMat(:,1)=[Ku Tu]';
% Ku=0.17
      Ku=0.55; Tu=2; %Ku=0.06; Tu=1.2;% P>Vang control 
      %Ku=0.002*3; Tu=1; %Ku=0.06; Tu=1.2;% P>Vang control 
    Kpp_vang = Ku;Kip_vang=0; %Proportional only, use to det Ku,Tu  
ZNcritMat(:,2)=[Ku Tu]';
    Ku=14; Tu=2.2; % Q>Vmag control
    %Ku=0.005*3; Tu=1; % Q>Vmag control
    Kpp_vmag = Ku;Kip_vmag=0;Kd_vmag=0; %Proportional only, use to det Ku,Tu  
ZNcritMat(:,3)=[Ku Tu]';
% Ku=0.17
      Ku=0.55; Tu=2; %Ku=0.06; Tu=1.2;% P>Vang control 
      %Ku=0.002*3; Tu=1; %Ku=0.06; Tu=1.2;% P>Vang control 
    Kpq_vang = Ku;Kiq_vang=0;Kd_vang=0; %Proportional only, use to det Ku,Tu  
ZNcritMat(:,4)=[Ku Tu]';

k_singlePh=[Kpp_vmag Kip_vmag Kiq_vmag Kpq_vmag Kpp_vang Kip_vang Kiq_vang Kpq_vang]'; %4x1, kgains for single phase-actuator

%T3.1, 5000 Sbase 
end 

% ku=7.25,Tu=2.2;Ku=0.125,Tu=2

%    Ku=4; Tu=2.2; % Q>Vmag control
%      Ku=0.1; Tu=2; %Ku=0.06; Tu=1.2;% P>Vang control 
