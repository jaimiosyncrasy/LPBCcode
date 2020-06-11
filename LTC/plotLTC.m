

% LTC params: must be same as parms in simulink block
Vref=[260 260 260]; 
band=3.5/Vref(1); %  in pu, Vbase=Vref
Time=0:length(Vmag_634)-1;
itg_chosen=1200/Vref(1); % same for all 3 phases
a=0.5*10^4; b=0.8*10^4;
%band=(2*0.1)/16
% Plot Vmag
figure;
subplot(3,1,1)
stairs(Time,Vmag_634(:,1),'k')
hold on
grid on
stairs([Time(1) Time(end)],[Vref(1) Vref(1)], 'r')
stairs([Time(1) Time(end)],[Vref(1)-band*Vref(1)*0.5 Vref(1)-band*Vref(1)*0.5], '--r')
stairs([Time(1) Time(end)],[Vref(1)+band*Vref(1)*0.5 Vref(1)+band*Vref(1)*0.5], '--r')
title('V Mag 634 A')
axis([a b 252 265]);

%Plot tap position
subplot(3,1,2)
stairs(Time, Tap_634(:,1))
title('Tap Position 634 A')
grid on
axis([a b -16 16]);

% Plot integrator state
subplot(3,1,3)
stairs(Time,itgrState(:,1), 'm')
title('Integrator state 634 A')
axis([a b 0 1300]);
%% Plot to aid choice of integration threshold constant 
% when integrator state reaches this threshold, change tap and reset
% integrator
figure; hold on;
for itg=[0.02 0.06 0.1 itg_chosen] % sample choices of 'integrator reset value'
dur=0.5:10;
err=itg./dur;
plot(dur,err,'LineWidth',1.5);
end
title('Threshold for tap change'); xlabel('seconds'); ylabel('error pu (V-band)/Vref'); legend('thresh=0.02','thresh=0.06','thresh=0.1','chosen');