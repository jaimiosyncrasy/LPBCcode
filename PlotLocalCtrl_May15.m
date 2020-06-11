

% Items plotLocalCtrl expects is in matlab workspace:
% data from sim, either load the .mat or already in workspace
%     t=1:0.1:600;
%     minStart=14*60+0; minEnd=14*60+5; % 14:00-14:05
%     Ts=0.1;
%     Vmag_ctrlStart=50; % timesteps
%     Vang_ctrlStart=50; % timesteps

%% Plot
tidx=0:length(t); % tout is cummulative timestep (non-int), tidx is integers for indexing
%FOR 1 NODE:
plotStart=minStart; %minute of the day, should not exceed timeEnd
plotEnd=minStart+1450/600; % minEnd for entire simulation
%^to stop at certain timestep T, plotEnd=minStart+T/600
plotEnd=minEnd; % minEnd for entire simulation

inter=1:(plotEnd-plotStart)/Ts*60; %interval to plot over in seconds, may be a subset of the minStart to minEnd
checkPlotInter=max(inter)<=600/Ts % required, can only plot 10 min of 1s data

%inter=1:length(netLoadData)*10;
%inter=1:300-50;
%%
 
% Plot Q and Vmag
vmag_init_actual =[[0:60:(minEnd-minStart)*60]',repmat(vmag_new(2,:),minEnd-minStart+1,1)]; % extract voltage after run PF solver once, use this value to set relative Vref

%Plot inv commands qnew
%put in for loop if want diff control gains for diff nodes
    figure;     % same plot across phases
    hold on;
    plot(tidx(inter+1),qnew(tidx(inter+1),1),'r-','LineWidth',2);
    plot(tidx(inter+1),qnew(tidx(inter+1),2),'b-','LineWidth',2);
   % plot(tidx(inter+1),qnew(tidx(inter+1),3),'color',[0.9290 0.6940 0.1250],'LineWidth',2);
    %plot(t,repmat(qmin,[1,length(t)]),'k-.',t,repmat(qmax,[1,length(t)]),'k-.','LineWidth',2);
    %plot(s,qnew(s,1),'k.','MarkerSize',20);
    plot([Vmag_ctrlStart,Vmag_ctrlStart],get(gca,'ylim'),'k-');
    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Reactive Power (pu)');title('Q cmd at actuator node, (Qmcd) p.u.'); grid on; legend('Qa','Qb','Qc','Qmin','Qmax');  
    %txt2 = strcat('Sbase (pu)=',num2str(Sbase)); text(get(gca,'xlim')+[0 -1000], get(gca,'ylim'),txt2);
    %set(gca, 'XTick',1:60:(plotEnd-plotStart+1)*60, 'XTickLabel',plotStart:(plotEnd+1))        
    hold off;

% %Plot inverter outputs qact
% qinv=PQact(:,4:6);
% %put in for loop if want diff control gains for diff nodes
%     figure;     % same plot across phases
%     hold on;
%     plot(tidx(inter+1),qinv(tidx(inter+1),1),'r-','LineWidth',2);
%     plot(tidx(inter+1),qinv(tidx(inter+1),2),'b-','LineWidth',2);
%     plot(tidx(inter+1),qinv(tidx(inter+1),3),'color',[0.9290 0.6940 0.1250],'LineWidth',2);
%     %plot(t,repmat(qmin,[1,length(t)]),'k-.',t,repmat(qmax,[1,length(t)]),'k-.','LineWidth',2);
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
    plot(tidx(inter+1),vmag_new(tidx(inter+1),1),'r-',tidx(inter+1),vmag_ref_sig(tidx(inter+1),1),'r-.','LineWidth',2);
    plot(tidx(inter+1),vmag_new(tidx(inter+1),2),'b-',tidx(inter+1),vmag_ref_sig(tidx(inter+1),2),'b-.','LineWidth',2);
 %   plot(tidx(inter+1),vmag_new(tidx(inter+1),3),tidx(inter+1),vmag_ref_sig(tidx(inter+1),3),'-.','color',[0.9290 0.6940 0.1250],'LineWidth',2);
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
    %plot(t,repmat(vmin,[1,length(t)]),'k-.',t,repmat(vmax,[1,length(t)]),'k-.','LineWidth',2);
    plot([Vmag_ctrlStart,Vmag_ctrlStart],get(gca,'ylim'),'k-');

    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Voltage (pu)');title('Vmag at perf node'); grid on; legend('va','varef','vb','vbref','vc','vcref','ctrl start');  
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

% Plot inverter commands pnew
    figure;     % same plot across phases
    hold on;
    plot(tidx(inter+1),pnew(tidx(inter+1),1),'r-','LineWidth',2);
    plot(tidx(inter+1),pnew(tidx(inter+1),2),'b-','LineWidth',2);
  %  plot(tidx(inter+1),pnew(tidx(inter+1),3),'color',[0.9290 0.6940 0.1250],'LineWidth',2);
%     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),1),'b--','LineWidth',2);
%     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),2),'r--','LineWidth',2);
%     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),3),'g--','LineWidth',2);
    %plot(t,repmat(qmin,[1,length(t)]),'k-.',t,repmat(qmax,[1,length(t)]),'k-.','LineWidth',2);
    plot([Vang_ctrlStart,Vang_ctrlStart],get(gca,'ylim'),'k-');

    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Real Power (pu)');title('p cmd at actuator node'); grid on; legend('Pa','Pb','Pc','Pavail');
    %txt2 = strcat('Sbase (pu)=',num2str(Sbase)); text(get(gca,'xlim')+[0 -1000], get(gca,'ylim'),txt2);
    %set(gca, 'XTick',1:60:(minEnd-minStart+1)*60, 'XTickLabel',minStart:(minEnd+1))        

    hold off;

% %Plot inverter outputs pact
% pinv=PQact(:,1:3);
%     figure;     % same plot across phases
%     hold on;
%     plot(tidx(inter+1),pinv(tidx(inter+1),1),'r-','LineWidth',2);
%     plot(tidx(inter+1),pinv(tidx(inter+1),2),'b-','LineWidth',2);
%     plot(tidx(inter+1),pinv(tidx(inter+1),3),'color',[0.9290 0.6940 0.1250],'LineWidth',2);
% %     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),1),'b--','LineWidth',2);
% %     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),2),'r--','LineWidth',2);
% %     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),3),'g--','LineWidth',2);
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
    plot(tidx(inter+1),vang_new(tidx(inter+1),1),'r-',tidx(inter+1),vang_ref_sig(tidx(inter+1),1),'r-.','LineWidth',2);
    plot([Vang_ctrlStart,Vang_ctrlStart],get(gca,'ylim'),'k-');

    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec'));title('Vang at perf node'); grid on; legend('va','varef','ctrl start');  

    h2=subplot(3,1,2); hold on;
    plot(tidx(inter+1),vang_new(tidx(inter+1),2),'b-',tidx(inter+1),vang_ref_sig(tidx(inter+1),2),'b-.','LineWidth',2);
    plot([Vang_ctrlStart,Vang_ctrlStart],get(gca,'ylim'),'k-');

    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); title('Vang at perf node'); grid on; legend('vb','vbref','ctrl start');  

%     h3=subplot(3,1,3); hold on;
%     plot(tidx(inter+1),vang_new(tidx(inter+1),3),tidx(inter+1),vang_ref_sig(tidx(inter+1),3),'-.','color',[0.9290 0.6940 0.1250],'LineWidth',2);
%     plot([Vang_ctrlStart,Vang_ctrlStart],get(gca,'ylim'),'k-');
% 
%     xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec'));title('Vang at perf node'); grid on; legend('vc','vcref','ctrl start');  

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

%%