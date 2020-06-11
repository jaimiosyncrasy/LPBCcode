close all
Time=Node634_Vmag_Vang.Time;
V_634=Node634_Vmag_Vang.Data;  %
V_651=Node651_Vmag_Vang.Data;  %

Tap_634=Node634_TapPosition.Data;  %
Tap_651=Node651_TapPosition.Data;  %

Vreg_634=VregRefN634_sout.Data;    %
Vreg_651=VregRefN651_sout.Data;   %

Vregband_634=deadband_sout.Data;  %
Vregband_651=deadband_soutTx.Data;  %

Time2=Node634_TapPosition.Time;
TapMaintYN=Tap_Maintance_YN634.data;  %
TapMaintYNSub=Tap_Maintance_YN1651.data;  %


Int_634=Error_Integrator_State_634.Data;

k = find(TapMaintYN==1);
k2 = find(TapMaintYNSub==1);
j=isempty(k);
j2=isempty(k2);
if j==0
    k=k(1);
    tapmaintenanceTime=Time(k);
else 
    tapmaintenanceTime=Ts*size(TapMaintYN,1);
end
if j2==0
    k2=k2(1);
    tapmaintenanceTime2=Time(k2);
else 
    tapmaintenanceTime2=Ts*size(TapMaintYNSub,1);
end

figure(3)
subplot(3,2,1)
stairs(Time,V_651(:,1),'k')
hold on
grid on
stairs(Time,Vreg_651, 'r')
stairs(Time,Vreg_651-Vregband_651, '--r')
stairs(Time,Vreg_651+Vregband_651, '--r')
axis([Tstart Tstop  2400 2550 ])
title('V Mag 651 A')

subplot(3,2,2)
stairs(Time,V_634(:,1),'k')
hold on
grid on
stairs(Time,Vreg_634, 'r')
stairs(Time,Vreg_634-Vregband_634, '--r')
stairs(Time,Vreg_634+Vregband_634, '--r')
axis([Tstart Tstop  265 290 ])
title('V Mag 634 A')


subplot(3,2,3)
stairs(Time2, Tap_651(:,1))
axis([Tstart Tstop  0 16 ])
title('Tap Position A N651')
grid on

subplot(3,2,4)
stairs(Time2, Tap_634(:,1), 'm')
axis([Tstart Tstop  -17 17])
title('Tap Position A N634')
grid on


subplot(3,2,5)
stairs(Time2, Tap_634(:,1), 'm')
hold on
grid on
stairs(Time2, Tap_651(:,1), 'b')
axis([Tstart Tstop  -17 17])
title('Tap Position A N634 and N651')



subplot(3,2,6)
stairs(Time2,Int_634, 'm')
hold on
grid on
axis([Tstart Tstop  -2000 2000])
title('Integrator State N634 and N651')


