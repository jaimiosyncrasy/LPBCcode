%close all;
%% Plot
tidx=0:length(t); % t is cummulative timestep, tidx is integers for indexing
%FOR 1 NODE:
plotStart=minStart; %minute of the day, should not exceed timeEnd
plotEnd=minStart+5; 
inter=1:(plotEnd-plotStart)/Ts*60; %interval to plot over in seconds, may be a subset of the minStart to minEnd
checkPlotInter=max(inter)<=600/Ts % required, can only plot 10 min of 1s data
%%
 
% Plot Q and Vmag
vmag_init_actual =[[0:60:(minEnd-minStart)*60]',repmat(vmag_new(2,:),minEnd-minStart+1,1)]; % extract voltage after run PF solver once, use this value to set relative Vref

%Plot control inputs u
%put in for loop if want diff control gains for diff nodes
    figure;     % same plot across phases
    hold on;
    plot(tidx(inter+1),qnew(tidx(inter+1),1),'b-','LineWidth',2);
    plot(tidx(inter+1),qnew(tidx(inter+1),2),'r-','LineWidth',2);
    plot(tidx(inter+1),qnew(tidx(inter+1),3),'g-','LineWidth',2);
    %plot(t,repmat(qmin,[1,length(t)]),'k-.',t,repmat(qmax,[1,length(t)]),'k-.','LineWidth',2);
    %plot(s,qnew(s,1),'k.','MarkerSize',20);
    if (Vang_ctrl==true && Vang_ctrlStart>plotStart)
        plot([Vang_ctrlStart,Vang_ctrlStart],get(gca,'ylim'),'k-');
    end
%     if (Vmag_ctrl==true)
%         plot([Vmag_ctrlStart,Vmag_ctrlStart],get(gca,'ylim'),'k-');
%     end
    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Reactive Power (pu)');title('Q at actuator node'); grid on; legend('Qa','Qb','Qc','Qmin','Qmax');  
    txt2 = strcat('Sbase (kVA)=',num2str(Sbase)); text(get(gca,'xlim'), get(gca,'ylim'),txt2);
    %set(gca, 'XTick',1:60:(plotEnd-plotStart+1)*60, 'XTickLabel',plotStart:(plotEnd+1))        
    hold off;

% Plot outputs v
    figure;     % same plot across phases
    hold on;
    plot(tidx(inter+1),vmag_new(tidx(inter+1),1),'b-',tidx(inter+1),vmag_ref_sig(tidx(inter+1),1),'b-.','LineWidth',2);
    plot(tidx(inter+1),vmag_new(tidx(inter+1),2),'r-',tidx(inter+1),vmag_ref_sig(tidx(inter+1),2),'r-.','LineWidth',2);
    plot(tidx(inter+1),vmag_new(tidx(inter+1),3),'g-',tidx(inter+1),vmag_ref_sig(tidx(inter+1),3),'g-.','LineWidth',2);
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
    if (Vmag_ctrl==true && Vmag_ctrlStart>plotStart)
        plot([Vmag_ctrlStart,Vmag_ctrlStart],get(gca,'ylim'),'k-');%,[dbcStart,dbcStart],get(gca,'ylim'),'k');
    end
%     if (Vang_ctrl==true)
%         plot([Vang_ctrlStart,Vang_ctrlStart],get(gca,'ylim'),'m-');%,[dbcStart,dbcStart],get(gca,'ylim'),'k');
%     end
    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Voltage (pu)');title('Vmag at perf node'); grid on; legend('va','varef','vb','vbref','vc','vcref','ctrl start', 'ctrl start');  
    txt1 = strcat('perf node Vbase (V) =',num2str(V1base)); text(get(gca,'xlim'),get(gca,'ylim'),txt1);
    %set(gca, 'XTick',1:60:(minEnd-minStart+1)*60, 'XTickLabel',minStart:(minEnd+1))        
    %axis([0,max(inter+1),0.9,1.2]); % narrow axis to easier see one phase
    hold off;
    
%  maxDelU_vmag=max(max(abs(delta_u_vmag)))
%  maxU_vmag=max(max(abs(vmag_new)))

 %% Plot P and Vang
        a=[10 -130 130];
vang_init_actual =[[0:60:(minEnd-minStart)*60]',repmat(vang_new(2,:),minEnd-minStart+1,1)]; % extract voltage after run PF solver once, use this value to set relative Vref
% vmag_new(2,:) is 1x3

% Plot control inputs u
    figure;     % same plot across phases
    hold on;
    plot(tidx(inter+1),pnew(tidx(inter+1),1),'b-','LineWidth',2);
    plot(tidx(inter+1),pnew(tidx(inter+1),2),'r-','LineWidth',2);
    plot(tidx(inter+1),pnew(tidx(inter+1),3),'g-','LineWidth',2);
%     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),1),'b--','LineWidth',2);
%     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),2),'r--','LineWidth',2);
%     plot(tidx(inter+1),PTOD_sig(tidx(inter+1),3),'g--','LineWidth',2);
    %plot(t,repmat(qmin,[1,length(t)]),'k-.',t,repmat(qmax,[1,length(t)]),'k-.','LineWidth',2);
%     if (Vang_ctrl==true)
%         plot([Vang_ctrlStart,Vang_ctrlStart],get(gca,'ylim'),'m-');
%     end
    if (Vmag_ctrl==true && Vmag_ctrlStart>plotStart)
        plot([Vmag_ctrlStart,Vmag_ctrlStart],get(gca,'ylim'),'k-');%,[dbcStart,dbcStart],get(gca,'ylim'),'k');
    end
    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Real Power (pu)');title('p at actuator node'); grid on; legend('Pa','Pb','Pc','Pavail');
    txt2 = strcat('Sbase (kVA)=',num2str(Sbase)); text(get(gca,'xlim'), get(gca,'ylim'),txt2);
    %set(gca, 'XTick',1:60:(minEnd-minStart+1)*60, 'XTickLabel',minStart:(minEnd+1))        

    hold off;

%Plot outputs vang
    figure;     % same plot across phases
    hold on;
    plot(tidx(inter+1),vang_new(tidx(inter+1),1),'b-',tidx(inter+1),vang_ref_sig(tidx(inter+1),1),'b-.','LineWidth',2);
    plot(tidx(inter+1),vang_new(tidx(inter+1),2),'r-',tidx(inter+1),vang_ref_sig(tidx(inter+1),2),'r-.','LineWidth',2);
    plot(tidx(inter+1),vang_new(tidx(inter+1),3),'g-',tidx(inter+1),vang_ref_sig(tidx(inter+1),3),'g-.','LineWidth',2);
    %plot(t,repmat(vmin,[1,length(t)]),'k-.',t,repmat(vmax,[1,length(t)]),'k-.','LineWidth',2);
    if (Vmag_ctrl==true && Vmag_ctrlStart>plotStart)
        plot([Vmag_ctrlStart,Vmag_ctrlStart],get(gca,'ylim'),'k-');%,[dbcStart,dbcStart],get(gca,'ylim'),'k');
    end
%     if (Vang_ctrl==true && Vang_ctrlStart>plotStart)
%         plot([Vang_ctrlStart,Vang_ctrlStart],get(gca,'ylim'),'m-');%,[dbcStart,dbcStart],get(gca,'ylim'),'k');
%     end
    xlabel(strcat('timesteps,Ts=',num2str(Ts),'sec')); ylabel('Phase Angle (degrees)');title('Vang at perf node'); grid on; legend('va','varef','vb','vbref','vc','vcref','ctrl start', 'ctrl start');  
    txt1 = strcat('perf node Vbase (V) =',num2str(V2base)); text(get(gca,'xlim'),get(gca,'ylim'),txt1);
    %axis([min(tidx(inter+1)),max(tidx(inter+1)),-5,5]); % narrow axis to easier see one phase
    %set(gca, 'XTick',plotStart:60:(plotEnd-plotStart+1)*60, 'XTickLabel',minStart:(minEnd+1))        

    hold off;
    
%   maxDelU_vang=max(max(abs(delta_u_vang)))
%  maxU_vang=max(max(abs(vang_new)))
 
 %% Plot P vs. Q plots
% % minEnd-1 is largest value minIntime can be assigned 
%  minInTime=0 % the minute within the timeStart and timeEnd that you want to measure the 4-quadrant operation
%      secInterval=minInTime*60+1:minInTime*60+57;
%     Sbase=500; %kVA
%      Sinv=900;
%      [xcirc,ycirc]=circle(0,0,Sinv);
%     figure; plot(pnew(secInterval,1)*Sbase,qnew(secInterval,1)*Sbase,'b.',xcirc,ycirc,'k--','MarkerSize',15);
%     grid on; xlabel('Real power, kW'); ylabel('Reactive power, kVAR');  title(strcat('Min=',num2str(minStart),'Actuation across 57 seconds'));
% 
% disp('done plotting sim!');

% %% compute settling time from delta_vang and delta_vmag
% % for vang you cannot calculate a percentage because 0, 120, and -120 penalize percents differently
% %Vang
% settleStart=repmat([1:60:length(delta_vang)]',1,3);
% for ph=1:3 % across 3 phases
%     k=1;
%     for i=1:60:length(delta_vang)-1
%        j=i;
%        while abs(delta_vang(j,ph))>0.01 % increment settling time until control changes by less than 1 percent
%            j=j+1;
%        end
%         settleEnd(k,ph)=j;
%         k=k+1;
%     end
% end
% settleTimes=settleEnd-settleStart(1:end-1,:);
% 
% % Vmag
% % reduced settling time threshold to be 0.0001 instead of 0.01 because
% % setpoints might only shift by 0.0005
% settleStart=repmat([1:60:length(delta_vmag)]',1,3);
% for ph=1:3 % across 3 phases
%     k=1;
%     for i=1:60:length(delta_vmag)-1
%        j=i;
%        while abs(delta_vmag(j,ph)/vmag_ref_sig(i,ph))>0.0005 % increment settling time until control changes by less than 1 percent
%            j=j+1;
%        end
%         settleEnd(k,ph)=j;
%         k=k+1;
%     end
% end
% settleTimes=settleEnd-settleStart(1:end-1,:);
% 
% %% plot results
% figure; plot(1:length(settleStart)-1,settleTimes,'LineWidth',2); title(strcat('settling time across',num2str(minEnd-minStart), ' min of day')); ylabel('timesteps');xlabel('minute');legend('phA','phB','phC');
% nonzero=(settleTimes(settleTimes~=0));
% nonzeroA=(settleTimes(settleTimes(:,1)~=0)); mean(nonzeroA)
% nonzeroB=(settleTimes(settleTimes(:,2)~=0)); mean(nonzeroB)
% nonzeroC=(settleTimes(settleTimes(:,3)~=0)); mean(nonzeroC)
% figure; histogram(nonzero); title('Histogram of settling times'); 
% bins = linspace(0,50,20);
% figure; y1=hist(nonzeroA,bins); y2=hist(nonzeroB,bins); y3=hist(nonzeroC,bins);
% bar(y1.','facecolor',[0.3 0.7 0.2]); hold on; bar(y2.','facecolor',[0.3 0.7 0.2]); bar(y3.','facecolor',[0.7 0.7 0.2]);
