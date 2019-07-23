function kset = PItuner_GA_RT(sens,tau,dt,settleMax,OSmax,stepMag,lbub)
    popsize =10; % # candidates per generation
    MaxGenerations = 7; % # generations
    
    G=tf([sens],[tau 1]);
    Gd = c2d(G,dt)
    lb=repmat(lbub(1),2,1); % for both kp and ki
    ub=repmat(lbub(2),2,1); % for both kp and ki

    %G = 1/(s*(s*s+s+1)); % plant you're controlling
    N=10; % horizon
    %rng(1,'twister') % control random number generation, for reproducibility
    %startPop=[5; 10] ; % bounds of starting params
    % use gaoptimset instead of optimoptions, weird error occurs
    options = gaoptimset('PopulationSize',popsize,'Generations',MaxGenerations);
      
   %options = gaoptimset('PopulationSize',popsize,'Generations',MaxGenerations,'CreationFcn','gacreationuniform','InitialPopulationRange',[0 10]);
    plot=false; % dont plot while autotuning, unless debugging
    [kset,fval,exitflag,output,population,scores] = ga(@(K)pidtest_RT(Gd,dt,K,N,settleMax,OSmax,stepMag,plot),2,-eye(2),zeros(2,1),[],[],lb,ub,[],options);
    
    disp('-------- Best -----------------------------');
    plot=true; % plot best controller
    pidtest_RT(Gd,dt,kset,N,settleMax,OSmax,stepMag,plot); title(strcat('PItuner: CL step resp, BEST kset=',num2str(kset)));
end