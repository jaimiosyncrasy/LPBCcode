function [dvdq dvdp ddeldq ddeldp sensMats]=computeSens(dbcMeas,stepP,stepQ, dbcDur, vmag_new,vang_new,ctrl_idx,uniq_meas_idx,loadNames,Sbase)
    % This func computes sensitivities between vmag, vang, P, Q from gains of step
    % response data; these sensitivities encapsulates consideration of how heavily loaded
    % each phase is as well as how much impedance/losses is between the
    % actuator and performance node
    
    % dvdq is dim rx1, and so are the other sens vars. r is number of
    % actuator-phases
d=length(ctrl_idx); %d/2 is num of phase actuators 
s=length(uniq_meas_idx);
for i= 1:d % for all power injections
    str=loadNames{ctrl_idx(i)};
    % each dvdpMat is nxn matrix, where n is number of phase actuators
    % dvdpMat=[dV1/dQ1 dV2/dQ1 ...
    %    dV1/dQ2 dV2/dQ2 ...
    for j=1:s % for all voltages
        % ctrl_idx groups Ps, then Qs; however dbcMeas is ordered [P Q P Q...]
            phase=str2num(str(end)); % last char is phase-actuator index number
            if ~isempty(strfind(loadNames{ctrl_idx(i)},'/P')) % if actuator label contains /P
                assert(i<=d/2,"loadNames(ctrl_idx) is not PPP then QQQ")
                dvdpMat(i,j)=(vmag_new(dbcMeas(2*i-1),j)-vmag_new(dbcMeas(2*i-1)-dbcDur,j))/(stepP*1000/Sbase);
                dv2dpMat(i,j)=(vmag_new(dbcMeas(2*i-1),j)^2-vmag_new(dbcMeas(2*i-1)-dbcDur,j)^2)/(stepP*1000/Sbase);
                ddeldpMat(i,j)=(vang_new(dbcMeas(2*i-1),j)-vang_new(dbcMeas(2*i-1)-dbcDur,j))/(stepP*1000/Sbase);
            elseif ~isempty(strfind(loadNames{ctrl_idx(i)},'/Q'))
                assert(i>d/2,"loadNames(ctrl_idx) is not PPP then QQQ")
                dvdqMat(i-d/2,j)=(vmag_new(dbcMeas(2*i-length(ctrl_idx)),j)-vmag_new(dbcMeas(2*i-length(ctrl_idx))-dbcDur,j))/(stepQ*1000/Sbase);
                dv2dqMat(i-d/2,j)=(vmag_new(dbcMeas(2*i-length(ctrl_idx)),j)^2-vmag_new(dbcMeas(2*i-length(ctrl_idx))-dbcDur,j)^2)/(stepQ*1000/Sbase);
                ddeldqMat(i-d/2,j)=(vang_new(dbcMeas(2*i-length(ctrl_idx)),j)-vang_new(dbcMeas(2*i-length(ctrl_idx))-dbcDur,j))/(stepQ*1000/Sbase);
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


dvdp=-extract_blks(dvdpMat);
ddeldp=-extract_blks(ddeldpMat);
dvdq=-extract_blks(dvdqMat);
ddeldq=-extract_blks(ddeldqMat);
% sensitivity values are in pu, sens=Vpu/Spu
end