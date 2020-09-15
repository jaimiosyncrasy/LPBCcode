function [minStart,minEnd,tsVec] = setSimTime(timeStart,timeEnd)
%% Set Time and Init Condition Settings
[Y, M, D, H, MN, S]=datevec(timeStart,'HH:MM');
 sprintf('Time start: %02d:%02d:%02d', H, MN, S)
minStart=H*60+MN;
t1 = datetime(Y,M,D,H,MN,S);
[Y, M, D, H, MN, S]=datevec(timeEnd,'HH:MM');
 sprintf('Time end: %02d:%02d:%02d', H, MN, S)
minEnd=H*60+MN;
t2 = datetime(Y,M,D,H,MN,S);

% WHEN CHANGE TIME START AND END, CHANGE SIMULATING DURATION according to
% number below:
changeSimulink=(minEnd-minStart)*60 % tell user to change simulink run duration to get best results

%create timestamp vec from timeStart and timeEnd
tsVec= t1:minutes(1):t2; % minute-wise

% >> t = datetime( vec );
% >> t(1)
% ans = 
%   datetime
%    01-Mar-2018 00:00:00
% >> t(end)
% ans = 
%   datetime
%    31-Mar-2018 23:55:00
%     timeStart='9:00'; % HH:MM
% 
%    DateStrings = {'2014-05-26';'2014-08-03'};
% t = datetime(DateStrings,'InputFormat','yyyy-MM-dd')
%    
end

