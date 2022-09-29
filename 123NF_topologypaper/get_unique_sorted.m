function [meas_idx_sorted] = get_unique_sorted(meas_idx,measStr)
% take in measStr, group based on common chars,
% then sort meas_idx to output uniq_meas_idx
    Z = textscan(measStr,'%s','Delimiter',',')';
    measArr=Z{:}';
    rng(3) % make reproducable
    actNodes= cellfun(@(x) x(1:end-2),measArr,'UniformOutput',false)

    groupVec=[1]; groupNum=1;
    for i=1:length(actNodes)-1
        i
        if ~strcmp(actNodes{i+1},actNodes{i})
            groupNum=groupNum+1;
        end
        groupVec=[groupVec groupNum];
    end
    groupVec
    assert(length(groupVec)==length(actNodes))

    % then sort meas_idx within each group
    meas_idx_sorted=[];
    for i=1:max(groupVec)
        idx=find(i==groupVec);
        meas_idx_sorted=[meas_idx_sorted unique(meas_idx(idx),'sorted')]
    end
end

