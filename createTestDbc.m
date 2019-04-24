function [testDbcData, dbcMeas, stepP, stepQ, dbcDur]=createTestDbc(pload,qload,Ts,ctrl_idx)
    % pload and qload are in seconds, not in timesteps
    numDbc=length(ctrl_idx); % P&Q across all actuators and all phases
    dbcDur=20; % in timesteps, not in seconds
    totDbcTime=numDbc*(dbcDur*2)
    checkDbcFit=totDbcTime<length(pload)/Ts % the disturbance timesteps should not go off the edge of the actual sim duration
    dbcStart=5:dbcDur*2:totDbcTime % in timesteps
    dbcMeas=dbcStart+dbcDur-3; % in timesteps
    sz=size(pload);
    testDbcData=[[0:Ts:length(pload)]' zeros(length(pload)/Ts+1,numDbc)]; % col1 is time, initialize as no dbc with correct dims
    
    % define square wave (step up and step down) disturbance
    pload_avg=mean(pload);
    qload_avg=mean(qload);
    stepP=0.8*pload_avg; % scalar, assumes dbc location is colocated with a load
    stepQ=0.8*qload_avg; 
    for i=1:length(ctrl_idx)/2
        testDbcData(dbcStart(i*2-1):dbcStart(i*2-1)+dbcDur,i*2)=stepP(i); % 1 offset because 1st col is time
        testDbcData(dbcStart(i*2):dbcStart(i*2)+dbcDur,i*2+1)=stepQ(i);
    end
    
    % plot for debugging purpose
    figure; plot(testDbcData(:,2:end),'LineWidth',1.5); hold on; plot(dbcMeas,testDbcData(dbcMeas,2:end),'k.','MarkerSize',15); 
    legend(num2str(ctrl_idx)); title('test disturbance')
end