function [tarVmag,tarVang] = process_targets(minStart,measStr,meas_idx)
    row=minStart+2 % minStart starts at 0, so if zero want 2nd row, so add 2
    [~,head,~] = xlsread('voltage_targets_123NF_100PVpen.csv','A1:ACU1');
    [num,txt,raw] = xlsread('voltage_targets_123NF_100PVpen.csv',strcat('A',num2str(row),':ACU',num2str(row)));
    assert(num(:,1)==minStart) % make sure TODs match
    % extract only the targets for your performance nodes:
    % find index of head where measStr matches into head
    
    perf_idx=[];
    perfNode=split(measStr,',')
    for i=1:length(perfNode)
        checkhead = not( cellfun( @isempty, strfind( head, perfNode(i) ) ) );
        perf_idx=[perf_idx find(checkhead)];
    end
    %perf_idx=unique(perf_idx); % remove duplicates
    
    a=head(perf_idx)
    b=num(perf_idx+1)
    % assign targets
    tarVmag=b(:,1:2:end)
    tarVang=b(:,2:2:end)
    assert((length(meas_idx)==length(tarVmag) && length(meas_idx)==length(tarVang)));
    % issue: tarVmag is length 9 while length(meas_idx) is length 21
end


