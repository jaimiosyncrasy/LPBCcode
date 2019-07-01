function J = pidtest_RT(Gp,dt,parms,N,settleMax,OSmax,stepMag,YNplot)
    s = tf('s');
    % Create PID controller
    % Gc = parms(1) + parms(2)/s + parms(3)*s/(1+.001*s);
    disp('----------------------------------');
    k_try=[parms(1) parms(2)]
    Gc_cont = parms(1) + parms(2)/s; % PI control
    Gc=c2d(Gc_cont,dt);
    Loop = series(Gc,Gp); % both are discrete time
    ClosedLoop = feedback(Loop,1);

    % Simulate
    t = 0:dt:N;
    opt = stepDataOptions; opt.StepAmplitude = stepMag; % specify your own step amplitude
    [y,t] = step(ClosedLoop,t,opt);
    yref=stepMag;
    u = lsim(Gc,yref-y,t); % u produced from passing y-yref through Gc

    % Build cost func
        % small overshoot, small control effort, and short settle time seem to also
        % provide good stability margins (GM and PM)
    R= .0005/stepMag;
    Q1=@(t) t/stepMag; % linearly increasing penalty for deviation
    devTerm=yref-y(:);
    OS=max(max(y(2/dt:end)-yref),0)/stepMag; % start measuring after 2s so have time to rise, outer max is because OS is only for when go above yref
    uEffortTerm=u(:);
    logBarr=@(z,zref,zMax) (((z-zref)<zMax).*(-(zMax^2)*log10(1-((z-zref)/zMax).^2)) + ((z-zref)>=zMax).*(100));
    ssBound=0.05*stepMag; a=abs(devTerm)<ssBound;
    settle=(length(a)-(find(0==flipud(a),1)-2))*dt; % settling time, in seconds
    if (isempty(settle) || settle>=settleMax) % case of not settling or settle is beyond settle max
        disp('didnt settle');
        settle=settleMax+0.05
    end
    settlePen=5*logBarr(settle,0,settleMax); % normalize with desired max/actual max
    OSPen=100*logBarr(OS,0,OSmax);

    optTerms=[sum(Q1(t).*(devTerm)) settlePen.*settle OSPen.*OS sum(R*uEffortTerm.^2)];
    %figure; plot(t,devTerm,t,uEffortTerm,'LineWidth',2); legend('devTerm','uEffortTerm');
    J = sum(Q1(t).*(devTerm)) + settlePen.*settle + OSPen.*OS+ sum(R*uEffortTerm.^2)

    if (YNplot)
        %Plot controlled sim
        figure;
        [y,t]=step(ClosedLoop,t,opt);
        plot(t, squeeze(y), [0 N],[stepMag stepMag],'k','LineWidth',2);
%         h = findobj(gcf,'type','line');
%         set(h,'linewidth',2); 
        title('Automatic PItuner: CL step resp with candidate controller');
        %drawnow
        %pause
    end
end