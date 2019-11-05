function [dvdq dvdp ddeldq ddeldp]=computeSens(dbcMeas,stepP,stepQ, dbcDur, vmag_new,vang_new,ctrl_idx,loadNames)
    % This func computes sensitivities between vmag, vang, P, Q from gains of step
    % response data; these sensitivities encapsulates consideration of how heavily loaded
    % each phase is as well as how much impedance/losses is between the
    % actuator and performance node
    
    % dvdq is dim rx1, and so are the other sens vars. r is number of
    % actuator-phases

sense=zeros(length(ctrl_idx),2);
for i= 1:length(ctrl_idx) % 2r, r is num of phase actuators
        str=loadNames{ctrl_idx(i)};
        phase=str2num(str(end)); % last char is phase number
        if ~isempty(strfind(loadNames{ctrl_idx(i)},'/P')) % if actuator label contains /P
            sense(i,1)=(vmag_new(dbcMeas(i),phase)-vmag_new(dbcMeas(i)-dbcDur,phase))/(stepP);
            sense(i,2)=(vang_new(dbcMeas(i),phase)-vang_new(dbcMeas(i)-dbcDur,phase))/(stepP);
        elseif ~isempty(strfind(loadNames{ctrl_idx(i)},'/Q'))
            sense(i,1)=(vmag_new(dbcMeas(i),phase)-vmag_new(dbcMeas(i)-dbcDur,phase))/(stepQ);
            sense(i,2)=(vang_new(dbcMeas(i),phase)-vang_new(dbcMeas(i)-dbcDur,phase))/(stepQ);
        end
end
    % sens should be positive because a load inc (dec in nodal pow inj)
    % should cause a dec in voltage; so mult by -1 to fix sign convention
    dvdp=-1*sense(1:2:end,1);
    ddeldp=-1*sense(1:2:end,2);
    dvdq=-1*sense(2:2:end,1);
    ddeldq=-1*sense(2:2:end,2);
% sensitivity values are NOT in pu, sens=V/kW
end