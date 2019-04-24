function [ output_args ] = actLimits( input_args )
    %% Settings for Limits
         % Voltage and Power limits, in pu
         %a=1.05*max(gen_634)/0.9; % for inverter limits block
         %Sinv=max(a(2:4))/500 %1x3, convert to pu, first index is timestep
        Sinv=1.1061; % when considering node 634 generation across the day is 1.1061pu

        [xcirc,ycirc]=circle(0,0,Sinv);
        figure;
        plot(xcirc,ycirc,'k--',[-Sinv,Sinv],[0,0],[0,0],[-Sinv,Sinv],'MarkerSize',20); 
        title('Inv constr'); xlabel('P (pu)'); ylabel('Q (pu)'); grid on; hold on;
        axis([-1.2*Sinv 1.2*Sinv -1.2*Sinv 1.2*Sinv]); 

end

