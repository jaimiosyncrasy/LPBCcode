% computeK_way3
% (Vmag_ctrl,Vang_ctrl,sens,Ts,r)
% close all
% Vmag_ctrl=true;
% Vang_ctrl=true;
% Ts=0.1;
% r=3;
% dvdq=-[0.1 0.15]; ddeldp=-[16 18]; % diag terms
% dvdp=[0.1 0.1]; ddeldq=[8 9]; % cross terms
% %dvdp=0.3*dvdq; ddeldq=0.3*ddeldp; % cross terms

%-------------------------------------------------------
% START of func
function [Kpq_vmag,Kiq_vmag,Kpq_vang,Kiq_vang,Kpp_vmag,Kip_vmag,Kpp_vang,Kip_vang,...
    Vmag_ctrlStart,Vang_ctrlStart]=...
    computeK_way3(Vmag_ctrl,Vang_ctrl,dvdq,ddeldp,dvdp,ddeldq,Ts,r)


    Vang_ctrlStart = 5; % 
    Vmag_ctrlStart = 5; % in seconds, time for turning on controllers

     % hardcode for now
    tau=0.3*Ts; % first order TF time const for plant model
    settleMax=[15 15]; % vmag vang, units of seconds
    OSmax=[0.15 0.15]; % percentage of stepMag, vmag vang
    stepMag=[0.05 5]; % hardcoded, TEMP, realistic voltage disturbance mags
    popsize =10; % # candidates per generation
    MaxGenerations = 6; % # generations
    options = gaoptimset('PopulationSize',popsize,'Generations',MaxGenerations);
  

    if (Vmag_ctrl==false && Vang_ctrl==false)
         Kpp_vmag=zeros(r,1);
         Kip_vmag=zeros(r,1);
         Kiq_vmag=zeros(r,1);
         Kpq_vmag=zeros(r,1);
         Kpp_vang=zeros(r,1);
         Kip_vang=zeros(r,1);
         Kiq_vang=zeros(r,1);
         Kpq_vang=zeros(r,1);
    else 
        m1=0.05;
        m2=0.5;
        for i =1:length(dvdq) % for each phase-actuator
             % allowable range of kgains, vmag first 2 col, vang 2nd 2 cols
            % qloop
             a=sort([m1*(1/dvdq(i)) m2*(1/dvdq(i))]);
             d=sort([m1*(1/ddeldq(i)) m2*(1/ddeldq(i))]);

             % ploop
             c=sort([m1*(1/dvdp(i)) m2*(1/dvdp(i))]);
             b=sort([m1*(1/ddeldp(i)) m2*(1/ddeldp(i))]);

             lb=[a(1) a(1) d(1) d(1) c(1) c(1) b(1) b(1)]
             ub=[a(2) a(2) d(2) d(2) c(2) c(2) b(2) b(2)]
            N=30; % horizon, in seconds

            % create all 4 open-loop TFs
            H11=c2d(tf([dvdq(i)],[tau 1]),Ts);
            H12=c2d(tf([dvdp(i)],[tau 1]),Ts);
            H21=c2d(tf([ddeldq(i)],[tau 1]),Ts); 
            H22=c2d(tf([ddeldp(i)],[tau 1]),Ts);
            Hmat=[H11 H12; H21 H22];

            plot=false; % dont plot while autotuning, unless debugging
            nvars=length(lb);
            [kset,fval,exitflag,output,population,scores] = ga(@(K)bfunc(Hmat,Ts,K,N,settleMax,OSmax,stepMag,plot,Vmag_ctrl,Vang_ctrl),nvars,[],[],[],[],lb,ub,[],options);
            % check statement

            disp('-------- Best -----------------------------');
            plot=true; % plot only best controller
            bfunc(Hmat,Ts,kset,N,settleMax,OSmax,stepMag,plot,Vmag_ctrl,Vang_ctrl); 
            %pause

% Changes due to MIMO control start here
            % vmag loop P,Q then vang loop P,Q
            Kpq_vmag(i)=kset(1); Kiq_vmag(i)=kset(2); % coupled more
            Kpq_vang(i)=kset(3); Kiq_vang(i)=kset(4);  
            Kpp_vmag(i)=kset(5); Kip_vmag(i)=kset(6); 
            Kpp_vang(i)=kset(7); Kip_vang(i)=kset(8); % coupled more
            
            data=[...
            [ub(1) Kpq_vmag(i) lb(1)]'...
            [ub(1) Kiq_vmag(i) lb(1)]'...
            [ub(2) Kpq_vang(i) lb(2)]'...
            [ub(2) Kiq_vang(i) lb(2)]'...
            [ub(3) Kpp_vmag(i) lb(3)]'...
            [ub(3) Kip_vmag(i) lb(3)]'...
            [ub(4) Kpp_vang(i) lb(4)]'...
            [ub(4) Kip_vang(i) lb(4)]'];
            rowhead = strcat('ub',sprintf(' phase-act%d ', 1:size(data,1)-2),' lb');
            printmat(data,'Kgains with param space bounds',rowhead,'Kpp_vmag Kip_vmag Kpq_vmag Kiq_vmag Kpp_vang Kip_vang Kpq_vang Kiq_vang');
        end
    end
 
