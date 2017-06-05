% Script to filter and epoch EEG data

function preprocdat(datadir,chanlocs)

load('chanlocs256.mat')

trigs = {'3','5','7','9','11','13'};
%trigs = {'21','22','23','24','25','26','27','28','29','30','31','32'};

% Define ERP parameters %THESE SHOULD BE DETERMINED FROM DATA STRUCT OR
% USER SHOULD BE PROMPTED
fs = 512;
nChans = 32;
tmin = -100;
tmax = 900;
thr1 = 150;
thrMin = -100;
thrMax = 500;
blmin = -50;
blmax = 10;

% Define filter parameters
FstopH = 1;
FpassH = 2;
AstopH = 40;
FpassL = 45;
FstopL = 55;
AstopL = 40;
Apass = 1;

% Generate high/low-pass filters
h = fdesign.highpass(FstopH,FpassH,AstopH,Apass,fs);
hpf = design(h,'cheby2','MatchExactly','stopband'); clear h
h = fdesign.lowpass(FpassL,FstopL,Apass,AstopL,fs);
lpf = design(h,'cheby2','MatchExactly','stopband'); clear h

% Find 6 nearest channels to each channel
[~,nearMat] = getnearest('chanlocs128.txt',nChans,6);
nearCell = cell(1,nChans);
for i = 1:nChans
    nearCell{i} = nearMat(i,:);
end

% Get all subject IDs
folders = dir(datadir);
subjects = {folders([folders(:).isdir]).name};
subjects(ismember(subjects,{'.','..'})) = [];

for i = 1:length(subjects)
    if exist(fullfile(datadir,subjects{i},[subjects{i},'_erp']),'dir') == 0
    %if isempty(ls(fullfile(datadir,subjects{i},[subjects{i},'_erp'],'*mat')));
        
        % Create new subject folder
        mkdir(fullfile(datadir,subjects{i},[subjects{i},'_erp']));
        
        % Load MAT files
        load(fullfile(datadir,subjects{i},[subjects{i},'_mat'],[subjects{i},'.mat']));
        
%         for j = 1:length(EEG.urevent)
%             if ~ischar(EEG.urevent(j).type)
%                 alltrigs(j) = EEG.urevent(j).type;
%             else
%                 alltrigs(j) = 999;
%             end
%         end
%         uniqueTrigs = unique(alltrigs);
%         for j = 1:length(uniqueTrigs)
%             trigs{j} = num2str(uniqueTrigs(j));
%         end
%         
        trigs(ismember(trigs,{'252','253','999'})) = [];
        
        % Filter EEG
        disp('Filtering EEG...');
        EEG.data = filtfilthd(hpf,EEG.data');
        EEG.data = filtfilthd(lpf,EEG.data)';
        disp('Done Filtering...');
        % Remove external channels
        EEG.data = EEG.data(1:nChans,:);
        EEG.nbchan = nChans;
        disp('Finding bad channels...');
        % Find bad channels based on XCORR and SD
        badChans = findBadChans(EEG.data',nearCell,3,3);
        
        % Spline interpolate bad channels
        if ~isempty(badChans)
            EEG = pop_interp(EEG,badChans,'spherical');
        end
        % Re-refernece to average of all channels
        EEG = pop_reref(EEG,[],'exclude',257:size(EEG.data,1));
        
        maxVals = [];
        ERPs = cell(numel(trigs),1);
        for j = 1:numel(trigs)
            % Extract epochs for each condition
            ERPs{j} = pop_epoch(EEG,trigs(j),[tmin/1e3,tmax/1e3]);
            
            % Calculate max/min values of epochs
            maxVals = [maxVals;squeeze(max(max(abs(ERPs{j}.data(1:nChans,1:308,:)))))];
        end
        
        % Get rid of outliers above threshold 1 (150 uV)
        maxVals(maxVals>thr1) = [];
        
        % Set threshold 2 based on normal distribution of max/min values
        thr2 = mean(maxVals) + 2*std(maxVals);
        
        % Rejection epochs above threshold
        for j = 1:numel(trigs)
            ERPs{j} = pop_eegthresh(ERPs{j},1,1:nChans,-thr2,thr2,thrMin/1e3,thrMax/1e3,0,1);
            ERPs{j} = pop_rmbase(ERPs{j},[blmin,blmax]);
        end
        
        % Get reaction times
        RTs = cell(1,numel(trigs));
        for j = 1:numel(trigs)
            RTs{j} = zeros(1,ERPs{j}.trials);
            for k = 1:ERPs{j}.trials
                try
                    RTs{j}(k) = cell2mat(ERPs{j}.epoch(k).eventlatency(2));
                catch
                    RTs{j}(k) = 0;
                end
            end
        end
        
        % Calculate average ERP
        ERPavg = cell(numel(trigs));
        for j = 1:numel(trigs)
            ERPavg{j} = squeeze(mean(ERPs{j}.data,3));
        end
        
        t = ERPs{1}.times;
        fs = ERPs{1}.srate;
        
        % Save in MAT files
        disp('Saving data to mat file...');
        save(fullfile(datadir,subjects{i},[subjects{i},'_erp'],[subjects{i},'.mat']),'ERPs','ERPavg','RTs','t','fs','-mat');
        clear files EEG ERPs maxVals thr2 RTs ERPavg t fs
        
    end
end

