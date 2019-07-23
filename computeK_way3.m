function [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=...
    computeK_way3(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,Ts)
    % input: [dvdq ddeldp], each rx1 vectors
    % this func calls PItuner_GA_RT which runs an algo to automatically
    % det kgains for each actuator-phase
    
    Vang_ctrlStart = 5; % 
    Vmag_ctrlStart = 5; % in seconds, time for turning on controllers

         % hardcode for now
        tau=0.3; % first order TF time const for plat model
        settleMax=[10 10]; % vmag vang, units of seconds
        OSmax=[0.2 0.1]; % percentage, vmag vang
        stepMag=[0.05 2]; % hardcoded, TEMP, realistic voltage disturbance mags
        %stepMag=[dvdq(1) ddeldp(1)]; % design using a reasonable step change in V/kW
        lbub=[0.1*(1/dvdq(1)) 10*(1/dvdq(1)); 0.1*(1/ddeldp(1)) 10*(1/ddeldp(1))] % allowable range of kgains, vmag first row, vang second row
    
    % If controller loop off, zero out kgains
     if Vmag_ctrl==false
         Kp_vmag=zeros(1,r); Ki_vmag=zeros(1,r);
     else
        for i=1:length(dvdq) %for each actuator-phase, det kset={kp ki}
            kset = PItuner_GA_RT(dvdq(i),tau,Ts,settleMax(1),OSmax(1),stepMag(1),lbub(1,:)); % Q-V loop
            Kp_vmag(i)=kset(1); Ki_vmag(i)=kset(2);
        end 
     end
    % If controller loop off, zero out kgains
     if Vang_ctrl==false
         Kp_vang=zeros(1,r); Ki_vang(i)=zeros(1,r);
     else
        for i=1:length(dvdq) %for each actuator-phase, det kset={kp ki}
             kset = PItuner_GA_RT(ddeldp(i),tau,Ts,settleMax(2),OSmax(2),stepMag(2),lbub(2,:)); % P-del loop
             Kp_vang(i)=kset(1); Ki_vang(i)=kset(2);
        end  
     end
    % Kp_vmag and the others are each rx1 vectors
end