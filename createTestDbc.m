function testDbcData=createTestDbc(pload,qload,Ts,ctrl_idx)
%     dbcData=createActualDbc(loadData_noTS(:,dbc_idx(1)),loadData_noTS(:,dbc_idx(2)),Ts,dbc_idx);
    phases=length(ctrl_idx)/2; % number of phases of disturbance
    sz=size(pload);
    testDbcData=[[0:Ts:length(pload)]' zeros(length(pload)/Ts+1,phases*2)]; % col1 is time, initialize as no dbc with correct dims
    % TEMP: currently only single phase disturabance
    % define square wave (step up and step down) disturbance
    dbcStart=70; dbcEnd=100; % time is in seconds
    stepP=0.8*pload(dbcStart); % assumes dbc location is colocated with a load
    stepQ=0.8*qload(dbcStart); 
    % assume same dbc on each phase if multiple phase disturbance
    testDbcData(dbcStart/Ts:dbcEnd/Ts,2:phases+1)=stepP; % first half of cols
    testDbcData(dbcStart/Ts:dbcEnd/Ts,phases+2:2*phases+1)=stepQ; % end half of cols
    % define other kinds of disturbances here
        % foo
end