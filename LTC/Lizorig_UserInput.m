close all
clear all
%run this first
%User inputs
%Tap controller to maintain a fixed voltage
% Ts=3 sec - measurements from L-PBC actuators reported each 3 sec 
load('tv_gen_73.5.mat')
load('tv_loads.mat')
tv_gen_632=[0*ones(1440,1) 0*ones(1440,1) 0*ones(1440,1) ];
tv_pload_632=[17*ones(1440,1) 66*ones(1440,1) 117*ones(1440,1) ];
tv_qload_632=[10*ones(1440,1) 38*ones(1440,1) 68*ones(1440,1) ];
sumA=tv_gen_632(:,1)+tv_gen_611(:,1)+tv_gen_634(:,1)+tv_gen_645(:,1)+tv_gen_646(:,1)+tv_gen_652(:,1)+tv_gen_671(:,1)+tv_gen_675(:,1)+tv_gen_692(:,1);
sumB=tv_gen_632(:,2)+tv_gen_611(:,2)+tv_gen_634(:,2)+tv_gen_645(:,2)+tv_gen_646(:,2)+tv_gen_652(:,2)+tv_gen_671(:,2)+tv_gen_675(:,2)+tv_gen_692(:,2);
sumC=tv_gen_632(:,3)+tv_gen_611(:,3)+tv_gen_634(:,3)+tv_gen_645(:,3)+tv_gen_646(:,3)+tv_gen_652(:,3)+tv_gen_671(:,3)+tv_gen_675(:,3)+tv_gen_692(:,3);
sumLdPA=tv_pload_632(:,1)+tv_pload_611(:,1)+tv_pload_634(:,1)+tv_pload_645(:,1)+tv_pload_646(:,1)+tv_pload_652(:,1)+tv_pload_671(:,1)+tv_pload_675(:,1)+tv_pload_692(:,1);
sumLdQB=tv_qload_632(:,1)+tv_qload_611(:,1)+tv_qload_634(:,1)+tv_qload_645(:,1)+tv_qload_646(:,1)+tv_qload_652(:,1)+tv_qload_671(:,1)+tv_qload_675(:,1)+tv_qload_692(:,1);
sumLdPB=tv_pload_632(:,2)+tv_pload_611(:,2)+tv_pload_634(:,2)+tv_pload_645(:,2)+tv_pload_646(:,2)+tv_pload_652(:,2)+tv_pload_671(:,2)+tv_pload_675(:,2)+tv_pload_692(:,2);
sumLdQB=tv_qload_632(:,2)+tv_qload_611(:,2)+tv_qload_634(:,2)+tv_qload_645(:,2)+tv_qload_646(:,2)+tv_qload_652(:,2)+tv_qload_671(:,2)+tv_qload_675(:,2)+tv_qload_692(:,2);
sumLdPC=tv_pload_632(:,3)+tv_pload_611(:,3)+tv_pload_634(:,3)+tv_pload_645(:,3)+tv_pload_646(:,3)+tv_pload_652(:,3)+tv_pload_671(:,3)+tv_pload_675(:,3)+tv_pload_692(:,3);
sumLdQC=tv_qload_632(:,3)+tv_qload_611(:,3)+tv_qload_634(:,3)+tv_qload_645(:,3)+tv_qload_646(:,3)+tv_qload_652(:,3)+tv_qload_671(:,3)+tv_qload_675(:,3)+tv_qload_692(:,3);
TotalPV=sumA+sumB+sumC;
TotalLoad=sumLdPA+sumLdPB+sumLdPC;
maxLd=max(TotalLoad);
maxPV=max(TotalPV);  % use real load for the calculation
PVpenetration=maxPV/maxLd; % 70.61%
% figure(1)
% plot(TotalPV, 'r')
% hold on
% plot(TotalLoad,'b')

Tstart=0;
Tstop=86400; %86400 seconds in a day
t = Tstop*(1/86400)*[1:60*60*24]'; %sec
t2=Tstop*(1/1440)*[1:60*24]';  %min - 400 is the simulation run time
spot=max(size(t2));
spot_mult=ones(spot,1);

% Transformer at Node 634 settings
Tap_Range_634=0.1; % or 10% percent
Vref_634=480/3^(1/2);        % Voltage reference
Integrator_634=1200; % increase to slow down  tap operations 
toptap_634=16;      %assume taps are symmetrical, i.e., toptap 16 bottom tap -16. 
Bandwidth_node_634=2*Vref_634*Tap_Range_634/toptap_634; % 1 tap operation up -> A= Vref_634*Tap_Range_634/toptap_634, 1 tap down = B , so select a number between 0 and 2 for example 1.5
d_634=3; %[3,1400] normal operation set this to 3 -  to create instability set to a number larger than the intergrator e.g., 

% Transformer at Node 651 Settings
Tap_Range_651=0.1; % or 10% percent
Vref_651=1.03*4160/3^(1/2);        % Voltage reference
Integrator_651=3000; % increase to slow down  tap operations 
toptap_651=16;      %assume taps are symmetrical, i.e., toptap 16 bottom tap -16. 
Bandwidth_node_651=1.5*Vref_651*Tap_Range_651/toptap_651; % 1 tap operation up -> A= Vref_634*Tap_Range_634/toptap_634, 1 tap down = B , so select a number between 0 and 2 for example 1.5
d_651=3;

%%% Generate simulink inputs
x=Bandwidth_node_634/2*ones(size(t,1),1);
x2=Bandwidth_node_651/2*ones(size(t,1),1);
y=Vref_634*ones(size(t,1),1);
y2=Vref_651*ones(size(t,1),1);
z=Integrator_634*ones(size(t,1),1);
z2=Integrator_651*ones(size(t,1),1);
p=toptap_634*ones(size(t,1),1);
p2=toptap_651*ones(size(t,1),1);
deadbandN634.time = t;
deadbandN634.signals.values = x;
deadbandN634.signals.dimensions =1;
deadbandN651.time = t;
deadbandN651.signals.values = x2;
deadbandN651.signals.dimensions =1;
VregRefN634.time = t;
VregRefN634.signals.values = y;
VregRefN634.signals.dimensions =1;
VregRefN651.time = t;
VregRefN651.signals.values = y2;
VregRefN651.signals.dimensions =1;
IntegratorN634.time = t;
IntegratorN634.signals.values = z;
IntegratorN634.signals.dimensions =1;
IntegratorN651.time = t;
IntegratorN651.signals.values = z2;
IntegratorN651.signals.dimensions =1;
toptapN634.time = t;
toptapN634.signals.values = p;
toptapN634.signals.dimensions =1;
toptapN651.time = t;
toptapN651.signals.values = p2;
toptapN651.signals.dimensions =1;
Node_646_G.time=t2;
Node_646_G.signals.values=tv_gen_646(:,2);
Node_646_G.signals.dimensions=1;
Node_646_P.time=t2;
Node_646_P.signals.values=tv_pload_646(:,2);
Node_646_P.signals.dimensions=1;
Node_646_Q.time=t2;
Node_646_Q.signals.values=tv_qload_646(:,2);
Node_646_Q.signals.dimensions=1;
Node_645_G.time=t2;
Node_645_G.signals.values=tv_gen_645(:,2);
Node_645_G.signals.dimensions=1;
Node_645_P.time=t2;
Node_645_P.signals.values=tv_pload_645(:,2);
Node_645_P.signals.dimensions=1;
Node_645_Q.time=t2;
Node_645_Q.signals.values=tv_qload_645(:,2);
Node_645_Q.signals.dimensions=1;
Node_652_G.time=t2;
Node_652_G.signals.values=tv_gen_652(:,1);
Node_652_G.signals.dimensions=1;
Node_652_P.time=t2;
Node_652_P.signals.values=tv_pload_652(:,1);
Node_652_P.signals.dimensions=1;
Node_652_Q.time=t2;
Node_652_Q.signals.values=tv_qload_652(:,1);
Node_652_Q.signals.dimensions=1;
Node_692_G.time=t2;
Node_692_G.signals.values=tv_gen_692(:,3);
Node_692_G.signals.dimensions=1;
Node_692_P.time=t2;
Node_692_P.signals.values=tv_pload_692(:,3);
Node_692_P.signals.dimensions=1;
Node_692_Q.time=t2;
Node_692_Q.signals.values=tv_qload_692(:,3);
Node_692_Q.signals.dimensions=1;
Node_611_G.time=t2;
Node_611_G.signals.values=tv_gen_611(:,3);
Node_611_G.signals.dimensions=1;
Node_611_P.time=t2;
Node_611_P.signals.values=tv_pload_611(:,3);
Node_611_P.signals.dimensions=1;
Node_611_Q.time=t2;
Node_611_Q.signals.values=tv_qload_611(:,3);
Node_611_Q.signals.dimensions=1;
Node_634_G.time=t2;
Node_634_G.signals.values=tv_gen_634;
Node_634_G.signals.dimensions=3;
Node_634_P.time=t2;
Node_634_P.signals.values=tv_pload_634;
Node_634_P.signals.dimensions=3;
Node_634_Q.time=t2;
Node_634_Q.signals.values=tv_qload_634;
Node_634_Q.signals.dimensions=3;
Node_671_G.time=t2;
Node_671_G.signals.values=tv_gen_671;
Node_671_G.signals.dimensions=3;
Node_671_P.time=t2;
Node_671_P.signals.values=tv_pload_671;
Node_671_P.signals.dimensions=3;
Node_671_Q.time=t2;
Node_671_Q.signals.values=tv_qload_671;
Node_671_Q.signals.dimensions=3;
Node_632_G.time=t2;
Node_632_G.signals.values=[0*spot_mult 0*spot_mult 0*spot_mult];
Node_632_G.signals.dimensions=3;
Node_632_P.time=t2;
Node_632_P.signals.values=[17*spot_mult 66*spot_mult 117*spot_mult];
Node_632_P.signals.dimensions=3;
Node_632_Q.time=t2;
Node_632_Q.signals.values=[10*spot_mult 38*spot_mult 68*spot_mult];
Node_632_Q.signals.dimensions=3;
Node_675_G.time=t2;
Node_675_G.signals.values=tv_gen_675;
Node_675_G.signals.dimensions=3;
Node_675_P.time=t2;
Node_675_P.signals.values=tv_pload_675;
Node_675_P.signals.dimensions=3;
Node_675_Q.time=t2;
Node_675_Q.signals.values=tv_qload_675;
Node_675_Q.signals.dimensions=3;

sim('Lizorig_phasor08_IEEE13.mdl') %run ePhasorSim
run('Lizorig_Tx634Tap.m')                 % plot results
