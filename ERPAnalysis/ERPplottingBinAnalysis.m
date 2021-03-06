%EEG ERP plotter functions

load chanlocs256.mat

direc = uigetdir;
folders = dir(direc);
id = {folders([folders(:).isdir]).name};
id(ismember(id,{'.','..'})) = [];


ERPavg = zeros(size(id,2),19,256,512); %% ERIC!! CHANGE SO ADAPTABLE!!!! MUCH WORK


for i = 1:size(id,2)
    
    load(fullfile(direc,id{i},[id{i},'_erp'],[id{i},'.mat']),'ERPs','RTs','t');

    % Avgerage across
    for j = 1:12  %% ERIC, NEEDS BE MADE ADAPTABLE, LOOP FOR TRIGGER VALUES
       ERPavg(i,j,:,:) = mean(ERPs{j}.data,3); %3 is an indexing thing in the data structure
    end
    ERPavg(i,13,:,:)=ERPavg(i,1,:,:)+ERPavg(i,2,:,:); %pure audio plus visual
    ERPavg(i,14,:,:)=ERPavg(i,6,:,:)+ERPavg(i,7,:,:); %repeat audio plus visual
    ERPavg(i,15,:,:)=ERPavg(i,9,:,:)+ERPavg(i,4,:,:); %switch audio plus visual
    ERPavg(i,16,:,:)=mean(cat(3,(ERPs{10}.data(:,:,(1:2:size(ERPs{10}.data,3)))),(ERPs{12}.data(:,:,(1:2:size(ERPs{12}.data,3))))),3); % 50% sample from A->AV combined with 50% sample from V->AV to not double sample set size
    ERPavg(i,17,:,:)=ERPavg(i,13,:,:)-ERPavg(i,3,:,:); %pure difference wave for (A+V)-AV
    ERPavg(i,18,:,:)=ERPavg(i,14,:,:)-ERPavg(i,11,:,:); %repeat difference wave for (A+V)-AV
    ERPavg(i,19,:,:)=ERPavg(i,15,:,:)-ERPavg(i,16,:,:); %switch difference wave for (A+V)-AV 
    clear ERPs RTs
    
end

erpPlot = squeeze(mean(ERPavg,1));
erpErr = squeeze(std(ERPavg,1))/sqrt(16); %16=number of subjects. do change accordingly.

for i = 1:length(chanlocs)
    chans{i} = chanlocs(i).labels;
end

% Bin #1 V-V < A-V
bin1indxs = [1 4 6 7 10 11 12 13 15 16]; %participant indeces. Ordered based on numerical order. 
ERPavg1 = ERPavg(bin1indxs, :, :, :);
erpPlot1 = squeeze(mean(ERPavg1,1));
erpErr1 = squeeze(std(ERPavg1,1))/sqrt(numel(bin1indxs));


% Bin #2 A-A < V-A
bin2indxs = [2 4 6 7 8 9 10 11 12 16];
ERPavg2 = ERPavg(bin2indxs, :, :, :);
erpPlot2 = squeeze(mean(ERPavg2, 1));
erpErr2 = squeeze(std(ERPavg2,1))/sqrt(numel(bin2indxs));


% Bin #3 V-V = A-V
bin3indxs = [5 14];
ERPavg3 = ERPavg(bin3indxs, :, :, :);
erpPlot3 = squeeze(mean(ERPavg3, 1));
erpErr3 = squeeze(std(ERPavg3,1))/sqrt(numel(bin3indxs));


% Bin #4 A-A = V-A
bin4indxs = [1 3 5 15];
ERPavg4 = ERPavg(bin4indxs, :, :, :);
erpPlot4 = squeeze(mean(ERPavg4, 1));
erpErr4 = squeeze(std(ERPavg4,1))/sqrt(numel(bin4indxs));


% Bin #A 2 people from V-V < V-A
binAindxs = [1 4];
ERPavgA = ERPavg(binAindxs, :, :, :);
erpPlotA = squeeze(mean(ERPavgA, 1));
erpErrA = squeeze(std(ERPavgA,1))/sqrt(numel(binAindxs));
%% Plot function A - New figure for each channel, n-conditions on plot.
trange = [-50 300];

electrodes = {'D10'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [6 4 5];

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    figure;

    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot2(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
end
%% Plot function #1.1 - One channel. Post & Pre-Bin, n-conditions on plot. Bin1 - V-V < A-V
binTitle = 'All Individuals With Statistically Significant & Near Significant Visual Switch Costs';
trange = [-50 300];

electrodes = {'A19'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [7 9 8];
condsLegend = {'V-V', 'A-V', 'AV-V'};
for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    figure;
    subplot(1,2,1)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title('All Individuals');
    
end

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    subplot(1,2,2)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot1(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title(binTitle);
    
end
 text(335,-.3,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
 text(335,0,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
 text(335,.3,strjoin(condsLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
  %% Plot function #1.2 - One channel. Post & Pre Bin. One condition per figure. Bin #1 - V-V < A-V
trange = [-50 300];

electrodes = {'A19'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [7 9 8];
condsLegend = {'V-V', 'A-V', 'AV-V'};
for i = 1:length(electrodes)
    for condIndx = 1:length(conds)
    condTitle = strjoin(condsLegend(condIndx));
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    figure;
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:1
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(condIndx),es(i),:)),'LineWidth',2);
        plot(t,squeeze(erpPlot1(conds(condIndx),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title(condTitle);
    end 
    
end

%% Plot function #2.1 - One channel on a figure, but one after binning and the other before binning, n-conditions on plot.
binTitle = 'All Individuals With Statistically Significant & Near Significant Auditory Switch Costs';
trange = [-50 300];

electrodes = {'D10'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [6 4 5 1];
condsLegend = {'A-A', 'V-A', 'AV-A', 'Pure A'};
for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    figure;
    subplot(1,2,1)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title('All Individuals');
    
end

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    subplot(1,2,2)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot2(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title(binTitle);
    
end
 text(335,-.3,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
 text(335,0,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
 text(335,.3,strjoin(condsLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
 text(335,.6,strjoin(condsLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
 %% Plot function #2.2 - One channel on a figure, but one after binning and the other before binning, for one channel only
trange = [-50 300];

electrodes = {'D10'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [6 4 5];
condsLegend = {'A-A', 'V-A', 'AV-A'};
for i = 1:length(electrodes)
    for condIndx = 1:length(conds)
    condTitle = strjoin(condsLegend(condIndx));
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    figure;
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:1
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(condIndx),es(i),:)),'LineWidth',2);
        plot(t,squeeze(erpPlot2(conds(condIndx),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title(condTitle);
    end 
    
end

%% Plot function #3.1 - One channel on a figure. All Indivs, Bin1, Bin3, n-conditions on plot.
bin1Title = 'Individuals With Statistically Significant Visual Switch Costs';
bin3Title = 'Individuals With No Visual Switch Costs';
trange = [-50 300];

electrodes = {'A20'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [7 9 8 2];
condsLegend = {'V-V', 'A-V', 'AV-V', 'Pure V'};
for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 7.5];
    figure;
    subplot(1,3,1)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title('All Individuals');
    
end

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 7.5];
    subplot(1,3,2)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot1(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title(bin1Title);
    
end

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 7.5];
    subplot(1,3,3)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot3(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title(bin3Title);
    
end
 text(335,-.3,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
 text(335,0,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
 text(335,.3,strjoin(condsLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
 text(335,.6,strjoin(condsLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
 
 %% Plot function #3.2 - many channels on a figure. All Indivs, Bin1, Bin3, n-conditions on plot.
bin1Title = 'Individuals With Statistically Significant Visual Switch Costs';
bin3Title = 'Individuals With No Visual Switch Costs';
trange = [-50 350];

electrodes = {'A15', 'A16', 'A32'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [7 9 8 2];
condsLegend = {'V-V', 'A-V', 'AV-V', 'Pure V'};
figure;
for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    subplot(numel(electrodes),3,3*(i-1) + 1)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title('All Individuals');
    
end

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    subplot(numel(electrodes),3,3*(i-1) + 2)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot1(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title(bin1Title);
    
end

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    subplot(numel(electrodes),3,3*(i-1) + 3)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot3(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title(bin3Title);
    
end
 text(335,-.3,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
 text(335,0,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
 text(335,.3,strjoin(condsLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
 text(335,.6,strjoin(condsLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
 %% Plot function #3.3 - intrabin. many channels on a figure. All Indivs, Bin1, Bin3, n-conditions on plot. Loops to create many figures

Outdir = uigetdir('C:\Users\achen52\Documents\SMART\bins\Outputs\','Select Output Directory for the Graphs!'); 
 
bin1Title = 'Individuals With Statistically Significant Visual Switch Costs';
bin3Title = 'Individuals With No Visual Switch Costs';
trange = [-50 350];

numberSets = 9;
electrodes = {'A7','A6','A24';'A8','A23','A25';'A9','A22','A26';'A10','A21','A27';'A11','A20','A28';'A12','A19','A29';'A13','A18','A30';'A14','A17','A31';'A15','A16','A32'};
for i = 1:size(electrodes, 2)
    for j = 1:size(electrodes, 1)
        es(j,i) = find(strcmp(electrodes{j,i},chans));
    end
end

conds = [7 9 8 2];
condsLegend = {'V-V', 'A-V', 'AV-V', 'Pure V'};

for Set = 1:numberSets
    Hfig = figure;
    for i = 1:size(electrodes,2)
        %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
        ys = [-5 5.5];
        subplot(size(electrodes,2),3,3*(i-1) + 1)
        plot([0,0],ys,'--k '); hold on;
        plot(trange,[0 0],'--k');
        for j = 1:length(conds)
            %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
            plot(t,squeeze(erpPlot(conds(j),es(Set,i),:)),'LineWidth',2);
        end
        
        text(mean(trange),ys(2),electrodes{Set, i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
        
        set(gca,'ylim',ys,'xlim',trange)
        title('All Individuals');   
    end
    
    for i = 1:size(electrodes,2)
        %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
        ys = [-5 5.5];
        subplot(size(electrodes,2),3,3*(i-1) + 2)
        plot([0,0],ys,'--k '); hold on;
        plot(trange,[0 0],'--k');
        for j = 1:length(conds)
            %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
            plot(t,squeeze(erpPlot1(conds(j),es(Set,i),:)),'LineWidth',2);
        end
        
        text(mean(trange),ys(2),electrodes{Set, i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
        
        set(gca,'ylim',ys,'xlim',trange)
        title(bin1Title);
        
    end
    
    for i = 1:size(electrodes,2)
        %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
        ys = [-5 5.5];
        subplot(size(electrodes,2),3,3*(i-1) + 3)
        plot([0,0],ys,'--k '); hold on;
        plot(trange,[0 0],'--k');
        for j = 1:length(conds)
            %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
            plot(t,squeeze(erpPlot3(conds(j),es(Set,i),:)),'LineWidth',2);
        end
        
        text(mean(trange),ys(2),electrodes{Set, i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
        
        set(gca,'ylim',ys,'xlim',trange)
        title(bin3Title);
        
    end
    text(400,14,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
    text(400,15,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    text(400,13,strjoin(condsLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    text(400,16,strjoin(condsLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    set(gcf, 'Position', [0, 0, 1920, 1080]);
    savefig(Hfig, strcat(Outdir,'\VisualBins_',strjoin(electrodes(Set,:),'_'),'.fig'));
    saveas(Hfig, strcat(Outdir,'\VisualBins_',strjoin(electrodes(Set,:),'_'),'.png'));
end
 %% Plot function #3.3E - intrabin. many channels on a figure. All Indivs, Bin1, Bin3, n-conditions on plot. Loops to create many figures. E - Includes SEM shadow

Outdir = uigetdir('C:\Users\achen52\Documents\SMART\bins\Outputs\','Select Output Directory for the Graphs!'); 
 
bin1Title = 'Individuals With Statistically Significant Visual Switch Costs';
bin3Title = 'Individuals With No Visual Switch Costs';
trange = [-50 350];

%numberSets = 9;
numberSets = 10;
%electrodes = {'A7','A6','A24';'A8','A23','A25';'A9','A22','A26';'A10','A21','A27';'A11','A20','A28';'A12','A19','A29';'A13','A18','A30';'A14','A17','A31';'A15','A16','A32'};
electrodes = {'E28','E12','E11';'E27','E13','E10';'E26','E14','E9';'E25','E15','E8';'E24','E16','E7';'E23','E17','E6';'E22','E18','E19';'F3','E21','E20';'E3','F2','E1';'E2','F1','D1'};
for i = 1:size(electrodes, 2)
    for j = 1:size(electrodes, 1)
        es(j,i) = find(strcmp(electrodes{j,i},chans));
    end
end

%conds = [7 9 8 2];
conds = [7 9];
condsLegend = {'V-V', 'A-V'};

for Set = 1:numberSets
    Hfig = figure;
    for i = 1:size(electrodes,2)
        %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
        ys = [-5 5.5];
        subplot(size(electrodes,2),3,3*(i-1) + 1)
        plot([0,0],ys,'--k '); hold on;
        plot(trange,[0 0],'--k');
        for j = 1:length(conds)
            patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(Set,i),:)+erpErr(conds(j),es(Set,i),:))' fliplr(squeeze(erpPlot(conds(j),es(Set,i),:)-erpErr(conds(j),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
            plot(t,squeeze(erpPlot(conds(j),es(Set,i),:)),'LineWidth',2);
        end
        
        text(mean(trange),ys(2),electrodes{Set, i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
        
        set(gca,'ylim',ys,'xlim',trange)
        title('All Individuals');   
    end
    
    for i = 1:size(electrodes,2)
        %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
        ys = [-5 5.5];
        subplot(size(electrodes,2),3,3*(i-1) + 2)
        plot([0,0],ys,'--k '); hold on;
        plot(trange,[0 0],'--k');
        for j = 1:length(conds)
            patch([t fliplr(t)],[squeeze(erpPlot1(conds(j),es(Set,i),:)+erpErr1(conds(j),es(Set,i),:))' fliplr(squeeze(erpPlot1(conds(j),es(Set,i),:)-erpErr1(conds(j),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
            plot(t,squeeze(erpPlot1(conds(j),es(Set,i),:)),'LineWidth',2);
        end
        
        text(mean(trange),ys(2),electrodes{Set, i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
        
        set(gca,'ylim',ys,'xlim',trange)
        title(bin1Title);
        
    end
    
    for i = 1:size(electrodes,2)
        %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
        ys = [-5 5.5];
        subplot(size(electrodes,2),3,3*(i-1) + 3)
        plot([0,0],ys,'--k '); hold on;
        plot(trange,[0 0],'--k');
        for j = 1:length(conds)
            patch([t fliplr(t)],[squeeze(erpPlot3(conds(j),es(Set,i),:)+erpErr3(conds(j),es(Set,i),:))' fliplr(squeeze(erpPlot3(conds(j),es(Set,i),:)-erpErr3(conds(j),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
            plot(t,squeeze(erpPlot3(conds(j),es(Set,i),:)),'LineWidth',2);
        end
        
        text(mean(trange),ys(2),electrodes{Set, i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
        
        set(gca,'ylim',ys,'xlim',trange)
        title(bin3Title);
        
    end
    text(400,14,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
    text(400,15,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    %text(400,13,strjoin(condsLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    %text(400,16,strjoin(condsLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    set(gcf, 'Position', [0, 0, 1920, 1080]);
    savefig(Hfig, strcat(Outdir,'\VisualBins_SEM',strjoin(electrodes(Set,:),'_'),'.fig'));
    saveas(Hfig, strcat(Outdir,'\VisualBins_SEM',strjoin(electrodes(Set,:),'_'),'.png'));
end
 %% Plot function #3.4 - One channel on a figure. All Individuals, bin 1 & bin3. n subplots for n conditions 
trange = [-50 300];

Outdir = uigetdir('C:\Users\achen52\Documents\SMART\bins\Outputs\','Select Output Directory for the Graphs!'); 

numberSets = 9;
electrodes = {'A7','A6','A24';'A8','A23','A25';'A9','A22','A26';'A10','A21','A27';'A11','A20','A28';'A12','A19','A29';'A13','A18','A30';'A14','A17','A31';'A15','A16','A32'};
for i = 1:size(electrodes, 2)
    for j = 1:size(electrodes, 1)
        es(j,i) = find(strcmp(electrodes{j,i},chans));
    end
end

conds = [7 9 8];
condsLegend = {'V-V', 'A-V', 'AV-V'};
subplotLegend = {'All Individuals','Significant Visual Switch Costs', 'No Visual Switch Costs'};
for Set = 1:numberSets
    Hfig = figure;
    for i = 1:size(electrodes,2)       
        for condIndx = 1:length(conds)
            condTitle = strjoin(condsLegend(condIndx));
            %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
            ys = [-5 5.5];
            %subplot(1,length(conds),condIndx);
            subplot(size(electrodes,2), length(conds), 3 *(i-1) + condIndx)
            plot([0,0],ys,'--k '); hold on;
            plot(trange,[0 0],'--k');
            for j = 1:1
                %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(Set,i),:)+erpErr(conds(j),es(Set,i),:))' fliplr(squeeze(erpPlot(conds(j),es(Set,i),:)-erpErr(conds(j),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
                plot(t,squeeze(erpPlot(conds(condIndx),es(Set,i),:)),'LineWidth',2);
                plot(t,squeeze(erpPlot1(conds(condIndx),es(Set,i),:)),'LineWidth',2);
                plot(t,squeeze(erpPlot3(conds(condIndx),es(Set,i),:)),'LineWidth',2);
            end
            
            text(mean(trange),ys(2),electrodes{Set,i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
            
            set(gca,'ylim',ys,'xlim',trange)
            title(condTitle);
        end
    end
    set(gcf, 'Position', [0, 0, 1920, 1080]);
    text(305,15,strjoin(subplotLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
    text(305,16,strjoin(subplotLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    text(305,14,strjoin(subplotLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    %text(400,16,strjoin(condsLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    savefig(Hfig, strcat(Outdir,'\VisualBins_intracond_',strjoin(electrodes(Set,:),'_'),'.fig'));
    saveas(Hfig, strcat(Outdir,'\VisualBins_intracond_',strjoin(electrodes(Set,:),'_'),'.png'));
end
%% Plot function #3.4E - Many channels on a figure. All Individuals, bin 1 & bin3. n subplots for n conditions 
trange = [-50 300];

Outdir = uigetdir('C:\Users\achen52\Documents\SMART\bins\Outputs\','Select Output Directory for the Graphs!'); 

numberSets = 9;
electrodes = {'A7','A6','A24';'A8','A23','A25';'A9','A22','A26';'A10','A21','A27';'A11','A20','A28';'A12','A19','A29';'A13','A18','A30';'A14','A17','A31';'A15','A16','A32'};
for i = 1:size(electrodes, 2)
    for j = 1:size(electrodes, 1)
        es(j,i) = find(strcmp(electrodes{j,i},chans));
    end
end

conds = [7 9 8];
condsLegend = {'V-V', 'A-V', 'AV-V'};
subplotLegend = {'All Individuals','Significant Visual Switch Costs', 'No Visual Switch Costs'};
for Set = 1:numberSets
    Hfig = figure;
    for i = 1:size(electrodes,2)       
        for condIndx = 1:length(conds)
            condTitle = strjoin(condsLegend(condIndx));
            %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
            ys = [-5 5.5];
            %subplot(1,length(conds),condIndx);
            subplot(size(electrodes,2), length(conds), 3 *(i-1) + condIndx)
            plot([0,0],ys,'--k '); hold on;
            plot(trange,[0 0],'--k');
            for j = 1:1
                patch([t fliplr(t)],[squeeze(erpPlot(conds(condIndx),es(Set,i),:)+erpErr(conds(condIndx),es(Set,i),:))' fliplr(squeeze(erpPlot(conds(condIndx),es(Set,i),:)-erpErr(conds(condIndx),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
                patch([t fliplr(t)],[squeeze(erpPlot1(conds(condIndx),es(Set,i),:)+erpErr1(conds(condIndx),es(Set,i),:))' fliplr(squeeze(erpPlot1(conds(condIndx),es(Set,i),:)-erpErr1(conds(condIndx),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
                patch([t fliplr(t)],[squeeze(erpPlot3(conds(condIndx),es(Set,i),:)+erpErr3(conds(condIndx),es(Set,i),:))' fliplr(squeeze(erpPlot3(conds(condIndx),es(Set,i),:)-erpErr3(conds(condIndx),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
                plot(t,squeeze(erpPlot(conds(condIndx),es(Set,i),:)),'LineWidth',2);
                plot(t,squeeze(erpPlot1(conds(condIndx),es(Set,i),:)),'LineWidth',2);
                plot(t,squeeze(erpPlot3(conds(condIndx),es(Set,i),:)),'LineWidth',2);
            end
            
            text(mean(trange),ys(2),electrodes{Set,i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
            
            set(gca,'ylim',ys,'xlim',trange)
            title(condTitle);
        end
    end
    set(gcf, 'Position', [0, 0, 1920, 1080]);
    text(305,15,strjoin(subplotLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
    text(305,16,strjoin(subplotLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    text(305,14,strjoin(subplotLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    %text(400,16,strjoin(condsLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    savefig(Hfig, strcat(Outdir,'\VisualBins_intracond_',strjoin(electrodes(Set,:),'_'),'.fig'));
    saveas(Hfig, strcat(Outdir,'\VisualBins_intracond_',strjoin(electrodes(Set,:),'_'),'.png'));
end

 %% Plot function #3.A - One channel on a figure. All Individuals, bin 1 & bin3. n subplots for n conditions 
trange = [-50 300];

Outdir = uigetdir('C:\Users\achen52\Documents\SMART\bins\Outputs\','Select Output Directory for the Graphs!'); 

numberSets = 9;
electrodes = {'A7','A6','A24';'A8','A23','A25';'A9','A22','A26';'A10','A21','A27';'A11','A20','A28';'A12','A19','A29';'A13','A18','A30';'A14','A17','A31';'A15','A16','A32'};
for i = 1:size(electrodes, 2)
    for j = 1:size(electrodes, 1)
        es(j,i) = find(strcmp(electrodes{j,i},chans));
    end
end

conds = [7 9 8];
condsLegend = {'V-V', 'A-V', 'AV-V'};
subplotLegend = {'All Individuals','Significant Visual Switch Costs', 'No Visual Switch Costs', 'Significant VSC n=2'};
for Set = 1:numberSets
    Hfig = figure;
    for i = 1:size(electrodes,2)       
        for condIndx = 1:length(conds)
            condTitle = strjoin(condsLegend(condIndx));
            %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
            ys = [-5 5.5];
            %subplot(1,length(conds),condIndx);
            subplot(size(electrodes,2), length(conds), 3 *(i-1) + condIndx)
            plot([0,0],ys,'--k '); hold on;
            plot(trange,[0 0],'--k');
            for j = 1:1
                %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
                plot(t,squeeze(erpPlot(conds(condIndx),es(Set,i),:)),'LineWidth',2);
                plot(t,squeeze(erpPlot1(conds(condIndx),es(Set,i),:)),'LineWidth',2);
                plot(t,squeeze(erpPlot3(conds(condIndx),es(Set,i),:)),'LineWidth',2);
                plot(t,squeeze(erpPlotA(conds(condIndx),es(Set,i),:)),'LineWidth',2);
            end
            
            text(mean(trange),ys(2),electrodes{Set,i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
            
            set(gca,'ylim',ys,'xlim',trange)
            title(condTitle);
        end
    end
    set(gcf, 'Position', [0, 0, 1920, 1080]);
    text(305,15,strjoin(subplotLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
    text(305,16,strjoin(subplotLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    text(305,14,strjoin(subplotLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    text(305,13,strjoin(subplotLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    savefig(Hfig, strcat(Outdir,'\VisualBins_intracond_',strjoin(electrodes(Set,:),'_'),'.fig'));
    saveas(Hfig, strcat(Outdir,'\VisualBins_intracond_',strjoin(electrodes(Set,:),'_'),'.png'));
end


%% Plot function #4.1 - One channel on a figure. All Indivs, Bin2, Bin4, n-conditions on plot.
bin2Title = 'Individuals With Statistically Significant Auditory Switch Costs';
bin4Title = 'Individuals With No Auditory Switch Costs';
trange = [-50 300];

electrodes = {'D10'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [6 4 5 1];
condsLegend = {'A-A', 'V-A', 'AV-A', 'Pure A'};
for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    figure;
    subplot(1,3,1)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title('All Individuals');
    
end

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    subplot(1,3,2)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot2(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title(bin2Title);
    
end

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    subplot(1,3,3)
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot4(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    title(bin4Title);
    
end
 text(335,-.3,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
 text(335,0,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
 text(335,.3,strjoin(condsLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
  text(335,.6,strjoin(condsLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
  
%% Plot function #4.3 - many channels on a figure. All Indivs, Bin1, Bin3, n-conditions on plot. Loops to create many figures

Outdir = uigetdir('C:\Users\achen52\Documents\SMART\bins\Outputs\','Select Output Directory for the Graphs!'); 
 
bin1Title = 'Individuals With Statistically Significant Auditory Switch Costs';
bin3Title = 'Individuals With No Auditory Switch Costs';
trange = [-50 350];

%numberSets = 9;
numberSets = 10;
%electrodes = {'D23','D11','D10';'D22','D12','D9';'D21','D13','D8';'D20','D14','D7';'D19','D15','D6';'D18','D16','C28';'D17','D5','C27';'C32','C31','C30';'C29','C22','C23'};
electrodes = {'E28','E12','E11';'E27','E13','E10';'E26','E14','E9';'E25','E15','E8';'E24','E16','E7';'E23','E17','E6';'E22','E18','E19';'F3','E21','E20';'E3','F2','E1';'E2','F1','D1'};
for i = 1:size(electrodes, 2)
    for j = 1:size(electrodes, 1)
        es(j,i) = find(strcmp(electrodes{j,i},chans));
    end
end

%conds = [6 4 5 1];
conds = [6 4];
condsLegend = {'A-A', 'V-A'};
%condsLegend = {'A-A', 'V-A', 'AV-A', 'Pure A'};

for Set = 1:numberSets
    Hfig = figure;
    for i = 1:size(electrodes,2)
        %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
        ys = [-5 5.5];
        subplot(size(electrodes,2),3,3*(i-1) + 1)
        plot([0,0],ys,'--k '); hold on;
        plot(trange,[0 0],'--k');
        for j = 1:length(conds)
            patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(Set,i),:)+erpErr(conds(j),es(Set,i),:))' fliplr(squeeze(erpPlot(conds(j),es(Set,i),:)-erpErr(conds(j),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
            plot(t,squeeze(erpPlot(conds(j),es(Set,i),:)),'LineWidth',2);
        end
        
        text(mean(trange),ys(2),electrodes{Set, i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
        
        set(gca,'ylim',ys,'xlim',trange)
        title('All Individuals');   
    end
    
    for i = 1:size(electrodes,2)
        %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
        ys = [-5 5.5];
        subplot(size(electrodes,2),3,3*(i-1) + 2)
        plot([0,0],ys,'--k '); hold on;
        plot(trange,[0 0],'--k');
        for j = 1:length(conds)
            patch([t fliplr(t)],[squeeze(erpPlot2(conds(j),es(Set,i),:)+erpErr2(conds(j),es(Set,i),:))' fliplr(squeeze(erpPlot2(conds(j),es(Set,i),:)-erpErr2(conds(j),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
            plot(t,squeeze(erpPlot2(conds(j),es(Set,i),:)),'LineWidth',2);
        end
        
        text(mean(trange),ys(2),electrodes{Set, i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
        
        set(gca,'ylim',ys,'xlim',trange)
        title(bin1Title);
        
    end
    
    for i = 1:size(electrodes,2)
        %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
        ys = [-5 5.5];
        subplot(size(electrodes,2),3,3*(i-1) + 3)
        plot([0,0],ys,'--k '); hold on;
        plot(trange,[0 0],'--k');
        for j = 1:length(conds)
            patch([t fliplr(t)],[squeeze(erpPlot4(conds(j),es(Set,i),:)+erpErr4(conds(j),es(Set,i),:))' fliplr(squeeze(erpPlot4(conds(j),es(Set,i),:)-erpErr4(conds(j),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
            plot(t,squeeze(erpPlot4(conds(j),es(Set,i),:)),'LineWidth',2);
        end
        
        text(mean(trange),ys(2),electrodes{Set, i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
        
        set(gca,'ylim',ys,'xlim',trange)
        title(bin3Title);
        
    end
    text(400,14,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
    text(400,15,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    %text(400,13,strjoin(condsLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    %text(400,16,strjoin(condsLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    set(gcf, 'Position', [0, 0, 1920, 1080]);
    savefig(Hfig, strcat(Outdir,'\AuditoryBins_',strjoin(electrodes(Set,:),'_'),'.fig'));
    saveas(Hfig, strcat(Outdir,'\AuditoryBins_',strjoin(electrodes(Set,:),'_'),'.png'));
end

 %% Plot function #4.4 - One channel on a figure. All Individuals, bin 1 & bin3. n subplots for n conditions 
trange = [-50 300];

Outdir = uigetdir('C:\Users\achen52\Documents\SMART\bins\Outputs\','Select Output Directory for the Graphs!'); 

numberSets = 9;
electrodes = {'D23','D11','D10';'D22','D12','D9';'D21','D13','D8';'D20','D14','D7';'D19','D15','D6';'D18','D16','C28';'D17','D5','C27';'C32','C31','C30';'C29','C22','C23'};
for i = 1:size(electrodes, 2)
    for j = 1:size(electrodes, 1)
        es(j,i) = find(strcmp(electrodes{j,i},chans));
    end
end

conds = [6 4 5];
condsLegend = {'A-A', 'V-A', 'AV-A'};
subplotLegend = {'All Individuals','Significant Auditory Switch Costs', 'No Auditory Switch Costs'};
for Set = 1:numberSets
    Hfig = figure;
    for i = 1:size(electrodes,2)       
        for condIndx = 1:length(conds)
            condTitle = strjoin(condsLegend(condIndx));
            %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
            ys = [-5 5.5];
            %subplot(1,length(conds),condIndx);
            subplot(size(electrodes,2), length(conds), 3 *(i-1) + condIndx)
            plot([0,0],ys,'--k '); hold on;
            plot(trange,[0 0],'--k');
            for j = 1:1
                patch([t fliplr(t)],[squeeze(erpPlot(conds(condIndx),es(Set,i),:)+erpErr(conds(condIndx),es(Set,i),:))' fliplr(squeeze(erpPlot(conds(condIndx),es(Set,i),:)-erpErr(conds(condIndx),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
                patch([t fliplr(t)],[squeeze(erpPlot2(conds(condIndx),es(Set,i),:)+erpErr2(conds(condIndx),es(Set,i),:))' fliplr(squeeze(erpPlot2(conds(condIndx),es(Set,i),:)-erpErr2(conds(condIndx),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
                patch([t fliplr(t)],[squeeze(erpPlot4(conds(condIndx),es(Set,i),:)+erpErr4(conds(condIndx),es(Set,i),:))' fliplr(squeeze(erpPlot4(conds(condIndx),es(Set,i),:)-erpErr4(conds(condIndx),es(Set,i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
                plot(t,squeeze(erpPlot(conds(condIndx),es(Set,i),:)),'LineWidth',2);
                plot(t,squeeze(erpPlot2(conds(condIndx),es(Set,i),:)),'LineWidth',2);
                plot(t,squeeze(erpPlot4(conds(condIndx),es(Set,i),:)),'LineWidth',2);
            end
            
            text(mean(trange),ys(2),electrodes{Set,i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
            
            set(gca,'ylim',ys,'xlim',trange)
            title(condTitle);
        end
    end
    set(gcf, 'Position', [0, 0, 1920, 1080]);
    text(305,15,strjoin(subplotLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
    text(305,16,strjoin(subplotLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    text(305,14,strjoin(subplotLegend(3)),'color','yellow','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    %text(400,16,strjoin(condsLegend(4)),'color','magenta','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold')
    savefig(Hfig, strcat(Outdir,'\VisualBins_intracond_',strjoin(electrodes(Set,:),'_'),'.fig'));
    saveas(Hfig, strcat(Outdir,'\VisualBins_intracond_',strjoin(electrodes(Set,:),'_'),'.png'));
end

%% Plot function #B - One figure, 64 Channels, full coverage, n-condtions
electrodes = {'F12' 'F9' 'E30' 'E14' 'D31' 'D25' 'D22' 'F28' 'F14' 'F6' 'E17' 'D28' 'D20' 'D12' 'F32' 'F24' 'F18' 'E20' 'D4' 'D16' 'D8' 'G12' 'G15' 'F21' 'A1' 'C25' 'C22' 'C19' 'G24' 'G27' 'H22' 'A4' 'B3' 'B24' 'C14' 'G30' 'H9' 'H28' 'A23' 'B6' 'B27' 'B32' 'H12' 'H16' 'H26' 'A20' 'B8' 'B15' 'B29'};
conds = [3 11 16];

trange = [-50 300];


for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end
%ys = [min(min(min(erpPlot(:,es,52:308)))) max(max(max(erpPlot(:,es,52:308))))];
ys = [-5 5.5];


xsize = 0.12; %changes dimension of each individual plot
ysize = 0.10;
ncols = 7;
nrows = 7;
colstart = 0.015; %leftmost bit of ehspace
cols = [colstart (1/ncols)+colstart (2/ncols)+colstart (3/ncols)+colstart (4/ncols)+colstart (5/ncols)+colstart (6/ncols)+colstart];
rowstart = 0.02;
rows = [rowstart (1/nrows)+rowstart (2/nrows)+rowstart (3/nrows)+rowstart (4/nrows)+rowstart (5/nrows)+rowstart (6/nrows)+rowstart];

scrsz = get(groot,'screensize');
figz = figure('Position',[scrsz(3)/20 scrsz(4)/20 scrsz(3)/1.2 scrsz(4)/1.2],'Name','AV Pure(b) Repeat(r) Switch(y)','NumberTitle','off'); 
chan1_ax = axes(figz,'Position',[cols(1) rows(7) xsize ysize]); hold on; %note how ordering works out
chan2_ax = axes(figz,'Position',[cols(2) rows(7) xsize ysize]); hold on;
chan3_ax = axes(figz,'Position',[cols(3) rows(7) xsize ysize]); hold on;
chan4_ax = axes(figz,'Position',[cols(4) rows(7) xsize ysize]);hold on;
chan5_ax = axes(figz,'Position',[cols(5) rows(7) xsize ysize]);hold on;
chan6_ax = axes(figz,'Position',[cols(6) rows(7) xsize ysize]);hold on;
chan7_ax = axes(figz,'Position',[cols(7) rows(7) xsize ysize]);hold on;
chan8_ax = axes(figz,'Position',[cols(1) rows(6) xsize ysize]);hold on;
chan9_ax = axes(figz,'Position',[cols(2) rows(6) xsize ysize]);hold on;
chan10_ax = axes(figz,'Position',[cols(3) rows(6) xsize ysize]);hold on;
chan11_ax = axes(figz,'Position',[cols(4) rows(6) xsize ysize]);hold on;
chan12_ax = axes(figz,'Position',[cols(5) rows(6) xsize ysize]);hold on;
chan13_ax = axes(figz,'Position',[cols(6) rows(6) xsize ysize]);hold on;
chan14_ax = axes(figz,'Position',[cols(7) rows(6) xsize ysize]);hold on;
chan15_ax = axes(figz,'Position',[cols(1) rows(5) xsize ysize]);hold on;
chan16_ax = axes(figz,'Position',[cols(2) rows(5) xsize ysize]);hold on;
chan17_ax = axes(figz,'Position',[cols(3) rows(5) xsize ysize]);hold on;
chan18_ax = axes(figz,'Position',[cols(4) rows(5) xsize ysize]);hold on;
chan19_ax = axes(figz,'Position',[cols(5) rows(5) xsize ysize]); hold on;
chan20_ax = axes(figz,'Position',[cols(6) rows(5) xsize ysize]); hold on;
chan21_ax = axes(figz,'Position',[cols(7) rows(5) xsize ysize]); hold on;
chan22_ax = axes(figz,'Position',[cols(1) rows(4) xsize ysize]);hold on;
chan23_ax = axes(figz,'Position',[cols(2) rows(4) xsize ysize]);hold on;
chan24_ax = axes(figz,'Position',[cols(3) rows(4) xsize ysize]);hold on;
chan25_ax = axes(figz,'Position',[cols(4) rows(4) xsize ysize]);hold on;
chan26_ax = axes(figz,'Position',[cols(5) rows(4) xsize ysize]);hold on;
chan27_ax = axes(figz,'Position',[cols(6) rows(4) xsize ysize]);hold on;
chan28_ax = axes(figz,'Position',[cols(7) rows(4) xsize ysize]);hold on;
chan29_ax = axes(figz,'Position',[cols(1) rows(3) xsize ysize]);hold on;
chan30_ax = axes(figz,'Position',[cols(2) rows(3) xsize ysize]);hold on;
chan31_ax = axes(figz,'Position',[cols(3) rows(3) xsize ysize]);hold on;
chan32_ax = axes(figz,'Position',[cols(4) rows(3) xsize ysize]);hold on;
chan33_ax = axes(figz,'Position',[cols(5) rows(3) xsize ysize]);hold on;
chan34_ax = axes(figz,'Position',[cols(6) rows(3) xsize ysize]);hold on;
chan35_ax = axes(figz,'Position',[cols(7) rows(3) xsize ysize]);hold on;
chan36_ax = axes(figz,'Position',[cols(1) rows(2) xsize ysize]);hold on;
chan37_ax = axes(figz,'Position',[cols(2) rows(2) xsize ysize]); hold on;
chan38_ax = axes(figz,'Position',[cols(3) rows(2) xsize ysize]); hold on;
chan39_ax = axes(figz,'Position',[cols(4) rows(2) xsize ysize]); hold on;
chan40_ax = axes(figz,'Position',[cols(5) rows(2) xsize ysize]);hold on;
chan41_ax = axes(figz,'Position',[cols(6) rows(2) xsize ysize]);hold on;
chan42_ax = axes(figz,'Position',[cols(7) rows(2) xsize ysize]);hold on;
chan43_ax = axes(figz,'Position',[cols(1) rows(1) xsize ysize]);hold on;
chan44_ax = axes(figz,'Position',[cols(2) rows(1) xsize ysize]);hold on;
chan45_ax = axes(figz,'Position',[cols(3) rows(1) xsize ysize]);hold on;
chan46_ax = axes(figz,'Position',[cols(4) rows(1) xsize ysize]);hold on;
chan47_ax = axes(figz,'Position',[cols(5) rows(1) xsize ysize]);hold on;
chan48_ax = axes(figz,'Position',[cols(6) rows(1) xsize ysize]);hold on;
chan49_ax = axes(figz,'Position',[cols(7) rows(1) xsize ysize]);hold on;

axarray = {chan1_ax chan2_ax chan3_ax chan4_ax chan5_ax chan6_ax chan7_ax chan8_ax chan9_ax chan10_ax chan11_ax chan12_ax chan13_ax chan14_ax chan15_ax chan16_ax chan17_ax chan18_ax chan19_ax chan20_ax chan21_ax chan22_ax chan23_ax chan24_ax chan25_ax chan26_ax chan27_ax chan28_ax chan29_ax chan30_ax chan31_ax chan32_ax chan33_ax chan34_ax chan35_ax chan36_ax chan37_ax chan38_ax chan39_ax chan40_ax chan41_ax chan42_ax chan43_ax chan44_ax chan45_ax chan46_ax chan47_ax chan48_ax chan49_ax};
%legend_ax = axes(figz,'Position',[0.25 0.86 0.1 0.1],'BoxStyle','full','Box','on','XTickLabel',[],'YTickLabel',[],'xtick',[],'ytick',[]); hold on;
set(gcf,'color','w');

for i = 1:length(electrodes)
    for j = 1:(length(conds))
        patch(axarray{i},[t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'Edgecolor','none','FaceAlpha',0.4);hold on;
        plot(axarray{i},t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',1); hold on;
        plot(axarray{i},[0,0],ys,'--k')
    end
        %plot(axarray{i},t,squeeze(erpPlot(conds(3),es(i),:)),'LineWidth',1); hold on;
        %plot(axarray{i},[0,0],ys,'--k')
        set(axarray{i},'layer','bottom','ylim',ys,'xlim',trange)
        text(axarray{i},mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
end


%% Plot function #C - One figure four channels, n-conditions on plot.
trange = [-100 350];

electrodes = {'D24' 'D30' 'B15' 'B12'};

MeanAEP = squeeze(mean(erpPlot,1));

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [1 2 3 4 5 6 7 8 9 10 11 12];


ys = [min(min(min(erpPlot(:,es,52:308))))-0.5 max(max(max(erpPlot(:,es,52:308))))+0.5];

for i = 1:length(conds)
    
    figure;
    subplot(2,2,1)
    plot([0,0],ys,'--k'); hold on;
    plot(trange,[0 0],'--k','color',[0.7 0.7 0.7]);
    plot(t,MeanAEP(es(1),:),'LineWidth',2)
    patch([t fliplr(t)],[squeeze(erpPlot(conds(i),es(1),:)+erpErr(conds(i),es(1),:))' fliplr(squeeze(erpPlot(conds(i),es(1),:)-erpErr(conds(i),es(1),:))')],[0.8 0.8 0.8],'FaceAlpha',0.4);
    plot(t,squeeze(erpPlot(conds(i),es(1),:)),'LineWidth',2);
    text(mean(trange),ys(2),electrodes{1},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    set(gca,'ylim',ys,'xlim',trange)
    
    subplot(2,2,2)
    plot([0,0],ys,'--k'); hold on;
    plot(trange,[0 0],'--k','color',[0.7 0.7 0.7]);
    plot(t,MeanAEP(es(2),:),'LineWidth',2)
    patch([t fliplr(t)],[squeeze(erpPlot(conds(i),es(2),:)+erpErr(conds(i),es(2),:))' fliplr(squeeze(erpPlot(conds(i),es(2),:)-erpErr(conds(i),es(2),:))')],[0.8 0.8 0.8],'FaceAlpha',0.4);
    plot(t,squeeze(erpPlot(conds(i),es(2),:)),'LineWidth',2);
    text(mean(trange),ys(2),electrodes{2},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    set(gca,'ylim',ys,'xlim',trange)
    
    subplot(2,2,3)
    plot([0,0],ys,'--k'); hold on;
    plot(trange,[0 0],'--k','color',[0.7 0.7 0.7]);
    plot(t,MeanAEP(es(3),:),'LineWidth',2)
    patch([t fliplr(t)],[squeeze(erpPlot(conds(i),es(3),:)+erpErr(conds(i),es(3),:))' fliplr(squeeze(erpPlot(conds(i),es(3),:)-erpErr(conds(i),es(3),:))')],[0.8 0.8 0.8],'FaceAlpha',0.4);
    plot(t,squeeze(erpPlot(conds(i),es(3),:)),'LineWidth',2);
    text(mean(trange),ys(2),electrodes{3},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    set(gca,'ylim',ys,'xlim',trange)
    
    subplot(2,2,4)
    plot([0,0],ys,'--k'); hold on;
    plot(trange,[0 0],'--k','color',[0.7 0.7 0.7]);
    plot(t,MeanAEP(es(1),:),'LineWidth',2)
    patch([t fliplr(t)],[squeeze(erpPlot(conds(i),es(4),:)+erpErr(conds(i),es(4),:))' fliplr(squeeze(erpPlot(conds(i),es(4),:)-erpErr(conds(i),es(4),:))')],[0.8 0.8 0.8],'FaceAlpha',0.4);
    plot(t,squeeze(erpPlot(conds(i),es(4),:)),'LineWidth',2);
    text(mean(trange),ys(2),electrodes{4},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    set(gca,'ylim',ys,'xlim',trange)
    
end


