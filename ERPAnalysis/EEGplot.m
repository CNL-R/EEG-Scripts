%

load chanlocs32.mat

direc = uigetdir;
folders = dir(direc);
id = {folders([folders(:).isdir]).name};
id(ismember(id,{'.','..'})) = [];

ERPavg = zeros(size(id,2),12,128,512); %% ERIC!! CHANGE SO ADAPTABLE!!!! MUCH WORK
for i = 1:size(id,2)
    
    % Load AVG ERPs
    load(fullfile(direc,id{i},[id{i},'_erp'],[id{i},'.mat']),'ERPs','RTs','t');
    %load([direc,id(i).name,'\',id(i).name,'_erp\',id(i).name,...
        %'_AVSRT.mat'],'ERPs','RTs','t');
    
    % Avgerage across
    for j = 1:12  %% ERIC, NEEDS BE MADE ADAPTABLE, LOOP FOR TRIGGER VALUES
       %idx = find(RTs{j}>150 & RTs{j}<250); %idx is unused in this loop and is redefined with each iteration....
       ERPavg(i,j,:,:) = mean(ERPs{j}.data,3);
    end
    
    ERPavg(i,13,:,:) = mean(cat(3,ERPs{4}.data,ERPs{5}.data,ERPs{6}.data),3);
    ERPavg(i,14,:,:) = mean(cat(3,ERPs{7}.data,ERPs{8}.data,ERPs{9}.data),3);
    ERPavg(i,15,:,:) = mean(cat(3,ERPs{10}.data,ERPs{11}.data,ERPs{12}.data),3);
    ERPavg(i,16,:,:) = mean(cat(3,ERPs{10}.data,ERPs{12}.data),3);
    
    clear ERPs RTs
    
end

ERPavg(:,17,:,:) = bsxfun(@plus,ERPavg(:,13,:,:),ERPavg(:,14,:,:)); %classic SUM is SUM of AllAud(13) and AllVis(14), Compare to AllAV(15)
ERPavg(:,18,:,:) = bsxfun(@plus,ERPavg(:,1,:,:),ERPavg(:,2,:,:)); %pure SUM is SUM of pureAud(1) and pureVis(2), Compare to pure AV(3)
ERPavg(:,19,:,:) = bsxfun(@plus,ERPavg(:,6,:,:),ERPavg(:,7,:,:)); %repeat SUM is SUM of A2A(6) and V2V(7), Compare to AV2AV(11)
ERPavg(:,20,:,:) = bsxfun(@plus,ERPavg(:,4,:,:),ERPavg(:,9,:,:)); %switch SUM is SUM of V2A(4) and A2V(9), Compare to A2AV or V2AV (13)

erpPlot = squeeze(mean(ERPavg,1));
erpErr = squeeze(std(ERPavg,1))/sqrt(12);

for i = 1:length(chanlocs)
    chans{i} = chanlocs(i).labels;
end

%conds = {'Stim1','Stim2','Stim3','Stim4','Stim5','Stim6','Stim7','Stim8','Stim9','Stim10','Stim11','Stim12'};
%conds = {'PureA','PureV','PureAV','V2A','AV2A','A2A','V2V','AV2V','A2V','V2AV','AV2AV','A2AV'};

trange = [-50 300];

%% Looking at temporal aspects of components at individual mean level.

%neworder(71) neworder(86) neworder(90) neworder(110) neworder(118) neworder(142)
%electrodes = {neworder(14) neworder(56) neworder(62) neworder(126) neworder(172) neworder(176) neworder(180)};
electrodes = {neworder(21) neworder(48) neworder(56) neworder(78) neworder(127) neworder(133) neworder(169)};
electrodes = {'E18'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
    mapref(i) = find(strcmp(electrodes{i},neworder));
end

conds = [1 6 4];
for p = 1:length(id)
    for i = 1:length(electrodes)
        %ys = [min(min(min(erpPlot(:,es(i),52:308)))) max(max(max(erpPlot(:,es(i),52:308))))];
        ys = [-5 5.5];
        figure;
%         for j = 1:length(conds)
%             
%             
%             patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.9 0.9 0.9],'FaceAlpha',0.5);hold on;
%             %plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2); hold on;
%             %plot([0,0],ys,'--k ')
%             %text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
%             
%         end
        
        %imagesc([t(1) t(end)],[ys(1) ys(2)],orderedplot(mapref(i),:),'AlphaData',0.8,[cmin cmax]);
        
        for j = 1:length(conds)
            
            
            %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.9 0.9 0.9],'FaceAlpha',0.4);hold on;
            plot(t,squeeze(ERPavg(p,conds(j),es(i),:)),'LineWidth',2); hold on;
            plot([0,0],ys,'--k ')
            text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
            
        end
        %     [cmin cmax] = caxis;
        %     crange = linspace(cmin,cmax,64);
        %     lowrange = find(crange<-2);
        %     highrange = find(crange>2);
        %
        %     custommap = ones(64,3);
        %     for j = 1:length(lowrange)
        %         custommap(j,:) = [j/length(lowrange) j/length(lowrange) 1];
        %     end
        %     count = length(highrange);
        %     if count > 0
        %         for j = highrange(1):highrange(end)
        %             custommap(j,:) = [1 count/length(highrange) count/length(highrange)];
        %             count = count - 1;
        %         end
        %     end
        %colormap(custommap)
        set(gca,'ylim',ys,'xlim',trange)
        
    end
end


%% Channels, individually, by request
%neworder(71) neworder(86) neworder(90) neworder(110) neworder(118) neworder(142)
%electrodes = {neworder(14) neworder(56) neworder(62) neworder(126) neworder(172) neworder(176) neworder(180)};

%putative electrodes of interest for SMART comparison
electrodes = {'D23' 'D19' 'B22' 'B26' 'B14' 'B13' 'D24' 'D29'};
%electrodes = {finalorder(159)};
% posits = [158 159 160 163:1:166 169 170 173 191 180:1:182 183:1:189 196 190];
% for i = 1:length(posits)
%     potelects{i} = finalorder(posits(i));
% end

%electrodes = {neworder(21) neworder(48) neworder(56) neworder(78) neworder(127) neworder(133) neworder(169)};
%electrodes = {'F1' 'D1' 'F2' 'E2' 'E1' 'E18' 'D24'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
    %mapref(i) = find(strcmp(electrodes{i},finalorder));
end

conds = [1 2 3 4 5 6 7 8 9 10 11 12];
%conds = fliplr(conds);
for i = 1:length(electrodes)
    ys = [min(min(min(erpPlot(:,es(i),52:308)))) max(max(max(erpPlot(:,es(i),52:308))))];
    %ys = [-2 4.5];
    %subtrace = squeeze(erpPlot(conds(2),es(i),:))' - squeeze(erpPlot(conds(1),es(i),:))';
    figure;
%     for j = 1:length(conds)
%         patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.9 0.9 0.9],'FaceAlpha',0.5);hold on;
%     end
    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k','color',[0.7 0.7 0.7]);
    %imagesc([t(1) t(end)],[ys(1) ys(2)],orderedplot(mapref(i),:),'AlphaData',0.5,[cmin cmax]);
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.9 0.9 0.9],'FaceAlpha',0.4);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    %plot(t,subtrace,'color',[0.65 0.3 0.95],'LineWidth',2);
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
%     [cmin cmax] = caxis;
%     crange = linspace(cmin,cmax,64);
%     lowrange = find(crange<-2);
%     highrange = find(crange>2);
%     
%     custommap = ones(64,3);
%     for j = 1:length(lowrange)
%         custommap(j,:) = [j/length(lowrange) j/length(lowrange) 1];
%     end
%     count = length(highrange);
%     if count > 0
%         for j = highrange(1):highrange(end)
%             custommap(j,:) = [1 count/length(highrange) count/length(highrange)];
%             count = count - 1;
%         end
%     end
    %colormap(custommap)
    set(gca,'ylim',ys,'xlim',trange)
end


%% 18 channel, whole head, all conditions in one
electrodes = {'C19' 'D4' 'C21' 'C4' 'D9' 'D12' 'C23' 'B31' 'B28' 'D25' 'D28' 'A3' 'B18' 'B15' 'A7' 'A19' 'B4' 'A23'};
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
        patch(axarray{i},[t fliplr(t)],[squeeze(erpPlot(j,es(i),:)+erpErr(j,es(i),:))' fliplr(squeeze(erpPlot(j,es(i),:)-erpErr(j,es(i),:))')],[0.5 0.8 0.5]);hold on;
        plot(axarray{i},t,squeeze(erpPlot(j,es(i),:)),'LineWidth',2); hold on;
        plot(axarray{i},[0,0],ys,'--k')
        set(axarray{i},'layer','bottom','ylim',ys,'xlim',trange)
        text(axarray{i},mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    end
end

%% 18 Channel, whole head, plotting by condition against mean of all conditions
%electrodes = {'E13' 'F16' 'E16' 'D18' 'G10' 'G5' 'E1' 'C22' 'C32' 'G21' 'H5' 'A2' 'C5' 'C17' 'H20' 'A23' 'B19' 'A19'};
electrodes = {'C19' 'D4' 'C21' 'C4' 'D9' 'D12' 'C23' 'B31' 'B28' 'D25' 'D28' 'A3' 'B18' 'B15' 'A7' 'A19' 'B4' 'A23'};
for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end
ys = [min(min(min(erpPlot(:,es,52:308)))) max(max(max(erpPlot(:,es,52:308))))];

realmin = erpPlot(find(erpPlot == min(min(min(erpPlot(:,es,52:308))))))-erpErr(find(erpPlot == min(min(min(erpPlot(:,es,52:308))))));
realmax = erpPlot(find(erpPlot == max(max(max(erpPlot(:,es,52:308))))))+erpErr(find(erpPlot == max(max(max(erpPlot(:,es,52:308))))));

ys = [realmin realmax];

meanvep = squeeze(mean(erpPlot,1));
veperr = squeeze(std(erpPlot,1))/sqrt(12);

xsize = 0.18;
ysize = 0.14;
ncols = 5;
nrows = 6;
colstart = 0.015;
cols = [colstart (1/ncols)+colstart (2/ncols)+colstart (3/ncols)+colstart (4/ncols)+colstart];
rowstart = 0.02;
rows = [rowstart (1/nrows)+rowstart (2/nrows)+rowstart (3/nrows)+rowstart (4/nrows)+rowstart (5/nrows)+rowstart];
scrsz = get(groot,'screensize');
for j = 1:length(conds)
    
    figure('Position',[scrsz(3)/20 scrsz(4)/20 scrsz(3)/1.2 scrsz(4)/1.2],'Name',sprintf('Stimulus # %d',j),'NumberTitle','off');
    chan1_ax = axes(gcf,'Position',[cols(3) rows(6) xsize ysize]); hold on;
    chan2_ax = axes(gcf,'Position',[cols(2) rows(5) xsize ysize]); hold on;
    chan3_ax = axes(gcf,'Position',[cols(3) rows(5) xsize ysize]); hold on;
    chan4_ax = axes(gcf,'Position',[cols(4) rows(5) xsize ysize]);hold on;
    chan5_ax = axes(gcf,'Position',[cols(1) rows(4) xsize ysize]);hold on;
    chan6_ax = axes(gcf,'Position',[cols(2) rows(4) xsize ysize]);hold on;
    chan7_ax = axes(gcf,'Position',[cols(3) rows(4) xsize ysize]);hold on;
    chan8_ax = axes(gcf,'Position',[cols(4) rows(4) xsize ysize]);hold on;
    chan9_ax = axes(gcf,'Position',[cols(5) rows(4) xsize ysize]);hold on;
    chan10_ax = axes(gcf,'Position',[cols(1) rows(3) xsize ysize]);hold on;
    chan11_ax = axes(gcf,'Position',[cols(2) rows(3) xsize ysize]);hold on;
    chan12_ax = axes(gcf,'Position',[cols(3) rows(3) xsize ysize]);hold on;
    chan13_ax = axes(gcf,'Position',[cols(4) rows(3) xsize ysize]);hold on;
    chan14_ax = axes(gcf,'Position',[cols(5) rows(3) xsize ysize]);hold on;
    chan15_ax = axes(gcf,'Position',[cols(2) rows(2) xsize ysize]);hold on;
    chan16_ax = axes(gcf,'Position',[cols(3) rows(2) xsize ysize]);hold on;
    chan17_ax = axes(gcf,'Position',[cols(4) rows(2) xsize ysize]);hold on;
    chan18_ax = axes(gcf,'Position',[cols(3) rows(1) xsize ysize]);hold on;
    axarray = {chan1_ax chan2_ax chan3_ax chan4_ax chan5_ax chan6_ax chan7_ax chan8_ax chan9_ax chan10_ax chan11_ax chan12_ax chan13_ax chan14_ax chan15_ax chan16_ax chan17_ax chan18_ax};
    
    condi = ['MeanVEP' conds(j)];
    
    legend_ax = axes(gcf,'Position',[0.25 0.86 0.1 0.1],'BoxStyle','full','Box','off','XTickLabel',[],'YTickLabel',[],'xtick',[],'ytick',[]); hold on;
    plot(legend_ax,[1 1],'color',[0.9 0.3 0.3],'LineWidth',2); text(legend_ax,0.2,1,condi(1),'horizontalalignment','center')
    plot(legend_ax,[0 0],'color',[0.4 0.8 0.4],'LineWidth',2); text(legend_ax,0.2,0,condi(2),'horizontalalignment','center')
    set(legend_ax,'xlim',[-.25 2.75],'ylim',[-2 2]);
    set(gca,'Visible','off');
    
    set(gcf,'color','w');
    
    
    for i = 1:length(electrodes)
            pat1 = patch(axarray{i},[t fliplr(t)],[(meanvep(es(i),:)+veperr(es(i),:)) fliplr(meanvep(es(i),:)-veperr(es(i),:))],[0.8 0.6 0.6]);hold on;
            p1 = plot(axarray{i},t,meanvep(es(i),:),'color',[0.9 0.3 0.3],'LineWidth',2); hold on;
            
            pat2 = patch(axarray{i},[t fliplr(t)],[squeeze(erpPlot(j,es(i),:)+erpErr(j,es(i),:))' fliplr(squeeze(erpPlot(j,es(i),:)-erpErr(j,es(i),:))')],[0.6 0.9 0.6]);hold on;
            p2 = plot(axarray{i},t,squeeze(erpPlot(j,es(i),:)),'color',[0.4 0.8 0.4],'LineWidth',2); hold on;
            
            plot(axarray{i},[0,0],ys,'--k')
            set(axarray{i},'layer','bottom','ylim',ys,'xlim',trange)
            text(axarray{i},mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
            alpha(pat1,0.5); alpha(pat2,0.5)
    end
    
end


%% 18 Channel, whole head, plotting certain conditions
electrodes = {'E13' 'F16' 'E16' 'D18' 'G10' 'G5' 'E1' 'C22' 'C32' 'G21' 'H5' 'A2' 'C5' 'C17' 'H20' 'A23' 'B19' 'A19'};
for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end
ys = [min(min(min(erpPlot(:,es,52:308)))) max(max(max(erpPlot(:,es,52:308))))];

realmin = erpPlot(find(erpPlot == min(min(min(erpPlot(:,es,52:308))))))-erpErr(find(erpPlot == min(min(min(erpPlot(:,es,52:308))))));
realmax = erpPlot(find(erpPlot == max(max(max(erpPlot(:,es,52:308))))))+erpErr(find(erpPlot == max(max(max(erpPlot(:,es,52:308))))));

ys = [realmin realmax];

meanvep = squeeze(mean(erpPlot,1));
veperr = squeeze(std(erpPlot,1))/sqrt(12);

xsize = 0.18;
ysize = 0.14;
ncols = 5;
nrows = 6;
colstart = 0.015;
cols = [colstart (1/ncols)+colstart (2/ncols)+colstart (3/ncols)+colstart (4/ncols)+colstart];
rowstart = 0.02;
rows = [rowstart (1/nrows)+rowstart (2/nrows)+rowstart (3/nrows)+rowstart (4/nrows)+rowstart (5/nrows)+rowstart];
scrsz = get(groot,'screensize');

conds = {'PureA','PureV','PureAV','V2A','AV2A','A2A','V2V','AV2V','A2V','V2AV','AV2AV','A2AV'};
wantedplots = {'PureA','A2A','V2A';'PureV','V2V','A2V';'PureAV','AV2AV','SwitchAV'};

%create 'switchAV' virtual condition (mean of V2AV and A2AV)
%erpPlot(:,13,:,:) 
testout = mean(erpPlot(:,[10 12],:,:),1);

for j = 1:length(wantedplots)
    
    figure('Position',[scrsz(3)/20 scrsz(4)/20 scrsz(3)/1.2 scrsz(4)/1.2],'Name',sprintf('Stimulus # %d',j),'NumberTitle','off');
    chan1_ax = axes(gcf,'Position',[cols(3) rows(6) xsize ysize]); hold on;
    chan2_ax = axes(gcf,'Position',[cols(2) rows(5) xsize ysize]); hold on;
    chan3_ax = axes(gcf,'Position',[cols(3) rows(5) xsize ysize]); hold on;
    chan4_ax = axes(gcf,'Position',[cols(4) rows(5) xsize ysize]);hold on;
    chan5_ax = axes(gcf,'Position',[cols(1) rows(4) xsize ysize]);hold on;
    chan6_ax = axes(gcf,'Position',[cols(2) rows(4) xsize ysize]);hold on;
    chan7_ax = axes(gcf,'Position',[cols(3) rows(4) xsize ysize]);hold on;
    chan8_ax = axes(gcf,'Position',[cols(4) rows(4) xsize ysize]);hold on;
    chan9_ax = axes(gcf,'Position',[cols(5) rows(4) xsize ysize]);hold on;
    chan10_ax = axes(gcf,'Position',[cols(1) rows(3) xsize ysize]);hold on;
    chan11_ax = axes(gcf,'Position',[cols(2) rows(3) xsize ysize]);hold on;
    chan12_ax = axes(gcf,'Position',[cols(3) rows(3) xsize ysize]);hold on;
    chan13_ax = axes(gcf,'Position',[cols(4) rows(3) xsize ysize]);hold on;
    chan14_ax = axes(gcf,'Position',[cols(5) rows(3) xsize ysize]);hold on;
    chan15_ax = axes(gcf,'Position',[cols(2) rows(2) xsize ysize]);hold on;
    chan16_ax = axes(gcf,'Position',[cols(3) rows(2) xsize ysize]);hold on;
    chan17_ax = axes(gcf,'Position',[cols(4) rows(2) xsize ysize]);hold on;
    chan18_ax = axes(gcf,'Position',[cols(3) rows(1) xsize ysize]);hold on;
    axarray = {chan1_ax chan2_ax chan3_ax chan4_ax chan5_ax chan6_ax chan7_ax chan8_ax chan9_ax chan10_ax chan11_ax chan12_ax chan13_ax chan14_ax chan15_ax chan16_ax chan17_ax chan18_ax};
    
    condi = ['MeanVEP' conds(j)];
    
    legend_ax = axes(gcf,'Position',[0.25 0.86 0.1 0.1],'BoxStyle','full','Box','off','XTickLabel',[],'YTickLabel',[],'xtick',[],'ytick',[]); hold on;
    plot(legend_ax,[1 1],'color',[0.9 0.3 0.3],'LineWidth',2); text(legend_ax,0.2,1,condi(1),'horizontalalignment','center')
    plot(legend_ax,[0 0],'color',[0.4 0.8 0.4],'LineWidth',2); text(legend_ax,0.2,0,condi(2),'horizontalalignment','center')
    set(legend_ax,'xlim',[-.25 2.75],'ylim',[-2 2]);
    set(gca,'Visible','off');
    
    set(gcf,'color','w');
    
    
    for i = 1:length(electrodes)
            pat1 = patch(axarray{i},[t fliplr(t)],[(meanvep(es(i),:)+veperr(es(i),:)) fliplr(meanvep(es(i),:)-veperr(es(i),:))],[0.8 0.6 0.6]);hold on;
            p1 = plot(axarray{i},t,meanvep(es(i),:),'color',[0.9 0.3 0.3],'LineWidth',2); hold on;
            
            pat2 = patch(axarray{i},[t fliplr(t)],[squeeze(erpPlot(j,es(i),:)+erpErr(j,es(i),:))' fliplr(squeeze(erpPlot(j,es(i),:)-erpErr(j,es(i),:))')],[0.6 0.9 0.6]);hold on;
            p2 = plot(axarray{i},t,squeeze(erpPlot(j,es(i),:)),'color',[0.4 0.8 0.4],'LineWidth',2); hold on;
            
            plot(axarray{i},[0,0],ys,'--k')
            set(axarray{i},'layer','bottom','ylim',ys,'xlim',trange)
            text(axarray{i},mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
            alpha(pat1,0.5); alpha(pat2,0.5)
    end
    
end

%% 16 channel, occipital focus, plotting by condition against mean of all conditions
scrsz = get(groot,'screensize');
electrodes = {'D25' 'A7' 'A19' 'B4' 'B15' 'D30' 'A17' 'A21' 'A30' 'B12' 'A10' 'A23' 'B7' 'A13' 'A25' 'A26'};
for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end
conds = {'Stim1','Stim2','Stim3','Stim5','Stim6','Stim9','Stim13','Stim14','Stim15','Stim16','Stim17','Stim18'};

stimsdir = uigetdir(cd,'Select the directory with the .bmp images');
pngfiles = ls(fullfile(stimsdir,'*bmp'));

realmin = erpPlot(find(erpPlot == min(min(min(erpPlot(:,es,52:308))))))-erpErr(find(erpPlot == min(min(min(erpPlot(:,es,52:308))))));
realmax = erpPlot(find(erpPlot == max(max(max(erpPlot(:,es,52:308))))))+erpErr(find(erpPlot == max(max(max(erpPlot(:,es,52:308))))));
ys = [realmin realmax];

xsize = 0.18;
ysize = 0.2;
ncols = 5;
nrows = 4;
colstart = 0.015;
cols = [colstart (1/ncols)+colstart (2/ncols)+colstart (3/ncols)+colstart (4/ncols)+colstart];
rowstart = 0.025;
rows = [rowstart (1/nrows)+rowstart (2/nrows)+rowstart (3/nrows)+rowstart (4/nrows)+rowstart (5/nrows)+rowstart];

for j = 1:length(conds)
    %stim image analysis stuff (power plot)
    file = strtrim(fullfile(stimsdir,pngfiles(j,:)));
    I = imread(file);
    I = rgb2gray(I);
    F = fftshift(fft2(I));
    [rws, cls] = size(F);
    [ux, uy] = meshgrid(([1:cls]-(fix(cls/2)+1))/(cls-mod(cls,2)), ...
    ([1:rws]-(fix(rws/2)+1))/(rws-mod(rws,2)));
    th = atan2(uy,ux);
    r = sqrt(ux.^2 + uy.^2);
    Fr = F .* r;
    rcoords = linspace(0,sqrt(ux(1,1)^2 + uy(1,1)^2),rws);
    thcoords = linspace(0,2*pi,cls);
    [ri,thi] = meshgrid(rcoords,thcoords);
    [x,y] = pol2cart(thi,ri);
    Fp = interp2(ux,uy,abs(Fr),x,y);
    F1D = sum(Fp);
    %plotting
    figure('Position',[scrsz(3)/20 scrsz(4)/20 scrsz(3)/1.2 scrsz(4)/1.2],'Name',sprintf('Stimulus # %d',j),'NumberTitle','off');
    chan1_ax = axes(gcf,'Position',[cols(1) rows(4) xsize ysize]); hold on;
    chan2_ax = axes(gcf,'Position',[cols(2) rows(4) xsize ysize]); hold on;
    chan3_ax = axes(gcf,'Position',[cols(3) rows(4) xsize ysize]); hold on;
    chan4_ax = axes(gcf,'Position',[cols(4) rows(4) xsize ysize]);hold on;
    chan5_ax = axes(gcf,'Position',[cols(5) rows(4) xsize ysize]);hold on;
    chan6_ax = axes(gcf,'Position',[cols(1) rows(3) xsize ysize]);hold on;
    chan7_ax = axes(gcf,'Position',[cols(2) rows(3) xsize ysize]);hold on;
    chan8_ax = axes(gcf,'Position',[cols(3) rows(3) xsize ysize]);hold on;
    chan9_ax = axes(gcf,'Position',[cols(4) rows(3) xsize ysize]);hold on;
    chan10_ax = axes(gcf,'Position',[cols(5) rows(3) xsize ysize]);hold on;
    chan11_ax = axes(gcf,'Position',[cols(2) rows(2) xsize ysize]);hold on;
    chan12_ax = axes(gcf,'Position',[cols(3) rows(2) xsize ysize]);hold on;
    chan13_ax = axes(gcf,'Position',[cols(4) rows(2) xsize ysize]);hold on;
    chan14_ax = axes(gcf,'Position',[cols(2) rows(1) xsize ysize]);hold on;
    chan15_ax = axes(gcf,'Position',[cols(3) rows(1) xsize ysize]);hold on;
    chan16_ax = axes(gcf,'Position',[cols(4) rows(1) xsize ysize]);hold on;
    axarray = {chan1_ax chan2_ax chan3_ax chan4_ax chan5_ax chan6_ax chan7_ax chan8_ax chan9_ax chan10_ax chan11_ax chan12_ax chan13_ax chan14_ax chan15_ax chan16_ax};
    
    legend_ax = axes(gcf,'Position',[0.05 0.35 0.1 0.1],'BoxStyle','full','Box','on','XTickLabel',[],'YTickLabel',[],'xtick',[],'ytick',[]); hold on;
    condi = ['MeanVEP' conds(j)];
    plot(legend_ax,[1 1],'color',[0.9 0.3 0.3],'LineWidth',2); text(legend_ax,0.2,1,condi(1),'horizontalalignment','center')
    plot(legend_ax,[0 0],'color',[0.4 0.8 0.4],'LineWidth',2); text(legend_ax,0.2,0,condi(2),'horizontalalignment','center')
    set(legend_ax,'xlim',[-.25 2.75],'ylim',[-2 2]);
    set(gca,'Visible','off');
    
    set(gcf,'color','w');
    
    for i = 1:length(electrodes)
        pat1 = patch(axarray{i},[t fliplr(t)],[(meanvep(es(i),:)+veperr(es(i),:)) fliplr(meanvep(es(i),:)-veperr(es(i),:))],[0.8 0.6 0.6]);hold on;
        p1 = plot(axarray{i},t,meanvep(es(i),:),'color',[0.9 0.3 0.3],'LineWidth',2); hold on;
        
        pat2 = patch(axarray{i},[t fliplr(t)],[squeeze(erpPlot(j,es(i),:)+erpErr(j,es(i),:))' fliplr(squeeze(erpPlot(j,es(i),:)-erpErr(j,es(i),:))')],[0.6 0.9 0.6]);hold on;
        p2 = plot(axarray{i},t,squeeze(erpPlot(j,es(i),:)),'color',[0.4 0.8 0.4],'LineWidth',2); hold on;
        
        plot(axarray{i},[0,0],ys,'--k')
        set(axarray{i},'layer','bottom','ylim',ys,'xlim',trange)
        text(axarray{i},mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
        alpha(pat1,0.2); alpha(pat2,0.2)
    end
    
    box1ax = axes(gcf,'Position',[cols(5)*1.01 .15 xsize*0.3 ysize*1.5]); hold on;
    boxplot(box1ax,pixvals); hold on; plot(box1ax,pixvals(j),'.','color',[0.9 0.6 0.2],'MarkerSize',50); set(box1ax,'xticklabels',[]); xlabel('Mean Pix Val');
    box2ax = axes(gcf,'Position',[cols(5)*1.12 .15 xsize*0.3 ysize*1.5]); hold on;
    boxplot(pixnums); hold on; plot(pixnums(j),'.','color',[0.9 0.6 0.2],'MarkerSize',50); set(box2ax,'xticklabels',[]); xlabel('Total Pixels (mass)');
    
    powax = axes(gcf,'Position',[0.01 0.05 xsize ysize]); hold on; plot(powax,rcoords,F1D); title('Image Spectral Power'); xlim([0 0.2]);
end

%% old

patch(chan1_ax,[tvec fliplr(tvec)],[rav_metamean(e1,:)*-1+rav_error(e1,:) fliplr(rav_metamean(e1,:)*-1-rav_error(e1,:))],[0.8 0.8 1],'EdgeColor',[0.6 0.6 1]);hold on;
plot(chan1_ax,tvec,rav_metamean(e1,:)*-1,'b','LineWidth',1.5);
pa1 = patch(chan1_ax,[tvec fliplr(tvec)],[pav_metamean(e1,:)*-1+pav_error(e1,:) fliplr(pav_metamean(e1,:)*-1-pav_error(e1,:))],[0.8 1 0.8],'EdgeColor',[0.6 1 0.6]);
p1 = plot(chan1_ax,tvec,pav_metamean(e1,:)*-1,'g','LineWidth',1.5);
pa2 = patch(chan1_ax,[tvec fliplr(tvec)],[sav_metamean(e1,:)*-1+sav_error(e1,:) fliplr(sav_metamean(e1,:)*-1-sav_error(e1,:))],[1 0.8 0.8],'EdgeColor',[1 0.6 0.6]); 
p2 = plot(chan1_ax,tvec,sav_metamean(e1,:)*-1,'r','LineWidth',1.5);
ys = get(chan1_ax,'ylim');
plot(chan1_ax,[0 0],ys,'Linestyle','-','color','k');
hline1 = refline(chan1_ax,0,0);
set(hline1,'LineStyle','--','color','k');
patch(chan1_ax,[tvec fliplr(tvec)],[rav_metamean(e1,:)*-1+rav_error(e1,:) fliplr(rav_metamean(e1,:)*-1-rav_error(e1,:))],[0.8 0.8 1],'EdgeColor',[0.6 0.6 1]);hold on;
plot(chan1_ax,tvec,rav_metamean(e1,:)*-1,'b','LineWidth',1.5);
pa1 = patch(chan1_ax,[tvec fliplr(tvec)],[pav_metamean(e1,:)*-1+pav_error(e1,:) fliplr(pav_metamean(e1,:)*-1-pav_error(e1,:))],[0.8 1 0.8],'EdgeColor',[0.6 1 0.6]);
p1 = plot(chan1_ax,tvec,pav_metamean(e1,:)*-1,'g','LineWidth',1.5);
pa2 = patch(chan1_ax,[tvec fliplr(tvec)],[sav_metamean(e1,:)*-1+sav_error(e1,:) fliplr(sav_metamean(e1,:)*-1-sav_error(e1,:))],[1 0.8 0.8],'EdgeColor',[1 0.6 0.6]); 
p2 = plot(chan1_ax,tvec,sav_metamean(e1,:)*-1,'r','LineWidth',1.5);
txt = text(chan1_ax, -.18, 3, electrode1);
set(chan1_ax,'FontSize',7);
hold(chan1_ax,'off')
alpha(pa1,0.5); alpha(p1,0.5); alpha(pa2,0.5); alpha(p2,0.5);