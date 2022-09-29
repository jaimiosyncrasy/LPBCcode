function [reordered_buses] = make_busOrder(busNames_short,cby_loads,ctrl_idx_align)
    cby_loads_short=cellfun(@(x) x(1:end-3),cby_loads,'UniformOutput',false)
    reordered_buses=[]; 
    idx=[];
    for i=1:length(busNames_short)
        idx=find(ismember(cby_loads_short,busNames_short(i)));
        if ~isempty(idx)
            reordered_buses=[reordered_buses ctrl_idx_align(idx)];
        end
    end
end

