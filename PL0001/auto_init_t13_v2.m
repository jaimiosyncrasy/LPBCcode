%clear all
close all
clc
%{

Test 13: contains 1 performance node from user and random/all the nodes in the feeder for actuation
%}

[~, ~, raw_loads] = xlsread('PL0001_OPAL_working_simple.xlsx', 'Multiphase Load');
[~, ~, raw_bus] = xlsread('PL0001_OPAL_working_simple.xlsx', 'Bus');

%%
Total_Loads = size(raw_loads,1)-1;

%% User Inputs:
FeederName = 'PL0001'; % not used just for reference
PerformanceNode = '300020414';

%Number of random nodes:
Num_Aq_Nodes = 13; % you choose
%Num_Aq_Nodes = Total_Loads; %use this to select all the loads for actuation

%% Auto processing
Aq_Nodes = sort(randperm(Total_Loads,Num_Aq_Nodes)); % list of actuation node IDs
%find the performance node information in the multiphase Load
busList=raw_bus(:,1); % 1st col of bus tab
busNumList=cell(length(busList)-1,1);
for j=1:length(busList)-1
    busNumList{j}=busList{j+1}(3:end-2); % extract the bus numbers without N_ and _A/B/C
end
%find performance node in the bus tab
PerfBus_loc =find(ismember(busNumList,PerformanceNode)); % for all 3 phases
%PerfBus_loc = find (contains(raw_bus(:,1),strcat('N_',PerformanceNode)));
if isempty(PerfBus_loc)
    error('couldnt find performance node in bus list, PerfBus_loc empty');
end

Pbuses = raw_bus(PerfBus_loc+1,1) % perf node buses
for i = 1:length(PerfBus_loc)
    %Phs_perfNode{i} = extractAfter(Pbuses{i},strcat('N_',PerformanceNode,'_'));
    Phs_perfNode{i}=Pbuses{i}(end); % extract the phase of perf node (A, B, or C)
end
Phs_perfNode

Perf_Cell='';
P_Cell='';
Q_Cell='';
H_indices = '';
all_Aq_Phs='';
count = 0;
for i = 1:length(Aq_Nodes)
    
    id = Aq_Nodes(i)+1; % 1 offset for heading
    
    if isnan(raw_loads{id,3})
        Aq_IDs = raw_loads(id,1:2);
    elseif isnan(raw_loads{id,2})
        Aq_IDs = raw_loads(id,1);
    else
        Aq_IDs = raw_loads(id,1:3);
    end
    disp('-----------------------');
    Aq_IDs
    % Aq_IDs is the current actuator node
    clear k; clear Aq_Phs
    for k=1:length(Aq_IDs)
        Aq_Phs(k)=Aq_IDs{k}(end);
    end
    Aq_Phs
    all_Aq_Phs=strcat(all_Aq_Phs,Aq_Phs);
    
    cnt_aq=0;
    for j = 1:length(Phs_perfNode)

        %Aq_PhsNum = find(contains(Aq_IDs,strcat('_',Phs_perfNode{j})));
        Aq_PhsNum =find(ismember(Aq_Phs,Phs_perfNode{j})); % for all 3 phases
        if isempty(Aq_PhsNum )
            disp('act node has less phases than perf node ');
        end
        if ~isempty(Aq_PhsNum)
            count = count + 1;
            cnt_aq = cnt_aq+1;
            foo=Aq_IDs{cnt_aq}(3:end-2);
            %P_Cell = strcat(P_Cell,',', extractBetween(Aq_IDs{cnt_aq},'N_','_'),'/P',num2str(Aq_PhsNum));
            %Q_Cell = strcat(Q_Cell,',', extractBetween(Aq_IDs{cnt_aq},'N_','_'),'/Q',num2str(Aq_PhsNum));
            P_Cell = strcat(P_Cell,',', foo,'/P',num2str(Aq_PhsNum));
            Q_Cell = strcat(Q_Cell,',', foo,'/Q',num2str(Aq_PhsNum));
            Perf_Cell = strcat(Perf_Cell,',',PerformanceNode,'_',Phs_perfNode{j});
            H_indices = strcat(H_indices,',',num2str(count));
        end
    end
    
    

end

% Perf_Cell = strip(Perf_Cell,'left',',');
% P_Cell = strip(P_Cell,'left',',');
% Q_Cell = strip(Q_Cell,'left',',');
% H_indices = strip(H_indices,'left',',');
Perf_Cell=Perf_Cell(2:end) ;% remove , from beginning
P_Cell=P_Cell(2:end) ;% remove , from beginning
Q_Cell=Q_Cell(2:end) ;% remove , from beginning
H_indices=H_indices(2:end) ;% remove , from beginning

Act_Cell = strcat(P_Cell,',', Q_Cell);

dataWrite(1,:) = {'tenNode_13',3,0.5,'14:00-14:05','test_13.mat',Perf_Cell,Act_Cell,H_indices,'',100000,'','','','','',1};


xlswrite('init_tests_auto.xlsx',dataWrite,'Sheet1','A5');
disp('done writing init file row!');

%% Generate associated vmag and vang target vectors
all_Aq_Phs
vmag_vals=[0.97 0.98 0.99];
vang_vals=[0-2 -120-2 120+2];
vang_nomvals=[0 -120 120];

for j=1:length(all_Aq_Phs)
    if (all_Aq_Phs(j)=='A')
        vmag_tar(j)=vmag_vals(1);
        vang_tar(j)=vang_vals(1);
        vang_nom(j)=vang_nomvals(1);
    elseif (all_Aq_Phs(j)=='B')
        vmag_tar(j)=vmag_vals(2);
        vang_tar(j)=vang_vals(2);
        vang_nom(j)=vang_nomvals(2);
    else
        vmag_tar(j)=vmag_vals(3);
        vang_tar(j)=vang_vals(3);
        vang_nom(j)=vang_nomvals(3);
    end
end

%copy and paste into set_const_target
num2str(vmag_tar)
num2str(vang_tar)
num2str(vang_nom)