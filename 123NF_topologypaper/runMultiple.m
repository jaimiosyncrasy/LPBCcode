mode=1;
test_num=21;
driver_runDailySim


%% output results
disp('------------------- Outputing results...');

% save data into .mats
if mode==1
    plot_dir=strcat('results/test',num2str(test_num),'_fixed_plots');
    mkdir(plot_dir)
    save(strcat('results/test',num2str(test_num),'_fixed_plots/test',num2str(test_num),'_fixed_9.18.mat'),'simTimestamps','gain_sched','ss_vall','ss_v','ss_del','ss_p','ss_q','gain_sched_simulated','ss_vref','ss_delref','int_vviol');
elseif mode==2
    plot_dir=strcat('results/test',num2str(test_num),'_adjust_plots');
    mkdir(plot_dir)
    save(strcat('results/test',num2str(test_num),'_adjust_plots/test',num2str(test_num),'_adjust_9.18.mat'),'simTimestamps','gain_sched','ss_vall','ss_v','ss_del','ss_p','ss_q','gain_sched_simulated','ss_vref','ss_delref','int_vviol');
end
disp('saving figs..')
save_all_figs(plot_dir,[])

%%
mode=2;
test_num=21;
driver_runDailySim


%% output results
disp('------------------- Outputing results...');

% save data into .mats
if mode==1
    plot_dir=strcat('results/test',num2str(test_num),'_fixed_plots');
    mkdir(plot_dir)
    save(strcat('results/test',num2str(test_num),'_fixed_plots/test',num2str(test_num),'_fixed_9.18.mat'),'simTimestamps','gain_sched','ss_vall','ss_v','ss_del','ss_p','ss_q','gain_sched_simulated','ss_vref','ss_delref','int_vviol');
elseif mode==2
    plot_dir=strcat('results/test',num2str(test_num),'_adjust_plots');
    mkdir(plot_dir)
    save(strcat('results/test',num2str(test_num),'_adjust_plots/test',num2str(test_num),'_adjust_9.18.mat'),'simTimestamps','gain_sched','ss_vall','ss_v','ss_del','ss_p','ss_q','gain_sched_simulated','ss_vref','ss_delref','int_vviol');
end
disp('saving figs..')
save_all_figs(plot_dir,[])

