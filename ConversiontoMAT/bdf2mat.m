function bdf2mat(datadir,chanlocs)

folders = dir(datadir);
subjects = {folders([folders(:).isdir]).name};
subjects(ismember(subjects,{'.','..'})) = [];
disp('Converting files to .mat format...');

for i = 1:length(subjects)
    
    bdffiles = ls(fullfile(datadir,subjects{i},[subjects{i},'_bdf'],'*bdf'));
    
    if ~isempty(bdffiles)
        if exist(fullfile(datadir,subjects{i},[subjects{i},'_mat']),'dir') == 0
        %if isempty(ls(fullfile(datadir,subjects{i},[subjects{i},'_mat'],'*mat')))
            disp(['Converting and merging ' subjects{i}]);
            
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
            
        else
            disp(['Participant ' subjects{i} ' already converted!']);
        end
    else
        disp(['Folder for ' subjects{i} ' contained no .bdf files to convert! (or the folder structure is incorrect!)']);
    end
    
end
disp('Finished file merging and conversions! On to preprocessing...');
end