function [testDbcData, dbcMeas, stepP, stepQ, dbcDur]=createTestDbc(pload,qload,Ts,ctrl_idx,Sbase)
    % pload and qload are in seconds, not in timesteps
    numDbc=length(ctrl_idx); % P&Q across all actuators and all phases
    dbcDur=20; % in timesteps, not in seconds
    totDbcTime=numDbc*(dbcDur*2)
    checkDbcFit=totDbcTime<length(pload)/Ts % the disturbance timesteps should not go off the edge of the actual sim duration
    dbcStart=5:dbcDur*2:totDbcTime % in timesteps
    dbcMeas=dbcStart+dbcDur-3; % in timesteps
    sz=size(pload);
    testDbcData=[[0:Ts:length(pload)]' zeros(length(pload)/Ts+1,numDbc)]; % col1 is time, initialize as no dbc with correct dims
    % idx=find(vec_nodes==str2num(measStr(1:3))) %3.1 reconfigure to find
    % all of the PV nodes, and then during disturbance, decrease them by
    % 0.5
    
    % define square wave (step up and step down) disturbance
    pload_avg=mean(pload);
    qload_avg=mean(qload);
    % Must multiply by Sbase because dbc powers will be added in update
    % power block, which is in kW not pu
    stepP=3.33*pload_avg(1); % choose 1st avg to make scalar, assumes dbc location is colocated with a load
    stepQ=3.33*pload_avg(1);  %want at least 200 kW change to excite voltage
    for i=1:length(ctrl_idx)/2
        testDbcData(dbcStart(i*2-1):dbcStart(i*2-1)+dbcDur,i*2)=stepP; % 1 offset because 1st col is time
        testDbcData(dbcStart(i*2):dbcStart(i*2)+dbcDur,i*2+1)=stepQ;
    end
   
    %testDbcData = testDbcData*0; %TEMP comment out for Adam + 1.1 
%   plot for debugging purpose
    figure; plot(testDbcData(:,2:end),'LineWidth',1.5); hold on; plot(dbcMeas,testDbcData(dbcMeas,2:end),'k.','MarkerSize',15); 
    legend(num2str(ctrl_idx)); title('test disturbance: P,Q,P,Q...'); ylabel('kW or kVAR');
%     axis([0 totDbcTime 0 pload_avg(1)*11])
end