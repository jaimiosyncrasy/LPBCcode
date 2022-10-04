function [vall_pu,vall_names_cleaned,scale] = clean_vall(vall,vall_names)
    % cleaning vall
    
    vall_names_cleaned=vall_names;
    
    idx=find(vall(1,:)<500);
    vall(:,idx)=[]; % remove secondary side voltages
    vall_names_cleaned(idx)=[];
    %vall_pu=vall/2385; %Vbase
    vall_pu=vall/2370; %Vbase
    rem_const=[];
    for i=1:size(vall_pu,2) % remove trajectory that doesnt change at all
        if length(find(abs(diff(vall_pu(:,i)))<0.001))==size(vall_pu,1)-1
            rem_const=[rem_const i];
        end
    end
    vall_pu(:,rem_const)=[];
    vall_names_cleaned(rem_const)=[];
    [maxval,idx]=max(vall_pu(end-10,:))
    scale=1.049/maxval % scale down because may be slightly ove
    vall_pu=vall_pu*scale;
end
