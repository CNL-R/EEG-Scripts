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
    %clear ERPs RTs
    
end

erpPlot = squeeze(mean(ERPavg,1));
erpErr = squeeze(std(ERPavg,1))/sqrt(16); %16=number of subjects. do change accordingly.

for i = 1:length(chanlocs)
    chans{i} = chanlocs(i).labels;
end

%% Plot function #1 - New figure for each channel, n-conditions on plot.
trange = [-50 300];

electrodes = {'B18'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

conds = [11 12 10];

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-5 5.5];
    figure;

    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
end

%% Plot function #2 - One figure, 64 Channels, full coverage, n-condtions
electrodes = {  'F12' 'F9' 'E30' 'E14' 'D31' 'D25' 'D22' 'F28' 'F14' 'F6' 'E17' 'D28' 'D20' 'D12' 'F32' 'F24' 'F18' 'E20' 'D4' 'D16' 'D8' 'G12' 'G15' 'F21' 'A1' 'C25' 'C22' 'C19' 'G24' 'G27' 'H22' 'A4' 'B3' 'B24' 'C14' 'G30' 'H9' 'H28' 'A23' 'B6' 'B27' 'B32' 'H12' 'H16' 'H26' 'A20' 'B8' 'B15' 'B29'};
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


