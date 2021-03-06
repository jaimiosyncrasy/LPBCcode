% computeK_way3
% (Vmag_ctrl,Vang_ctrl,sens,Ts,r)
% close all
% Vmag_ctrl=true;
% Vang_ctrl=true;
% dt=0.1;
% r=3;
% dvdq=-[0.1 0.15]; ddeldp=-[16 18]; % diag terms
% dvdp=[0.1 0.1]; ddeldq=[8 9]; % cross terms
% %dvdp=0.3*dvdq; ddeldq=0.3*ddeldp; % cross terms

%-------------------------------------------------------
% START of func
function [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang]=...
    computeK_way3(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,dvdp,ddeldq,dt,r)

     % hardcode for now
    tau=0.3*dt; % first order TF time const for plant model
    OSmax=[0.1 0.15]; % percentage, vmag vang
    stepMag=[0.05 5]; % hardcoded, TEMP, realistic voltage disturbance mags
    popsize =8; % # candidates per generation
    MaxGenerations = 6; % # generations    
    settleMax=[150*dt 150*dt]; % vmag vang, units of seconds
    N=300*dt; % horizon, in seconds
    
options = gaoptimset('PopulationSize',popsize,'Generations',MaxGenerations);
    
    if Vmag_ctrl~=Vang_ctrl
        error('Vmag_ctrl and Vang_ctrl must be both true or both false because way 3 considers MIMO plant model');
    end
    if Vmag_ctrl==false
        Kp_vmag=zeros(r,1);
        Ki_vmag=zeros(r,1);
        Kp_vang=zeros(r,1);
        Ki_vang=zeros(r,1);
    else 
        %m1=0.05;
        m1=0; % if set to zero, param space includes zero (filled box)
        m2=0.7*exp(-0.3*dt); % for small timesteps approaches 0.7, for large timesteps decays to zero (want smaller gains for delayed controllers)
        for i =1:length(dvdq) % for each phase-actuator
             % allowable range of kgains, vmag first 2 col, vang 2nd 2 cols
            a=sort([m1*(1/dvdq(i)) m2*(1/dvdq(i))]);
             b=sort([m1*(1/ddeldp(i)) m2*(1/ddeldp(i))]);
             lb=[a(1) a(1) b(1) b(1)]
             ub=[a(2) a(2) b(2) b(2)]
%              lb=[a(1) 0 0 0]
%              ub=[a(2) 0 0 0]

            % create all 4 open-loop TFs. The ss and tau have meaning in CT
            % model, so must convert to discrete AFTER
            H11=c2d(tf([dvdq(i)],[tau 1]),dt);
            H12=c2d(tf([dvdp(i)],[tau 1]),dt);
            H21=c2d(tf([ddeldq(i)],[tau 1]),dt); 
            H22=c2d(tf([ddeldp(i)],[tau 1]),dt);
            Hmat=[H11 H12; H21 H22];

            plot=false; % dont plot while autotuning, unless debugging
            nvars=length(lb)
            [kset,fval,exitflag,output,population,scores] = ga(@(K)bfunc(Hmat,dt,K,N,settleMax,OSmax,stepMag,plot),nvars,[],[],[],[],lb,ub,[],options);
            % check statement

            disp('-------- Best -----------------------------');
            plot=true; % plot only best controller
            bfunc(Hmat,dt,kset,N,settleMax,OSmax,stepMag,plot); 
            %pause

            Kp_vmag(i)=kset(1); Ki_vmag(i)=kset(2); Kp_vang(i)=kset(3); Ki_vang(i)=kset(4); 
             data=[...
            [ub(1) Kp_vmag(i) lb(1)]'...
            [ub(1) Ki_vmag(i) lb(1)]'...
            [ub(3) Kp_vang(i) lb(3)]'...
            [ub(3) Ki_vang(i) lb(3)]'];
            rowhead = strcat('ub',sprintf(' phase-act%d ', 1:size(data,1)-2),' lb');
            printmat(data,'Kgains with param space bounds',rowhead,'Kp_vmag Ki_vmag Kp_vang Ki_vang');
        end
    end
