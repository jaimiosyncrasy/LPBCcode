function [dvdq dvdp ddeldq ddeldp]=computeSens(dbcMeas,stepP,stepQ, dbcDur, vmag_new,vang_new,Sbase,ctrl_idx,loadNames)
    % This func computes sensitivities between vmag, vang, P, Q from gains of step
    % response data; these sensitivities encapsulates consideration of how heavily loaded
    % each phase is as well as how much impedance/losses is between the
    % actuator and performance node
    
    % dvdq is dim rx1, and so are the other sens vars. r is number of
    % actuator-phases
    pjump=(stepP/Sbase); % scalar
    qjump=(stepQ/Sbase);
sense=zeros(length(ctrl_idx),2);
for i= 1:length(ctrl_idx) % 2r, r is num of phase actuators
        str=loadNames{ctrl_idx(i)}
        phase=str2num(str(end)); % last char is phase number
        if ~isempty(strfind(loadNames{ctrl_idx(i)},'/P')) % if actuator label contains /P
            disp('hi');
            (vmag_new(dbcMeas(i),phase)-vmag_new(dbcMeas(i)-dbcDur,phase))/(stepP/Sbase)
            sense(i,1)=(vmag_new(dbcMeas(i),phase)-vmag_new(dbcMeas(i)-dbcDur,phase))/(stepP/Sbase);
            sense(i,2)=(vang_new(dbcMeas(i),phase)-vang_new(dbcMeas(i)-dbcDur,phase))/(stepP/Sbase);
        elseif ~isempty(strfind(loadNames{ctrl_idx(i)},'/Q'))
            sense(i,1)=(vmag_new(dbcMeas(i),phase)-vmag_new(dbcMeas(i)-dbcDur,phase))/(stepQ/Sbase);
            sense(i,2)=(vang_new(dbcMeas(i),phase)-vang_new(dbcMeas(i)-dbcDur,phase))/(stepQ/Sbase);
        end
    end
    dvdp=sense(1:2:end,1);
    ddeldp=sense(1:2:end,2);
    dvdq=sense(2:2:end,1);
    ddeldq=sense(2:2:end,2);
    
%     m=0.8; % ammount you want to attain in first ts
%     Kp_vmag_guess=-m*(1./dvdq) % close to Kp_vmag?
%     Kp_vmag
end