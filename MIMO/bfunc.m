function Jtot=bfunc(Hmat,Ts,parms,N,settleMax,OSmax,stepMag,plot,Vmag_ctrl,Vang_ctrl)
% pidtest_Rt, pass in Hmat
% pidtest_RT(Hmat,dt,kset,N,settleMax,OSmax,stepMag,plot)
    %disp(strcat('numparms=',num2str(numel(parms))));
    if numel(parms)<8
        error('GA unable to sample enough params from lbub');
    end
    % Create PID controller
    disp('----------------------------------');
    if Vmag_ctrl==false
        parms(1:4)=0;
    end
    if Vang_ctrl==false
        parms(5:8)=0;
    end
    k_try=[parms(1) parms(2) parms(3) parms(4) parms(5) parms(6) parms(7) parms(8)] % [Kp_vmag, Ki_vmag, Kp_vang, Ki_vang]

    s = tf('s'); % must discretize idv TFs before combining!
    C1=c2d(parms(1) + parms(2)/s,Ts); % use Vmag for Q, more coupling
	C2=c2d(parms(3) + parms(4)/s,Ts); % use Vmag for P
    D1=c2d(parms(5) + parms(6)/s,Ts); % use Vang for Q
    D2=c2d(parms(7) + parms(8)/s,Ts); % use Vang for P, more coupling

% MIMO control, MIMO plant
% Qloop:
    alpha=Hmat(1,1)*C1+Hmat(1,2)*D1; beta=Hmat(1,1)*C2+Hmat(1,2)*D2; gamma=(Hmat(2,1)*C1+Hmat(2,2)*D1)/(1+Hmat(2,1)*C2+Hmat(2,2)*D2);
    TF_y1r1=feedback(alpha-beta*gamma,1); % alpha-beta*gamma/(1+alpha-beta*gamma);
	J1=cfunc(Ts,N,TF_y1r1,C1,D1,settleMax(1),OSmax(1),stepMag(1),plot,parms(1:4))

% Ploop:
    alpha=Hmat(2,1)*C2+Hmat(2,2)*D2; beta=Hmat(2,1)*C1+Hmat(2,2)*D1; gamma=(Hmat(1,1)*C2+Hmat(1,2)*D2)/(1+Hmat(1,1)*C1+Hmat(1,2)*D1);
    TF_y2r2=feedback(alpha-beta*gamma,1); % alpha-beta*gamma/(1+alpha-beta*gamma);
	J2=cfunc(Ts,N,TF_y2r2,C2,D2,settleMax(2),OSmax(2),stepMag(2),plot,parms(5:8))
    Jtot=J1+J2;
end

% % For reference...
% % SISO control, MIMO plant
% % the vmag_ref-->vmag relation:
%     alpha=Hmat(1,1)*C1; beta=Hmat(1,2)*D2; gamma=Hmat(2,1)*C1/(1+Hmat(2,2)*D2);
%     TF_y1r1=feedback(alpha-beta*gamma,1); % alpha-beta*gamma/(1+alpha-beta*gamma);
% 	J1=cfunc(Ts,N,TF_y1r1,C1,settleMax(1),OSmax(1),stepMag(1),plot,parms(1:2))
% 
% % the vang_ref-->vang relation:
%     alpha=Hmat(2,2)*D2; beta=Hmat(2,1)*C1; gamma=Hmat(1,2)*D2/(1+Hmat(1,1)*C1);
%     TF_y2r2=feedback(alpha-beta*gamma,1); % alpha-beta*gamma/(1+alpha-beta*gamma);
% 	J2=cfunc(Ts,N,TF_y2r2,D2,settleMax(2),OSmax(2),stepMag(2),plot,parms(3:4))