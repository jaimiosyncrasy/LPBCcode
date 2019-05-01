function J = pidtest_RT(Gp,dt,parms,N,settleMax,OSmax)
s = tf('s');
% Create PID controller
% Gc = parms(1) + parms(2)/s + parms(3)*s/(1+.001*s);
disp('----------------------------------');
k_try=[parms(1) parms(2)]
Gc = parms(1) + parms(2)/s; % PI control
Loop = series(Gc,Gp);
ClosedLoop = feedback(Loop,1);

% Simulate
t = 0:dt:N;
[y,t] = step(ClosedLoop,t);
yref=1;
u = lsim(Gc,yref-y,t); % u produced from passing y-yref through Gc

% Build cost func
    % small overshoot, small control effort, and short settle time seem to also
    % provide good stability margins (GM and PM)
R= .01;
Q1=@(t) 0.5*t; % linearly increasing penalty for deviation
devTerm=yref-y(:);
OS=max(max(y(2/dt:end)-yref),0); % start measuring after 2s so have time to rise, outer max is because OS is only for when go above yref
uEffortTerm=u(:);
logBarr=@(z,zref,zMax) (((z-zref)<zMax).*(-(zMax^2)*log10(1-((z-zref)/zMax).^2)) + ((z-zref)>=zMax).*(100));
ssBound=0.05; a=abs(devTerm)<ssBound;
settle=(length(a)-(find(0==flipud(a),1)-2))*dt; % settling time, in seconds
if (isempty(settle) || settle>=settleMax) % case of not settling or settle is beyond settle max
    disp('didnt settle');
    settle=settleMax+0.05
end
settlePen=0.1*logBarr(settle,0,settleMax) % normalize with desired max/actual max
OSPen=100*logBarr(OS,0,OSmax)

optTerms=[sum(devTerm) OS settle sum(uEffortTerm)]
%figure; plot(t,devTerm,t,uEffortTerm,'LineWidth',2); legend('devTerm','uEffortTerm');
J = dt*sum(Q1(t).*(devTerm) + settlePen.*settle + OSPen.*OS+ R*uEffortTerm.^2) 

% Plot controlled sim
figure;
step(ClosedLoop,t)
h = findobj(gcf,'type','line');
set(h,'linewidth',2);
drawnow
%pause