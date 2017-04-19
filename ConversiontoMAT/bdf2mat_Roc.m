
%clear all;
%clc;

%load('chanlocs256.mat')  %move into loop? Script auto select chanloc file after reading in data?

datadir = uigetdir;

folders = dir(datadir);
subjects = {folders([folders(:).isdir]).name};
subjects(ismember(subjects,{'.','..'})) = [];

for i = 1:length(subjects)
    
    bdffiles = ls(fullfile(datadir,subjects{i},[subjects{i},'_bdf'],'*bdf'));
    for j = 1:size(bdffiles,1)
        temp_dat = pop_biosig(strtrim(fullfile(datadir,subjects{i},[subjects{i},'_bdf'],bdffiles(j,:))));
        if j == 1
            EEG = temp_dat;
        else
            EEG = pop_mergeset(EEG,temp_dat);
        end
        clear temp_dat;
    end
    
    EEG.chanlocs = chanlocs;
    
    mkdir(fullfile(datadir,subjects{i},[subjects{i},'_mat']));
    save(fullfile(datadir,subjects{i},[subjects{i},'_mat'],[subjects{i},'.mat']),'EEG','-mat');
    clear bdffiles EEG
    
end