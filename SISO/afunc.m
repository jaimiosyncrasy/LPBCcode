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
function [Kp_vmag,Ki_vmag,Kp_vang,Ki_vang,Vmag_ctrlStart,Vang_ctrlStart]=...
    computeK_way3(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,dvdp,ddeldq,dt,r)


    Vang_ctrlStart = 5; % 
    Vmag_ctrlStart = 5; % in seconds, time for turning on controllers

     % hardcode for now
    tau=0.3*dt; % first order TF time const for plant model
    settleMax=[15 15]; % vmag vang, units of seconds
    OSmax=[0.5 0.2]; % percentage, vmag vang
    stepMag=[0.05 5]; % hardcoded, TEMP, realistic voltage disturbance mags
    popsize =8; % # candidates per generation
    MaxGenerations = 6; % # generations
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
        m1=0.05;
        m2=1;
        for i =1:length(dvdq) % for each phase-actuator
             % allowable range of kgains, vmag first 2 col, vang 2nd 2 cols
            a=sort([m1*(1/dvdq(i)) m2*(1/dvdq(i))]);
             b=sort([m1*(1/ddeldp(i)) m2*(1/ddeldp(i))]);
            lb=[a(1) a(1) b(1) b(1)]
            ub=[a(2) a(2) b(2) b(2)]
            N=30; % horizon, in seconds

            % create all 4 open-loop TFs
            H11=tf([dvdq(i)],[tau 1]);
            H12=tf([dvdp(i)],[tau 1]);
            H21=tf([ddeldq(i)],[tau 1]); 
            H22=tf([ddeldp(i)],[tau 1]);
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
