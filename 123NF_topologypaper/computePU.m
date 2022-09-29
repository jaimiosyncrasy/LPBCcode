function [Sbase,V1base,V2base] = computePU()
%% For grid network of interest, computing Base Values, Per Unit
% % Calculating for 13NF 
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
    
    
    % Calculating for 33NF...
    % Calculating Base Vals to Convert to pu
   % Base voltages:
%     V1base=7199.6; V2base=0; % per phase
%     Sbase=15000/3; % kVAR, choose as 3x 13NF, 100MVA xfmr ratingt too large
%     baseVec=V1base;

    % Calculating for PL0001
   %Z Calculating Base Vals to Convert to pu
   % Base voltages:
%     V1base=7275; V2base=0;
%     Sbase=1500; % kVAR, same as XFMR rating --> UNSURE OF 1500
%     baseVec=V1base;

% Calculating for AL0001 
% Base voltages: 
% V1base=7275;
% V2base=120; 
% Sbase=2000; 
% baseVec=V1base;

     % Calculating for 123NF unbalanced
     %Calculating Base Vals to Convert to pu
 %    V1base=2401.8; % V 
    V1base=2370; % raise the Vpu by 1%
     Sbase=(V1base^2); % in VA, chosen so that Zbase=1
    V2base=NaN;
    
% % Calculating for 4NF...
%    V1_LL = 4160; % Voltage, line to line, from IEEE site
%    V1_ph = V1_LL/sqrt(3); % per phase voltage, value that goes into excel data sheet
%    % Base voltages:
%    V2_ph = V2_LL/sqrt(3); % zone 2 is only node 634, zone 1 is rest of nodes
%    V1base=V1_ph; V2base=V2_ph;
%    Sbase=5000; % kVAR, same as XFMR rating --> format for HIL testing 
%    baseVec=V1base;
	
% 	% % Calculating for ecoblock...    
%     V1base_LL=4.16; % kV L-L, put in xfmr tab
%     V1base_ph=1000*V1base_LL/sqrt(3); % V ph-N, put in bus tab
%     V2base_LL=0.416; % kV ph-ph, put in xfmr tab
%     V2base_ph=1000*V2base_LL/sqrt(3); % V ph-N, put in bus tab
%     V1base=V1base_ph; V2base=V2base_ph;
%     Sbase=1; % kVAR, same as XFMR rating --> format for HIL testing 
%     baseVec=V1base;
end

