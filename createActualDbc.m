function actualDbcData=createActualDbc(pload,qload,Ts,dbc_idx,Sinv, netLoadData)
% input: net load data at dbc node across sim duration, pload is wx1
      % r is number of phases across all nodes, i.e. the dim of the pin
      % let w be number of timesteps in sim duration
% output: wx2, timeseries (col 1 is time) of disturbance signal across sim duration
    phases=length(dbc_idx)/2; % number of phases of disturbance
    sz=size(pload);
    actualDbcData=[[0:Ts:length(pload)]' zeros(length(pload)/Ts+1,phases*2)]; % col1 is time, initialize as no dbc with correct dims
    % TEMP: currently only single phase disturabance
    % define square wave (step up and step down) disturbance
    dbcStart=150; dbcEnd=180; % time is in seconds %IF CHANGED HERE, CHANGE IN UPDATE POWS 
   if Sinv<10000 % if inv limits active
       stepP=0.5*Sinv(1); % assume dbc is always at a node with a load
       stepQ=0.5*Sinv(1); % make disturbance not too large compared to inv limits 
   else % when no inv limits
        stepP=8*pload(dbcStart); % assumes dbc location is colocated with a load
        stepQ=8*qload(dbcStart); 
   end
   
   
    % assume same dbc on each phase if multiple phase disturbance
    actualDbcData(dbcStart/Ts:dbcEnd/Ts,2:phases+1)=stepP;
    actualDbcData(dbcStart/Ts:dbcEnd/Ts,phases+2:2*phases+1)=stepQ;
    %TEMP, comment out for Adam + 1.1
    % define other kinds of disturbances here
        % foo
end

