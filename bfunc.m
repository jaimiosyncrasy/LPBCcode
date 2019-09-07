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
	s = tf('s');
	C1=parms(1) + parms(2)/s; % PI control, vmag loop
    C2=parms(3) + parms(4)/s; % PI control, vmag loop

% the OL TF relation dvdq with del loop present:
	Gopen=((1+Hmat(2,2)*C2)*Hmat(1,1)-Hmat(1,2)*Hmat(2,1)*C2)/(1+Hmat(2,2)*C2);
    %Gopen=Hmat(1,1) % without MIMO control
	Gclosed=feedback(series(C1,Gopen),1);
	J1=cfunc(dt,N,Gclosed,C1,settleMax(1),OSmax(1),stepMag(1),plot,parms(1:2))

% the OL TF relation ddeldp with v loop present:
	Gopen=((1+Hmat(1,1)*C1)*Hmat(2,2)-Hmat(1,2)*Hmat(2,1)*C1)/(1+Hmat(1,1)*C1);
    %Gopen=Hmat(2,2) % without MIMO control
    Gclosed=feedback(series(C2,Gopen),1);	
	J2=cfunc(dt,N,Gclosed,C2,settleMax(2),OSmax(2),stepMag(2),plot,parms(3:4))
    Jtot=J1+J2;
end

% these werent correct
    %Gopen=Hmat(1,1)-Hmat(1,2)*C2*feedback(Hmat(2,1),Hmat(2,2)*C2); % feedback(a,b)=a/(1+b)  
    %Gopen=Hmat(2,2)-Hmat(2,1)*C1*feedback(Hmat(1,2),Hmat(1,1)*C1/Hmat(1,2)); % feedback(a,b)=a/(1+b)
