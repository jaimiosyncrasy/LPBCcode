function [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=...
    computeK_way3(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,Ts)
    % input: [dvdq ddeldp], each rx1 vectors
    % this func calls PItuner_GA_RT which runs an algo to automatically
    % det kgains for each actuator-phase
    
    Vang_ctrlStart = 5; % 
    Vmag_ctrlStart = 5; % in seconds, time for turning on controllers
     if Vmag_ctrl==false
         Kp_vmag=0; Ki_vmag=0;
     end
     if Vang_ctrl==false
         Kp_vang=0; Ki_vang=0;
     else
         % hardcode for now
        tau=0.1;
        N=10; % horizon
        settleMax=[10 20]; % vmag vang
        OSmax=[0.2 0.1]; % vmag vang

        for i=1:length(dvdq) %for each actuator-phase, det kset={kp ki}
            kset = PItuner_GA_RT(dvdq(i),tau,Ts,settleMax(1),OSmax(1)) % Q-V loop
            Kp_vmag(i)=kset(1); Ki_vmag=kset(2);
            kset = PItuner_GA_RT(ddeldp(i),tau,Ts,settleMax(2),OSmax(2)) % P-del loop
            Kp_vang(i)=kset(1); Ki_vang=kset(2);
        end   
     end
    % Kp_vmag and the others are each rx1 vectors
end