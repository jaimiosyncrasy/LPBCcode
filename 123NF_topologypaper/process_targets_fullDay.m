function [tarVmag,tarVang,vang_nom] = process_targets(sim_iter,controlLoopAlign,measStr,meas_idx,test_num,num_tarSets)
% to get targets of 1st timestep: row 1,3, and 11
% to get targets of 2nd timestep: row 1,4, and 14
    tarVmag=[]; tarVang_no_offset=[]; tarVang=[]; vang_nom=[];

	phtarg_file=strcat('tar_PVpen125_9.10/voltage_targets_lzn_test',num2str(test_num),'.csv');
	[num,txt,raw]=xlsread(phtarg_file);
    foo=txt(1,:); tar_names=cellfun(@(x) x(5:end-4), foo, 'un', 0)
    vmags=num(sim_iter*2-1,2:end);
    vangs=num(sim_iter*2-1+num_tarSets*4+4,2:end); % sim_iter starts at 1

    % find index of tar_names where measStr matches into tar_names  
    perfNode=controlLoopAlign(:,2)
    for idx=1:length(tar_names) 
%         checktar_names = not( cellfun( @isempty, strfind( tar_names, perfNode(i) ) ) );
%         idx=find(ismember(buses2find_short,busNames_short{i}));
       % tar_names{idx}
        ismember(perfNode,tar_names{idx})
        if any(ismember(perfNode,tar_names{idx})) 
            tarVmag=[tarVmag vmags(idx)];
            tarVang_no_offset=[tarVang_no_offset vangs(idx)];
            if contains(tar_names{idx},'_a')
                tarVang=[tarVang 0+vangs(idx)];
                vang_nom=[vang_nom 0];
            elseif contains(tar_names{idx},'_b')
                tarVang=[tarVang [-120]+vangs(idx)];
                vang_nom=[vang_nom -120];
            elseif contains(tar_names{idx},'_c')
                tarVang=[tarVang [120]+vangs(idx)];
                vang_nom=[vang_nom 120];
            end
        end
       
    end
    %perf_idx=unique(perf_idx); % remove duplicates
    
    assert((length(unique(meas_idx,'stable'))==length(tarVmag) && length(unique(meas_idx,'stable'))==length(tarVang)));
    % issue: tarVmag is length 9 while length(meas_idx) is length 21
    
    %tarVmag=[1.01 1.03 1.03 1.01 1.03 1.04]; % TEMP
end


