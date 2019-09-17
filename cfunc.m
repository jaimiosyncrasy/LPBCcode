function J = cfunc(dt,N,Gclosed_cont,Cd1_cont,Cd2_cont,settleMax,OSmax,stepMag,YNplot,parms)
    
    % convert CT to DT
    Cd1=c2d(Cd1_cont,dt);
    Cd2=c2d(Cd2_cont,dt);
    Gclosed=c2d(Gclosed_cont,dt);
    
    % Simulate
    t = 0:dt:N;
    opt = stepDataOptions; opt.StepAmplitude = stepMag; % specify your own step amplitude
    [y,t] = step(Gclosed,t,opt); % cause step r as input to Gclosed, then measure output y, which should settle to r
    if (any(isnan(y)) || any(isinf(y)))
        J=10^10; % huge
        disp('output from step of Gclosed is NaN or inf');
    else
        yref=stepMag;
        u = lsim(Cd1,yref-y,t)+lsim(Cd2,yref-y,t); % u produced from passing y-yref through Gc

        % Build cost func
            % small overshoot, small control effort, and short settle time seem to also
            % provide good stability margins (GM and PM)
        R= .01/stepMag; % penalize conttrol effort
        Q1=@(t) 2*t/stepMag; % linearly increasing penalty for deviation
        devTerm=abs(yref-y(:));
        OS=max(max(y(2/dt:end)-yref),0)/stepMag; % start measuring after 2s so have time to rise, outer max is because OS is only for when go above yref
        uEffortTerm=u(:);
        logBarr=@(z,zref,zMax) (((z-zref)<zMax).*(-(zMax^2)*log10(1-((z-zref)/zMax).^2)) + ((z-zref)>=zMax).*(100));
        ssBound=0.1*stepMag; a=abs(devTerm)<ssBound; % 10% error bound
        settle=(length(a)-(find(0==flipud(a),1)-2))*dt; % settling time, in seconds
        if (isempty(settle) || settle>=settleMax) % case of not settling or settle is beyond settle max
            disp('didnt settle');
            settle=settleMax+0.05
        end
        settlePen=15*logBarr(settle,0,settleMax); % normalize with desired max/actual max
        OSPen=100*logBarr(OS,0,OSmax);

        optTerms=[sum(Q1(t).*(devTerm)) settlePen.*settle OSPen.*OS sum(R*uEffortTerm.^2)]
        %figure; plot(t,devTerm,t,uEffortTerm,'LineWidth',2); legend('devTerm','uEffortTerm');
        J = sum(Q1(t).*(devTerm)) + settlePen.*settle + OSPen.*OS+ sum(R*uEffortTerm.^2)

        if (YNplot)
            %Plot controlled sim
            figure;
            [y,t]=step(Gclosed,t,opt);
            plot(t, squeeze(y), [0 N],[stepMag stepMag],'k','LineWidth',2);
    %         h = findobj(gcf,'type','line');
    %         set(h,'linewidth',2); 
            title({'PItuner: CL step resp, of ploop or qloop';strcat('(Kp_{vmag},Ki_{vmag},Kp_{vang},Ki_{vang})=',num2str(parms))});
            %drawnow{'First line';'Second line'}
            
    %pause
        end
    end 
end
