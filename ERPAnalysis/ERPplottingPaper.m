%EEG ERP plotter functions + additional function for producing figures comparing repeats, switches and pures for the SMART paper

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

%% Plot function #1 - Repeat & Switch w/ SEMs & Difference Trace
Outdir = uigetdir('C:\Users\achen52\Documents\SMART\paperfigs','Select Output Directory for the Graphs!'); 
trange = [-50 150];

electrodes = {'B21'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

%Auditory
%conds = [6 4];
%condsLegend = {'A-A', 'V-A', 'Diff'};

%Visual
conds = [7 9];
condsLegend = {'V-V', 'A-V', 'Diff'};

difference = erpPlot(conds(2),:,:) - erpPlot(conds(1),:,:); %Switch - Repeat

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-2 1.5];
    Hfig = figure;

    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
     plot(t,squeeze(difference(:,es(i),:)),'LineWidth',2, 'Color', [.5 0 .5]);
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
end
text(155,.3,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
text(155,0,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
text(155,-.3,strjoin(condsLegend(3)),'color',[.5 0 .5],'horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
savefig(Hfig, strcat(Outdir,strcat('\',strjoin(condsLegend(1)),'_',strjoin(condsLegend(2)),'_',strjoin(condsLegend(3))),'_',strjoin(electrodes(:),'_'),'.fig'));
saveas(Hfig, strcat(Outdir,strcat('\',strjoin(condsLegend(1)),'_',strjoin(condsLegend(2)),'_',strjoin(condsLegend(3))),'_',strjoin(electrodes(:),'_'),'.png'));
%% Plot function #2 - Repeat & Switch & AVswitch w/ SEM
Outdir = uigetdir('C:\Users\achen52\Documents\SMART\paperfigs','Select Output Directory for the Graphs!'); 
trange = [-50 150];

electrodes = {'B21'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

%Auditory
%conds = [6 4 5];
%condsLegend = {'A-A', 'V-A', 'AV-A'};

%Visual
conds = [7 9 8];
condsLegend = {'V-V', 'A-V', 'AV-V'};

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-2 1.5];
    Hfig = figure;

    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
end
text(155,.3,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
text(155,0,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
text(155,-.3,strjoin(condsLegend(3)),'color',[0.9 0.75 0],'horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
savefig(Hfig, strcat(Outdir,strcat('\',strjoin(condsLegend(1)),'_',strjoin(condsLegend(2)),'_',strjoin(condsLegend(3))),'_',strjoin(electrodes(:),'_'),'.fig'));
saveas(Hfig, strcat(Outdir,strcat('\',strjoin(condsLegend(1)),'_',strjoin(condsLegend(2)),'_',strjoin(condsLegend(3))),'_',strjoin(electrodes(:),'_'),'.png'));

%% Plot function #3 - Repeat & Switch & AVswitch ONLY
Outdir = uigetdir('C:\Users\achen52\Documents\SMART\paperfigs','Select Output Directory for the Graphs!'); 
trange = [-50 150];

electrodes = {'A3','A6', 'H2','B21'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

%Auditory
conds = [6 4 5];
condsLegend = {'A-A', 'V-A', 'AV-A'};

%Visual
%conds = [7 9 8];
%condsLegend = {'V-V', 'A-V', 'AV-V'};

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-2 2.5];
    Hfig = figure;

    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    
    text(155,.3,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
text(155,0,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
text(155,-.3,strjoin(condsLegend(3)),'color',[0.9 0.75 0],'horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
savefig(Hfig, strcat(Outdir,strcat('\',strjoin(condsLegend(1)),'_',strjoin(condsLegend(2)),'_',strjoin(condsLegend(3))),'_',strjoin(electrodes(i),'_'),'.fig'));
saveas(Hfig, strcat(Outdir,strcat('\',strjoin(condsLegend(1)),'_',strjoin(condsLegend(2)),'_',strjoin(condsLegend(3))),'_',strjoin(electrodes(i),'_'),'.png'));
end


%% Plot function #4 - Repeat & Switch & AVswitch & Pure ONLY
Outdir = uigetdir('C:\Users\achen52\Documents\SMART\paperfigs','Select Output Directory for the Graphs!'); 
trange = [-50 150];

electrodes = {'A3','A6', 'H2','B21'};

for i = 1:length(electrodes)
    es(i) = find(strcmp(electrodes{i},chans));
end

%Auditory
conds = [6 4 5 1];
condsLegend = {'A-A', 'V-A', 'AV-A', 'Pure A'};

%Visual
%conds = [7 9 8 2];
%condsLegend = {'V-V', 'A-V', 'AV-V', 'Pure V'};

for i = 1:length(electrodes)
    %ys = [min(min(min(erpPlot(conds,es(i),52:308))))-0.5 max(max(max(erpPlot(conds,es(i),52:308))))+0.5];
    ys = [-2 2.5];
    Hfig = figure;

    plot([0,0],ys,'--k '); hold on;
    plot(trange,[0 0],'--k');
    for j = 1:length(conds)
        %patch([t fliplr(t)],[squeeze(erpPlot(conds(j),es(i),:)+erpErr(conds(j),es(i),:))' fliplr(squeeze(erpPlot(conds(j),es(i),:)-erpErr(conds(j),es(i),:))')],[0.8 0.8 0.8],'FaceAlpha',0.2);
        plot(t,squeeze(erpPlot(conds(j),es(i),:)),'LineWidth',2);
    end
    text(mean(trange),ys(2),electrodes{i},'horizontalalignment','center','verticalalignment','top','fontweight','bold')
    
    set(gca,'ylim',ys,'xlim',trange)
    text(155,.3,strjoin(condsLegend(1)),'color','blue','horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
text(155,0,strjoin(condsLegend(2)),'color','red','horizontalalignment','left','verticalalignment','top','FontSize',8','fontweight','bold');
text(155,-.3,strjoin(condsLegend(3)),'color',[0.9 0.75 0],'horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
text(155,-.6,strjoin(condsLegend(4)),'color',[.5 0 .5],'horizontalalignment','left','verticalalignment','top','FontSize',8,'fontweight','bold');
savefig(Hfig, strcat(Outdir,strcat('\',strjoin(condsLegend(1)),'_',strjoin(condsLegend(2)),'_',strjoin(condsLegend(3))),'_',strjoin(condsLegend(4)),'_',strjoin(electrodes(i),'_'),'.fig'));
saveas(Hfig, strcat(Outdir,strcat('\',strjoin(condsLegend(1)),'_',strjoin(condsLegend(2)),'_',strjoin(condsLegend(3))),'_',strjoin(condsLegend(4)),'_',strjoin(electrodes(i),'_'),'.png'));
end

