% left off here: testDbcData timevec is zeroing out after 300 timesteps

function [testDbcData, dbcMeas, stepP, stepQ]=createTestDbc(pload,qload,Ts,ctrl_idx,dbcDur,loadNames)
    % pload and qload are in seconds, not in timesteps
    numDbc=length(ctrl_idx); % P&Q across all actuators and all phases
    totDbcTime=numDbc*(dbcDur*2);
    %end of dbc=dbcDur+totDbcTime=20+2*r*40
    checkTestDbcFit=totDbcTime<length(pload)/Ts % the disturbance timesteps should not go off the edge of the actual sim duration
    dbcStart=dbcDur+3:dbcDur*2:totDbcTime; % in timesteps
    dbcMeas=dbcStart+dbcDur-3; % timesteps to measure dbc
    sz=size(pload);
    testDbcData=[[0:Ts:length(pload)]' zeros(length(pload)/Ts+1,numDbc)]; % col1 is time, initialize as no dbc with correct dims
    % idx=find(vec_nodes==str2num(measStr(1:3))) %3.1 reconfigure to find
    % all of the PV nodes, and then during disturbance, decrease them by
    % 0.5
    
    % define square wave (step up and step down) disturbance, units of kW
    stepP=-200; % choose 200kW for medium voltage actuator, 1kW for low voltage actuator
    stepQ=-200;  % units=kW

    % for PL0001 assign 70
    % for 13NF assign
    % for 123NF assign 100
    
    % format of PQPQPQ across cols; injections switch PQPQ over time
    ctrl_idx_dbcOrder=[];
    for i=1:length(ctrl_idx)/2
        testDbcData(dbcStart(i*2-1):dbcStart(i*2-1)+dbcDur,i*2)=stepP; % 1 offset because 1st col is time
        testDbcData(dbcStart(i*2):dbcStart(i*2)+dbcDur,i*2+1)=stepQ;
        ctrl_idx_dbcOrder=[ctrl_idx_dbcOrder [ctrl_idx(i) ctrl_idx(length(ctrl_idx)/2+i)]];
    end
   
    %testDbcData = testDbcData*0; %TEMP comment out for Adam + 1.1 
%   plot for debugging purpose
    figure; plot(testDbcData(:,2:end),'LineWidth',1.5); hold on; plot(dbcMeas,testDbcData(dbcMeas,2:end),'k.','MarkerSize',15); 
    legend(loadNames(ctrl_idx_dbcOrder)); title('test disturbance: P,Q,P,Q...'); ylabel('kW or kVAR');
     axis([0 totDbcTime min(stepQ,0)*1.2 max(stepQ,0)*1.2])
    % confirmed that there is only ever one phase-act injection
end