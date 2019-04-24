function [kgains] = getKgains(scenarioName)
% function to keep record of PI controller gains after designing so can
% rerun tests

% pseudocode:
G=cell(n,n); % cell array
% Scenario 1_1
Ku_Vmag=1;
Tu_Vmag=1;

Kp_Vmag=1;
Ki_Vmag=1;
Kp_Vang=1;
Ki_Vang=1;
% G(1)= fille with gains above

kgains=G{1}