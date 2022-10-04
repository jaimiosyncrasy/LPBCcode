
close all;

plotIdx=1:min([3,size(vmag_new,2)]); % if more than 1 act/perf node pair, assign which 3 indices to plot

%% Plot
tidx=1:length(t); % tout is cummulative timestep (non-int), tidx is integers for indexing
%plotStart=minStart; %minute of the day, should not exceed timeEnd
plotStart=round((Vmag_ctrlStart-ctrl_start_lag)/60); % minutes after sim start
%plotEnd=minStart+1450/600; % minEnd for entire simulation
%^to stop at certain timestep T, plotEnd=minStart+T/600
plotEnd=plotStart+(minEnd-minStart); % minutes after sim start
%plotEnd=2.5; % minutes after sim start

num_mnt_plot=7; % minutes to plot after ctrl staRT
%inter=plotStart*60:plotStart*60+(plotEnd-plotStart)/Ts*60; %interval to plot over in seconds, may be a subset of the minStart to minEnd
%inter=50:150; %interval to plot over in seconds
inter=Vmag_ctrlStart-12:Vmag_ctrlStart+num_mnt_plot*60;
checkPlotInter=max(inter)<=600/Ts % required, can only plot 10 min of 1s data

%size(inter=1:300-50;
%%
 
% Plot Q and Vmag
vmag_init_actual =[[0:60:(minEnd-minStart)*60]',repmat(vmag_new(2,:),minEnd-minStart+1,1)]; % extract voltage after run PF solver once, use this value to set relative Vref

% %Plot inv commands qnew
% %put in for loop if want diff control gains for diff nodes
%     figure;     % same plot across phases
%     hold on;
%     plot(tidx(inter+1),qnew(tidx(inter+1),plotIdx(1)),'r-','LineWidth',1);
%     plot(tidx(inter+1),qnew(tidx(inter+1),plotIdx(2)),'b-','LineWidth',1);
%     plot(tidx(inter+1),qnew(tidx(inter+1),plotIdx(3)),'color',[0.9290 0.6940 0.1250],'LineWidth',1);
%     %plot(t,repmat(qmin,[1,length(t)]),'k-.',t,repmat(qmax,[1,length(t)]),'k-.','LineWidth',1);
%     %plot(s,qnew(s,1),'k.','MarkerSize',20);
%     plot([Vmag_ctrlStart/Ts,Vmag_ctrlStart/Ts],get(gca,'ylim'),'k-');
%     xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Reactive Power (kVar)');title('Q cmd at actuator node'); grid on; legend('Qa','Qb','Qc','Control turn on');  
%     %txt2 = strcat('Sbase (pu)=',num2str(Sbase)); text(get(gca,'xlim')+[0 -1000], get(gca,'ylim'),txt2);
%     %set(gca, 'XTick',1:60:(plotEnd-plotStart+1)*60, 'XTickLabel',plotStart:(plotEnd+1))        
%     hold off;

% %Plot inverter outputs qact
% qinv=PQact(:,4:6);
% %put in for loop if want diff control gains for diff nodes
%     figure;     % same plot across phases
%     hold on;
%     plot(tidx(inter+1),qinv(tidx(inter+1),1),'r-','LineWidth',1);
%     plot(tidx(inter+1),qinv(tidx(inter+1),2),'b-','LineWidth',1);
%     plot(tidx(inter+1),qinv(tidx(inter+1),3),'color',[0.9290 0.6940 0.1250],'LineWidth',1);
%     %plot(t,repmat(qmin,[1,length(t)]),'k-.',t,repmat(qmax,[1,length(t)]),'k-.','LineWidth',1);
%     %plot(s,qnew(s,1),'k.','MarkerSize',20);
%     plot([Vmag_ctrlStart,Vmag_ctrlStart],get(gca,'ylim'),'k-');
% 
%     xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Reactive Power (kVAR)');title('Q inv at actuator node, (Qmcd) p.u.'); grid on; legend('Qa','Qb','Qc','Qmin','Qmax');  
%     %txt2 = strcat('Sbase (pu)=',num2str(Sbase)); text(get(gca,'xlim')+[0 -1000], get(gca,'ylim'),txt2);
%     %set(gca, 'XTick',1:60:(plotEnd-plotStart+1)*60, 'XTickLabel',plotStart:(plotEnd+1))        
%     hold off;
    
%% Plot outputs v
    figure;     % same plot across phases
    hold on;
    plot(tidx(inter+1),vmag_new(tidx(inter+1),plotIdx(1)),'r-',tidx(inter+1),vmag_ref_sig(tidx(inter+1),1),'r--','LineWidth',1);
    if length(plotIdx)>1
         plot(tidx(inter+1),vmag_new(tidx(inter+1),plotIdx(2)),'b-',tidx(inter+1),vmag_ref_sig(tidx(inter+1),2),'b--','LineWidth',1);
    end
    if length(plotIdx)>2
         plot(tidx(inter+1),vmag_new(tidx(inter+1),plotIdx(3)),tidx(inter+1),vmag_ref_sig(tidx(inter+1),3),'--','color',[0.9290 0.6940 0.1250],'LineWidth',1);
    end
     r=tidx(inter+1);
    Ts_bound=0.02;
    % Plot boundaries around settling time
    %    plot([r(1) r(end)], [vmag_new(r(end),1)+Ts_bound*vmag_step vmag_new(r(end),1)+Ts_bound*vmag_step],'k-');
    %    plot([r(1) r(end)], [vmag_new(r(end),1)-Ts_bound*vmag_step vmag_new(r(end),1)-Ts_bound*vmag_step],'k-');
    %    plot([r(1) r(end)], [vmag_new(r(end),2)+Ts_bound*vmag_step vmag_new(r(end),2)+Ts_bound*vmag_step],'k-');
    %    plot([r(1) r(end)], [vmag_new(r(end),2)-Ts_bound*vmag_step vmag_new(r(end),2)-Ts_bound*vmag_step],'k-');
    %    plot([r(1) r(end)], [vmag_new(r(end),3)+Ts_bound*vmag_step vmag_new(r(end),3)+Ts_bound*vmag_step],'k-');
    %    plot([r(1) r(end)], [vmag_new(r(end),3)-Ts_bound*vmag_step vmag_new(r(end),3)-Ts_bound*vmag_step],'k-');

    %plot(s,vmag_new(s,1),'k.','MarkerSize',20);
    %plot(t,repmat(vmin,[1,length(t)]),'k-.',t,repmat(vmax,[1,length(t)]),'k-.','LineWidth',1);
    plot([Vmag_ctrlStart/Ts,Vmag_ctrlStart/Ts],get(gca,'ylim'),'k-');

    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Voltage (pu)');title('Vmag at perf node'); grid on; legend('v_a','v_a ref','v_b','v_b ref','v_c','v_c ref','ctrl start');  
    %txt1 = strcat('perf node Vbase (V) =',num2str(V1base)); text(get(gca,'xlim')+[0 -1000],get(gca,'ylim'),txt1);
    %set(gca, 'XTick',1:60:(minEnd-minStart+1)*60, 'XTickLabel',minStart:(minEnd+1))        
    %axis([0,max(inter+1),0.9,1.2]); % narrow axis to easier see one phase
    hold off;
 
%  maxDelU_vmag=max(max(abs(delta_u_vmag)))
%  maxU_vmag=max(max(abs(vmag_new)))

 %% Plot P and Vang
        a=[10 -130 130];
vang_init_actual =[[0:60:(minEnd-minStart)*60]',repmat(vang_new(2,:),minEnd-minStart+1,1)]; % extract voltage after run PF solver once, use this value to set relative Vref
% vmag_new(2,:) is 1x3

% % Plot inverter commands pnew
%     figure;     % same plot across phases
%     hold on;
%     plot(tidx(inter+1),pnew(tidx(inter+1),plotIdx(1)),'r-','LineWidth',1);
%     plot(tidx(inter+1),pnew(tidx(inter+1),plotIdx(2)),'b-','LineWidth',1);
%     plot(tidx(inter+1),pnew(tidx(inter+1),plotIdx(3)),'color',[0.9290 0.6940 0.1250],'LineWidth',1);
% %     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),1),'b--','LineWidth',1);
% %     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),2),'r--','LineWidth',1);
% %     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),3),'g--','LineWidth',1);
%     %plot(t,repmat(qmin,[1,length(t)]),'k-.',t,repmat(qmax,[1,length(t)]),'k-.','LineWidth',1);
%     plot([Vang_ctrlStart/Ts,Vang_ctrlStart/Ts],get(gca,'ylim'),'k-');
% 
%     xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Real Power (kW)');title('p cmd at actuator node'); grid on; legend('Pa','Pb','Pc','Control turn on');
%     %txt2 = strcat('Sbase (pu)=',num2str(Sbase)); text(get(gca,'xlim')+[0 -1000], get(gca,'ylim'),txt2);
%     %set(gca, 'XTick',1:60:(minEnd-minStart+1)*60, 'XTickLabel',minStart:(minEnd+1))        
% 
%     hold off;

% %Plot inverter outputs pact
% pinv=PQact(:,1:3);
%     figure;     % same plot across phases
%     hold on;
%     plot(tidx(inter+1),pinv(tidx(inter+1),1),'r-','LineWidth',1);
%     plot(tidx(inter+1),pinv(tidx(inter+1),2),'b-','LineWidth',1);
%     plot(tidx(inter+1),pinv(tidx(inter+1),3),'color',[0.9290 0.6940 0.1250],'LineWidth',1);
% %     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),1),'b--','LineWidth',1);
% %     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),2),'r--','LineWidth',1);
% %     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),3),'g--','LineWidth',1);
%     plot([Vang_ctrlStart,Vang_ctrlStart],get(gca,'ylim'),'k-');
% 
%     xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Real Power (kW)');title('p inv at actuator node'); grid on; legend('Pa','Pb','Pc','Pavail');
%     %txt2 = strcat('Sbase (pu)=',num2str(Sbase)); text(get(gca,'xlim')+[0 -1000], get(gca,'ylim'),txt2);
%     %set(gca, 'XTick',1:60:(minEnd-minStart+1)*60, 'XTickLabel',minStart:(minEnd+1))        
% 
%     hold off;    
    
%% Plot vang as subplots so can see up close:
    figure;     % same plot across phases
    h1=subplot(3,1,1); hold on;
    plot(tidx(inter+1),vang_new(tidx(inter+1),plotIdx(1)),'r-',tidx(inter+1),vang_ref_sig(tidx(inter+1),1),'r--','LineWidth',1);
    plot([Vang_ctrlStart/Ts,Vang_ctrlStart/Ts],get(gca,'ylim'),'k-');

    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec'));title('Vang at perf node'); grid on; legend('v_a','v_a ref','ctrl start');  

    h2=subplot(3,1,2); hold on;
    if length(plotIdx)>1
        plot(tidx(inter+1),vang_new(tidx(inter+1),plotIdx(2)),'b-',tidx(inter+1),vang_ref_sig(tidx(inter+1),2),'b--','LineWidth',1);
        plot([Vang_ctrlStart/Ts,Vang_ctrlStart/Ts],get(gca,'ylim'),'k-');
    end
    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); title('Vang at perf node'); grid on; legend('v_b','v_b ref','ctrl start');  

    h3=subplot(3,1,3); hold on;
    if length(plotIdx)>2
        plot(tidx(inter+1),vang_new(tidx(inter+1),plotIdx(3)),tidx(inter+1),vang_ref_sig(tidx(inter+1),3),'--','color',[0.9290 0.6940 0.1250],'LineWidth',1);
        plot([Vang_ctrlStart/Ts,Vang_ctrlStart/Ts],get(gca,'ylim'),'k-');
    end
    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec'));title('Vang at perf node'); grid on; legend('v_c','v_c ref','ctrl start');  

    %axis([min(tidx(inter+1)),max(tidx(inter+1)),-5,5]); % narrow axis to easier see one phase
    %set(gca, 'XTick',plotStart:60:(plotEnd-plotStart+1)*60, 'XTickLabel',minStart:(minEnd+1))        
p1=get(h1,'position');
p2=get(h2,'position');
p3=get(h3,'position');
height=p2(2)-p2(4);
h3=axes('position',[p2(1) p2(2) p2(3) height],'visible','off');
h_label=ylabel('Phase Angle (degrees)','visible','on');

    hold off;
 
    
    %%
% % plot load data over sim interval
% figure; plot(netLoadData(:,1),netLoadData(:,2:end)); title('load data, one curve for each node'); xlabel('seconds'); ylabel('kW or kVAR');


%% Plot all pq output (after rsc constr) one plot
pinv=PQact(:,1:size(PQact,2)/2);
qinv=PQact(:,size(PQact,2)/2+1:end);
figure; 
subplot(2,1,2); plot(tidx(inter+1),pinv(tidx(inter+1),:),'LineWidth',1);
xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Real Power (kW)');title('P inv at all actuators'); grid on;
subplot(2,1,1);  plot(tidx(inter+1),qinv(tidx(inter+1),:),'LineWidth',1);
xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Reactive Power (kVAR)');title('Q inv at all actuators'); grid on;

totP_perph=sum(pinv(200,:))/3
totQ_perph=sum(qinv(200,:))/3

%%
% figure; subplot(2,1,1); plot(tidx(inter+1),qnew(inter+1,:),'LineWidth',1.2); title('q cmd (pu)'); grid on;
% subplot(2,1,2); plot(tidx(inter+1),pnew(inter+1,:),'LineWidth',1.2); title('p cmd (pu)'); grid on;

%%
figure; subplot(2,1,1); plot(tidx(inter+1),vmagsq_err(inter+1,:),'LineWidth',1); title('vmag err (meas-ref), pos=overV'); grid on;
xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('tracking error (pu)');grid on;
subplot(2,1,2); plot(tidx(inter+1),vang_err(inter+1,:),'LineWidth',1); title('vang err (meas-ref)'); grid on;
xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('tracking error (deg)');grid on;


%% Save all figs and data to files
% figure; plot(vmagsq_err(Vmag_ctrlStart-5:Vmag_ctrlStart+15,:))


% save data into .mats
if mode==1
    plot_dir=strcat('results/test',num2str(test_num),'_Helou_plots');
    mkdir(plot_dir)
    save(strcat('results/test',num2str(test_num),'_Helou_plots/data_norsc_9.18.mat'),'Vmag_ctrlStart','vmag_new','vmagsq_err','vang_err','vmag_all','vang_new','pnew','qnew','simTimestamps','vmag_ref_sig','vang_ref_sig','Fbar')
elseif mode==2
    plot_dir=strcat('results/test',num2str(test_num),'_plots');
    mkdir(plot_dir)
    save(strcat('results/test',num2str(test_num),'_plots/data_norsc_9.18.mat'),'Vmag_ctrlStart','vmag_new','vmagsq_err','vang_err','vmag_all','vang_new','pnew','qnew','simTimestamps','vmag_ref_sig','vang_ref_sig','Fbar')
end
fig_names={'err','PQ','vang','vmag'};
save_all_figs(plot_dir,fig_names)
