function actualDbcData=createActualDbc(pload,qload,Ts,dbc_idx,Sinv, netLoadData)
% input: net load data at dbc node across sim duration, pload is wx1
      % r is number of phases across all nodes, i.e. the dim of the pin
      % let w be number of timesteps in sim duration
% output: wx2, timeseries (col 1 is time) of MULTIPLE disturbance signal across sim duration
    totPh=length(dbc_idx)/2; % number of phases of disturbance
    sz=size(pload);
    actualDbcData=[[0:Ts:length(pload)]' zeros(length(pload)/Ts+1,totPh*2)]; % col1 is time, initialize as no dbc with correct dims
    % TEMP: currently only single phase disturabance
    % define square wave (step up and step down) disturbance
   
    % dbcs start 2 min in (120 seconds), then occurs every 15 minutes
    dbcStart=120:15*60:length(pload) % in seconds
    if Sinv<10000 % if inv limits active
       stepP=0.5*Sinv(1); % assume dbc is always at a node with a load
       stepQ=0.5*Sinv(1); % make disturbance not too large compared to inv limits 
   else % when no inv limits
        stepP=pload(dbcStart(1)); % assumes dbc location is colocated with a load
        stepQ=qload(dbcStart(1)); 
   end
    
    numDbc=length(dbcStart); % 
    numPh=randsrc(numDbc,1,[1,3;0.3,0.7]) % number of phases to choos
    for i=1:numDbc
        if numPh(i)==3 % dbc on 3 phases
            phIdx=[1 2 3];
        else % dbc on a single phase
            phIdx=randsrc(1,1,[1,2,3;0.33,0.33,0.34]); % randomly choose one of the phases
        end
        dbcAmp=(4-0.2)*rand(2,numPh(i))+0.2; % scaling factor for stepP/Q
        dbcDur=randi([10 120],1,1); % in seconds, dbcs are 10 to 120 second sq waves
        
        dbcEnd=(dbcStart(i)+dbcDur)
        actualDbcData(dbcStart(i)/Ts:dbcEnd/Ts,phIdx+1)=repmat(dbcAmp(1,:)*stepP,length(dbcStart(i)/Ts:dbcEnd/Ts),1);
        actualDbcData(dbcStart(i)/Ts:dbcEnd/Ts,phIdx+1+totPh)=repmat(dbcAmp(2,:)*stepQ,length(dbcStart(i)/Ts:dbcEnd/Ts),1);
    end
    
end

