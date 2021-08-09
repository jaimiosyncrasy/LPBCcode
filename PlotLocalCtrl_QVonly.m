
% Here's what we need to do:
% preprocess any phases or setup colors for certain indices of vmags
% plot vmags

%%

% Items plotLocalCtrl expects is in matlab workspace:
% data from sim, either load the .mat or already in workspace
%     t=1:0.1:600;
%     minStart=14*60+0; minEnd=14*60+5; % 14:00-14:05
%     Ts=0.1;
%     Vmag_ctrlStart=50; % in seconds
%     Vang_ctrlStart=50; % 

plotIdx=1:6; % if more than 1 act/perf node pair, assign which 3 indices to plot

%% Plot
tidx=0:length(t); % tout is cummulative timestep (non-int), tidx is integers for indexing
%FOR 1 NODE:
plotStart=minStart; %minute of the day, should not exceed timeEnd
%plotEnd=minStart+1450/600; % minEnd for entire simulation
%^to stop at certain timestep T, plotEnd=minStart+T/600
plotEnd=minEnd; % minEnd for entire simulation

inter=1:(plotEnd-plotStart)/Ts*60; %interval to plot over in seconds, may be a subset of the minStart to minEnd
checkPlotInter=max(inter)<=600/Ts % required, can only plot 10 min of 1s data

%% Plot Q

%Plot inv commands qnew
%put in for loop if want diff control gains for diff nodes
    figure;     % same plot across phases
    hold on;
    plot(tidx(inter+1),qnew(tidx(inter+1),:),'r-','LineWidth',1);
    C=plot([Vmag_ctrlStart/Ts,Vmag_ctrlStart/Ts],get(gca,'ylim'),'k-');
    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Reactive Power (pu)');title('Q cmd at actuator node, (Qmcd) p.u.'); grid on; legend('Qa','Qb','Qc','Qmin','Qmax');  
    %txt2 = strcat('Sbase (pu)=',num2str(Sbase)); text(get(gca,'xlim')+[0 -1000], get(gca,'ylim'),txt2);
    %set(gca, 'XTick',1:60:(plotEnd-plotStart+1)*60, 'XTickLabel',plotStart:(plotEnd+1))        
    hold off;

    
%% Plot Vmag
% find first instance of being in this range, across all phases
offset=5; % start looking for into safe set after first few seconds of the sim
vmag_underV=vmag_new(offset:end,[4 5 6]); % node 3
vmag_overV=vmag_new(offset:end,[1 2 3]); % node 2
for i=1:size(vmag_new,2)/2
    idx1(i)=find(vmag_underV(:,i)>0.95,1)+offset;
    idx2(i)=find(vmag_overV(:,i)<1.05,1)+offset;
end
timeEnter_fBelow=max(idx1)
timeEnter_fAbove=max(idx2)

    figure;     % same plot across phases
    hold on;
    plot(tidx(inter+1),vmag_new(tidx(inter+1),:),'r-o',tidx(inter+1),vmag_ref_sig(tidx(inter+1),1),'k.','LineWidth',1);
    r=tidx(inter+1);
    Ts_bound=0.02; vmag_step=vmag_ref_sig(300);
    % Plot deadband boundaries for marking settling time
    plot([r(1) r(end)], [0.95 0.95],'k--');
    plot([r(1) r(end)], [1.05 1.05],'k--');
    %plot(s,vmag_new(s,1),'k.','MarkerSize',20);
    %plot(t,repmat(vmin,[1,length(t)]),'k-.',t,repmat(vmax,[1,length(t)]),'k-.','LineWidth',1);
    C=plot([Vmag_ctrlStart/Ts,Vmag_ctrlStart/Ts],get(gca,'ylim'),'k-');
    S1=plot([timeEnter_fBelow,timeEnter_fBelow],get(gca,'ylim'),'m--');
    S2=plot([timeEnter_fAbove,timeEnter_fAbove],get(gca,'ylim'),'b--');
    
    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Voltage (pu)');title('Vmag at perf node'); grid on; 
    legend([C,S1,S2],{'ctrl start','safe from below','safe from above'});  
    %txt1 = strcat('perf node Vbase (V) =',num2str(V1base)); text(get(gca,'xlim')+[0 -1000],get(gca,'ylim'),txt1);
    %set(gca, 'XTick',1:60:(minEnd-minStart+1)*60, 'XTickLabel',minStart:(minEnd+1))        
    %axis([0,max(inter+1),0.9,1.2]); % narrow axis to easier see one phase
    hold off;
    axis([Vmag_ctrlStart-1 Vmag_ctrlStart+20 0.7 1.2]);

    ICcoor=[vmag_new(5,4) vmag_new(5,1)] % (v3,v2)
    settleTime=max([timeEnter_fBelow,timeEnter_fAbove])-Vmag_ctrlStart
 
  