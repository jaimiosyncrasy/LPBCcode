function Jtot=bfunc(Hmat,dt,parms,N,settleMax,OSmax,stepMag,plot)
% pidtest_Rt, pass in Hmat
% pidtest_RT(Hmat,dt,kset,N,settleMax,OSmax,stepMag,plot)
    disp(strcat('numparms=',num2str(numel(parms))));
    if numel(parms)<4
        error('GA unable to sample enough params from lbub');
    end
    % Create PID controller
    disp('----------------------------------');
    k_try=[parms(1) parms(2) parms(3) parms(4)] % [Kp_vmag, Ki_vmag, Kp_vang, Ki_vang]
	% The right way to do, it but, get worse perf
%     z = tf('z',dt);
% 	C1=parms(1) + parms(2)*(dt/(z-1)); % PI control, vmag loop
%     D2=parms(3) + parms(4)*(dt/(z-1)); % PI control, vang loop

    s = tf('s');
	C1=c2d(parms(1) + parms(2)/s,dt); % PI control, vmag loop
    D2=c2d(parms(3) + parms(4)/s,dt); % PI control, vang loop
    
% SISO control, MIMO plant
% the vmag_ref-->vmag relation:
    alpha=Hmat(1,1)*C1; beta=Hmat(1,2)*D2; gamma=Hmat(2,1)*C1/(1+Hmat(2,2)*D2);
    TF_y1r1=feedback(alpha-beta*gamma,1); % alpha-beta*gamma/(1+alpha-beta*gamma);
	J1=cfunc(dt,N,TF_y1r1,C1,settleMax(1),OSmax(1),stepMag(1),plot,parms(1:2))

% the vang_ref-->vang relation:
    alpha=Hmat(2,2)*D2; beta=Hmat(2,1)*C1; gamma=Hmat(1,2)*D2/(1+Hmat(1,1)*C1);
    TF_y2r2=feedback(alpha-beta*gamma,1); % alpha-beta*gamma/(1+alpha-beta*gamma);
	J2=cfunc(dt,N,TF_y2r2,D2,settleMax(2),OSmax(2),stepMag(2),plot,parms(3:4))
    Jtot=J1+J2;
end

% these werent correct
    %Gopen=Hmat(1,1)-Hmat(1,2)*C2*feedback(Hmat(2,1),Hmat(2,2)*C2); % feedback(a,b)=a/(1+b)  
    %Gopen=Hmat(2,2)-Hmat(2,1)*C1*feedback(Hmat(1,2),Hmat(1,1)*C1/Hmat(1,2)); % feedback(a,b)=a/(1+b)
