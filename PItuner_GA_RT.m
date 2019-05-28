function kset = PItuner_GA_RT(sens,tau,dt,settleMax,OSmax,stepMag)
    popsize =10; % # candidates per generation
    MaxGenerations = 7; % # generations
    s = tf('s');
    %G = 1/(s*(s*s+s+1)); % plant you're controlling
    G = sens/(tau*s+1); % constant, no dynamics
    N=10; % horizon
    rng(1,'twister') % control random number generation, for reproducibility
    startPop=[-5; 5]; % bounds of starting params
    % use gaoptimset instead of optimoptions, weird error occurs
    options = gaoptimset('PopulationSize',popsize,'Generations',MaxGenerations,'PopInitRange',startPop);
    plot=false; % dont plot while tuning
    [kset,fval,exitflag,output,population,scores] = ga(@(K)pidtest_RT(G,dt,K,N,settleMax,OSmax,stepMag,plot),2,-eye(2),zeros(2,1),[],[],[],[],[],options);

    disp('-------- Best -----------------------------');
    plot=true; % plot best controller
    pidtest_RT(G,dt,kset,N,settleMax,OSmax,stepMag,plot); title(strcat('PItuner: CL step resp, BEST kset=',num2str(kset)));
end