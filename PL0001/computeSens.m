function [dvdq dvdp ddeldq ddeldp sensMats]=computeSens(dbcMeas,stepP,stepQ, dbcDur, vmag_new,vang_new,ctrl_idx,loadNames,Sbase)
    % This func computes sensitivities between vmag, vang, P, Q from gains of step
    % response data; these sensitivities encapsulates consideration of how heavily loaded
    % each phase is as well as how much impedance/losses is between the
    % actuator and performance node
    
    % dvdq is dim rx1, and so are the other sens vars. r is number of
    % actuator-phases
r=length(ctrl_idx)/2; %r is num of phase actuators 
for i= 1:2*r % 2r, r is num of phase actuators      
    str=loadNames{ctrl_idx(i)};
    % each dvdpMat is nxn matrix, where n is number of phase actuators
    % dvdpMat=[dV1/dQ1 dV2/dQ1 ...
    %    dV1/dQ2 dV2/dQ2 ...
    for j=1:r
        % ctrl_idx groups Ps, then Qs; however dbcMeas is ordered [P Q P Q...]
            phase=str2num(str(end)); % last char is phase-actuator index number
            if ~isempty(strfind(loadNames{ctrl_idx(i)},'/P')) % if actuator label contains /P
                dvdpMat(i,j)=(vmag_new(dbcMeas(2*i-1),j)-vmag_new(dbcMeas(2*i-1)-dbcDur,j))/(stepP/Sbase);
                dv2dpMat(i,j)=(vmag_new(dbcMeas(2*i-1),j)^2-vmag_new(dbcMeas(2*i-1)-dbcDur,j)^2)/(stepP/Sbase);
                ddeldpMat(i,j)=(vang_new(dbcMeas(2*i-1),j)-vang_new(dbcMeas(2*i-1)-dbcDur,j))/(stepP/Sbase);
            elseif ~isempty(strfind(loadNames{ctrl_idx(i)},'/Q'))
                dvdqMat(i-r,j)=(vmag_new(dbcMeas(2*i-length(ctrl_idx)),j)-vmag_new(dbcMeas(2*i-length(ctrl_idx))-dbcDur,j))/(stepQ/Sbase);
                dv2dqMat(i-r,j)=(vmag_new(dbcMeas(2*i-length(ctrl_idx)),j)^2-vmag_new(dbcMeas(2*i-length(ctrl_idx))-dbcDur,j)^2)/(stepQ/Sbase);
                ddeldqMat(i-r,j)=(vang_new(dbcMeas(2*i-length(ctrl_idx)),j)-vang_new(dbcMeas(2*i-length(ctrl_idx))-dbcDur,j))/(stepQ/Sbase);
            end
    end
end

% sens should be positive because a load inc (dec in nodal pow inj)
% should cause a dec in voltage; so mult by -1 to fix sign convention
    
% collect all sensitivities
sensMats{1}=-dvdpMat; % relation between voltage mag and real power
sensMats{2}=-ddeldpMat;
sensMats{3}=-dvdqMat;
sensMats{4}=-ddeldqMat;
sensMats{5}=-dv2dpMat; % relation between squared voltage mag and real power
sensMats{6}=-dv2dqMat;

%%
dvdp=-diag(dvdpMat);
ddeldp=-diag(ddeldpMat);
dvdq=-diag(dvdqMat);
ddeldq=-diag(ddeldqMat);
% sensitivity values are in pu, sens=Vpu/Spu
end