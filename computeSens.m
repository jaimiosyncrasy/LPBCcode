function [dvdq dvdp ddeldq ddeldp]=computeSens(dbcMeas,stepP,stepQ, dbcDur, vmag_new,vang_new,ctrl_idx,loadNames,Sbase)
    % This func computes sensitivities between vmag, vang, P, Q from gains of step
    % response data; these sensitivities encapsulates consideration of how heavily loaded
    % each phase is as well as how much impedance/losses is between the
    % actuator and performance node
    
    % dvdq is dim rx1, and so are the other sens vars. r is number of
    % actuator-phases

sense=zeros(length(ctrl_idx),2);
for i= 1:length(ctrl_idx) % 2r, r is num of phase actuators  
    
        str=loadNames{ctrl_idx(i)};
%         phase = str(length(str));
%         if phase == 'a'
%             phase = 1; 
%         elseif phase == 'b'
%             phase = 2;
%         elseif phase == 'c'
%             phase = 3; 
%   
    % ctrl_idx groups Ps, then Qs; however dbcMeas is ordered [P Q P Q...]
        phase=str2num(str(end)); % last char is phase number, i.e. 1 2 or 3
        if ~isempty(strfind(loadNames{ctrl_idx(i)},'/P')) % if actuator label contains /P
            sense(i,1)=(vmag_new(dbcMeas(2*i-1),phase)-vmag_new(dbcMeas(2*i-1)-dbcDur,phase))/(stepP/Sbase);
            sense(i,2)=(vang_new(dbcMeas(2*i-1),phase)-vang_new(dbcMeas(2*i-1)-dbcDur,phase))/(stepP/Sbase);
        elseif ~isempty(strfind(loadNames{ctrl_idx(i)},'/Q'))
            sense(i,1)=(vmag_new(dbcMeas(2*i-length(ctrl_idx)),phase)-vmag_new(dbcMeas(2*i-length(ctrl_idx))-dbcDur,phase))/(stepQ/Sbase);
            sense(i,2)=(vang_new(dbcMeas(2*i-length(ctrl_idx)),phase)-vang_new(dbcMeas(2*i-length(ctrl_idx))-dbcDur,phase))/(stepQ/Sbase);
        end
end


%%

    % sens should be positive because a load inc (dec in nodal pow inj)
    % should cause a dec in voltage; so mult by -1 to fix sign convention
    dvdp=-sense(1:length(ctrl_idx)/2,1);
    ddeldp=-sense(1:length(ctrl_idx)/2,2);
    dvdq=-sense(length(ctrl_idx)/2+1:end,1);
    ddeldq=-sense(length(ctrl_idx)/2+1:end,2);
% sensitivity values are in pu, sens=Vpu/Spu
end