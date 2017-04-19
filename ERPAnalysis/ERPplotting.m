%EEG ERP plotter functions


direc = uigetdir;
folders = dir(direc);
id = {folders([folders(:).isdir]).name};
id(ismember(id,{'.','..'})) = [];


ERPavg = zeros(size(id,2),6,32,512); %% ERIC!! CHANGE SO ADAPTABLE!!!! MUCH WORK

for i = 1:size(id,2)
    
    load(fullfile(direc,id{i},[id{i},'_erp'],[id{i},'.mat']),'ERPs','RTs','t');

    % Avgerage across
    for j = 1:6  %% ERIC, NEEDS BE MADE ADAPTABLE, LOOP FOR TRIGGER VALUES
       ERPavg(i,j,:,:) = mean(ERPs{j}.data,3);
    end
    
    clear ERPs RTs
    
end

erpPlot = squeeze(mean(ERPavg,1));
erpErr = squeeze(std(ERPavg,1))/sqrt(12);

for i = 1:length(chanlocs)
    chans{i} = chanlocs(i).labels;
end

%% Plot function #1 - New figure for each channel, n-conditions on plot.
trange = [-100 350];

electrodes = {'Fz' 'Pz'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [5 6];

for i = 1:length(electrodes)
    ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    
    figure;

    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k','color',[0.7 0.7 0.7]);
    for j = 1:length(conds)
        patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.4);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
end

%% Plot function #2 - One figure, 18 Channels, full coverage, n-condtions
electrodes = {'C20' 'D5' 'C21' 'C5' 'D10' 'D12' 'C23' 'B31' 'B29' 'D26' 'D28' 'A3' 'B18' 'B16' 'D30' 'A20' 'B12' 'A21'};


trange = [-50 300];


for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end
ys = [min(min(min(erpPlot(:,es,52:308)))) max(max(max(erpPlot(:,es,52:308))))];

xsize = 0.18;
ysize = 0.14;
ncols = 5;
nrows = 6;
colstart = 0.015;
cols = [colstart (1/ncols)+colstart (2/ncols)+colstart (3/ncols)+colstart (4/ncols)+colstart];
rowstart = 0.02;
rows = [rowstart (1/nrows)+rowstart (2/nrows)+rowstart (3/nrows)+rowstart (4/nrows)+rowstart (5/nrows)+rowstart];

scrsz = get(groot,'screensize');
figz = figure('Position',[scrsz(3)/20 scrsz(4)/20 scrsz(3)/1.2 scrsz(4)/1.2],'Name','SMART data - AudioVisual (Switch vs Repeat vs Pure)','NumberTitle','off'); 
chan1_ax = axes(figz,'Position',[cols(3) rows(6) xsize ysize]); hold on;
chan2_ax = axes(figz,'Position',[cols(2) rows(5) xsize ysize]); hold on;
chan3_ax = axes(figz,'Position',[cols(3) rows(5) xsize ysize]); hold on;
chan4_ax = axes(figz,'Position',[cols(4) rows(5) xsize ysize]);hold on;
chan5_ax = axes(figz,'Position',[cols(1) rows(4) xsize ysize]);hold on;
chan6_ax = axes(figz,'Position',[cols(2) rows(4) xsize ysize]);hold on;
chan7_ax = axes(figz,'Position',[cols(3) rows(4) xsize ysize]);hold on;
chan8_ax = axes(figz,'Position',[cols(4) rows(4) xsize ysize]);hold on;
chan9_ax = axes(figz,'Position',[cols(5) rows(4) xsize ysize]);hold on;
chan10_ax = axes(figz,'Position',[cols(1) rows(3) xsize ysize]);hold on;
chan11_ax = axes(figz,'Position',[cols(2) rows(3) xsize ysize]);hold on;
chan12_ax = axes(figz,'Position',[cols(3) rows(3) xsize ysize]);hold on;
chan13_ax = axes(figz,'Position',[cols(4) rows(3) xsize ysize]);hold on;
chan14_ax = axes(figz,'Position',[cols(5) rows(3) xsize ysize]);hold on;
chan15_ax = axes(figz,'Position',[cols(2) rows(2) xsize ysize]);hold on;
chan16_ax = axes(figz,'Position',[cols(3) rows(2) xsize ysize]);hold on;
chan17_ax = axes(figz,'Position',[cols(4) rows(2) xsize ysize]);hold on;
chan18_ax = axes(figz,'Position',[cols(3) rows(1) xsize ysize]);hold on;
axarray = {chan1_ax chan2_ax chan3_ax chan4_ax chan5_ax chan6_ax chan7_ax chan8_ax chan9_ax chan10_ax chan11_ax chan12_ax chan13_ax chan14_ax chan15_ax chan16_ax chan17_ax chan18_ax};
legend_ax = axes(figz,'Position',[0.25 0.86 0.1 0.1],'BoxStyle','full','Box','on','XTickLabel',[],'YTickLabel',[],'xtick',[],'ytick',[]); hold on;
set(gcf,'color','w');

for i = 1:length(electrodes)
    for j = 1:length(conds)
        patch(axarray{i},[t fliplr(t)],[squeeze(erpPlot(j,es(i),:)+erpErr(j,es(i),:))' fliplr(squeeze(erpPlot(j,es(i),:)-erpErr(j,es(i),:))')],[0.8 0.8 0.8]);hold on;
        plot(axarray{i},t,squeeze(erpPlot(j,es(i),:)),'LineWidth',2); hold on;
        plot(axarray{i},[0,0],ys,'--k')
        set(axarray{i},'layer','bottom','ylim',ys,'xlim',trange)
        text(axarray{i},mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    end
end


%% Plot function #3 - One figure four channels, n-conditions on plot.
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


