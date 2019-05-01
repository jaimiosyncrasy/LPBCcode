function kset = PItuner_GA_RT(sens,tau,dt,settleMax,OSmax)
% note: running ga func requires global opt toolbox and opt toolbox

popsize = 7; % # candidates per generation
MaxGenerations = 5; % # generations
s = tf('s');
%G = 1/(s*(s*s+s+1)); % plant you're controlling
G = sens/(tau*s+1); % constant, no dynamics
N=10; % horizon

rng(1,'twister') % control random number generation, for reproducibility
startPop=[-10; 10]; % bounds of starting params
options = optimoptions(@ga,'PopulationSize',popsize,'MaxGenerations',MaxGenerations,'PopInitRange',startPop);
[kset,fval,exitflag,output,population,scores] = ga(@(K)pidtest_RT(G,dt,K,N,settleMax,OSmax),2,-eye(2),zeros(2,1),[],[],[],[],[],options);

close all
disp('--------------------------------------');
pidtest(G,dt,kset,N); title('Best step resp');
