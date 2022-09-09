function [tarVmag,tarVang,vang_nom] = process_targets(minStart,measStr,meas_idx,test_num)
% to get targets of 1st timestep: row 1,3, and 11
% to get targets of 2nd timestep: row 1,4, and 14
    tarVmag=[]; tarVang_no_offset=[]; tarVang=[]; vang_nom=[];

	phtarg_file=strcat('tar_PVpen125_9.8/voltage_targets_lzn_test',num2str(test_num),'.csv');
	[num,txt,raw]=xlsread(phtarg_file);
    tar_names=txt(1,:);
    vmags=num(1,2:end);
    vangs=num(9,2:end);


    % find index of tar_names where measStr matches into tar_names  
    perfNode=split(measStr,',')
    for i=1:length(perfNode)
        checktar_names = not( cellfun( @isempty, strfind( tar_names, perfNode(i) ) ) );
        idx=find(checktar_names);
        tarVmag=[tarVmag vmags(idx)];
        tarVang_no_offset=[tarVang_no_offset vangs(idx)];
       if contains(tar_names(idx),'_a_')
	 %  if ismember('_a_',tar_names{i})
			tarVang=[tarVang 0+tarVang_no_offset(i)];
			vang_nom=[vang_nom 0];
	   elseif contains(tar_names(idx),'_b_')
			tarVang=[tarVang [-120]+tarVang_no_offset(i)];
			vang_nom=[vang_nom -120];
	   elseif contains(tar_names(idx),'_c_')
			tarVang=[tarVang [120]+tarVang_no_offset(i)];
			vang_nom=[vang_nom 120];
       end
       
    end
    %perf_idx=unique(perf_idx); % remove duplicates
    
    assert((length(meas_idx)==length(tarVmag) && length(meas_idx)==length(tarVang)));
    % issue: tarVmag is length 9 while length(meas_idx) is length 21
end


