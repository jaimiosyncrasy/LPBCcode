function [Sbase,V1base,V2base] = computePU()
%% For grid network of interest, computing Base Values, Per Unit
% % Calculating for 13NF...
%  %  Calculating Base Vals to Convert to pu
%     V1_LL = 4160; % Voltage, line to line, from IEEE site
%     V1_ph = V1_LL/sqrt(3); % per phase voltage, value that goes into excel data sheet
%     XFMR_highV = 4.16;
%     XFMR_lowV = 0.48;
%     V2_LL = V1_LL*XFMR_lowV/XFMR_highV; % low/high = turns ratio
%     % Base voltages:
%     V2_ph = V2_LL/sqrt(3); % zone 2 is only node 634, zone 1 is rest of nodes
%     V1base=V1_ph; V2base=V2_ph;
%     Sbase=5000/3; % kVAR, same as XFMR rating --> format for HIL testing 
%     baseVec=V1base;
    
    
%     % Calculating for 33NF...
%     % Calculating Base Vals to Convert to pu
%     V1_LL = 4160; % Voltage, line to line, from IEEE site
%     V1_ph = V1_LL/sqrt(3); % per phase voltage, value that goes into excel data sheet
%    % Base voltages:
%     V1base=2401.7; V2base=0;
%     Sbase=100000; % kVAR, same as XFMR rating
%     baseVec=V1base;

    % Calculating for PL0001
   %Z Calculating Base Vals to Convert to pu
   % Base voltages:
    V1base=7275; V2base=0;
    Sbase=1500; % kVAR, same as XFMR rating --> UNSURE OF 1500
    baseVec=V1base;

% Calculating for AL0001 
% Base voltages: 
% V1base=7275;
% V2base=120; 
% Sbase=2000; 
% baseVec=V1base;

 %     % Calculating for 123NF unbalanced
     % Calculating Base Vals to Convert to pu
%      V1base=2401.8; V2base=277.1281;
%      Sbase=5000/3; % kVAR, same as XFMR rating/3
%      baseVec=V1base;
end

