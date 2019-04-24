function [dvdq dvdp ddeldq ddeldp]=computeSens(dbcMeas, stepP, stepQ, dbcDur, vmag_new,vang_new,Sbase,ctrl_idx,loadNames)
    % compute sensitivities between vmag, vang, P, Q from gains of step
    % response data
    
    pjump=stepP; % scalar
    qjump=stepQ;
    dvdp=cell(length(ctrl_idx),1); ddeldp=cell(length(ctrl_idx),1); dvdq=cell(length(ctrl_idx),1); ddeldeq=cell(length(ctrl_idx),1);
    for i= 1:length(ctrl_idx)
        str=loadNames{ctrl_idx(i)}
        phase=str2num(str(end)); % last char is phase number
        if ~isempty(strfind(loadNames{ctrl_idx(i)},'/P')) % if actuator label contains /P
            (vmag_new(dbcMeas(i),phase)-vmag_new(dbcMeas(i)-dbcDur,phase))/stepP
            dvdp{i}=(vmag_new(dbcMeas(i),phase)-vmag_new(dbcMeas(i)-dbcDur,phase))/stepP;
            ddeldp{i}=(vang_new(dbcMeas(i),phase)-vang_new(dbcMeas(i)-dbcDur,phase))/stepP;
        elseif ~isempty(strfind(loadNames{ctrl_idx(i)},'/Q'))
            dvdq{i}=(vmag_new(dbcMeas(i),phase)-vmag_new(dbcMeas(i)-dbcDur,phase))/stepQ;
            ddeldq{i}=(vang_new(dbcMeas(i),phase)-vang_new(dbcMeas(i)-dbcDur,phase))/stepQ;
        end
    end
%     m=0.8; % ammount you want to attain in first ts
%     Kp_vmag_guess=-m*(1./dvdq) % close to Kp_vmag?
%     Kp_vmag
end