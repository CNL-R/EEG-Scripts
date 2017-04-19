function badChans = findBadChans(EEG,nearest,thr1,thr2)

% Finds bad EEG channels based on channel covariance and standard
% deviation.
% 
% Inputs:
% EEG  - EEG data (time x channels)
% thr1 - covariance threshold
% thr2 - standrard deviation threshold
% 
% Output:
% badChans - bad EEG channels
% 
% Mitch & Jim
% 22/03/2015

if ~exist('thr1','var') || isempty(thr1)
    thr1 = 2;
end
if ~exist('thr2','var') || isempty(thr2)
    thr2 = 2;
end

badChans1 = [];
badChans2 = [];

EEGz = zscore(EEG);
XTX = EEGz'*EEGz;
stdXTX = std(XTX);
stdEEG = std(EEG);

% Compare to nearest channels
for i = 1:size(EEG,2)
    % Covariance
    if stdXTX(i) < mean(stdXTX(nearest{i}))/thr1  
        badChans1 = [badChans1,i];
    end
    % Standard deviation
    if stdEEG(i) > mean(stdEEG(nearest{i}))*thr2 %|| stdEEG(i) < mean(stdEEG(nearest{i}))/thr2 
        badChans2 = [badChans2,i];
    end
end

% Compare to all channels
EEGz = zscore(EEG);
XTX = EEGz'*EEGz;
stdXTX = std(XTX);
badChans1 = find(stdXTX<mean(stdXTX)/thr1);
if ~isempty(badChans1)
    tmpChans = [];
    while size(tmpChans) ~= size(badChans1)
        tmp = stdXTX;
        tmp(:,badChans1) = [];
        tmpChans = badChans1;
        badChans1 = find(stdXTX<mean(tmp)/thr1);
        clear tmp
    end
    clear tmpChans
end

stdEEG = std(EEG);
badChans2 = unique([find(stdEEG<mean(stdEEG)/thr2),find(stdEEG>mean(stdEEG)*thr2)]);
if ~isempty(badChans2)
    tmpChans = [];
    while size(tmpChans) ~= size(badChans2)
        tmp = stdEEG;
        tmp(:,badChans2) = [];
        tmpChans = badChans2;
        badChans2 = unique([find(stdEEG>mean(tmp)*thr2),find(stdEEG>mean(tmp)*thr2)]);
        clear tmp
    end
    clear tmpChans
end

badChans = unique([badChans1,badChans2,badChans3]);
disp(['Bad channels: ',num2str(badChans1),' (cov), ',num2str(badChans2),' (std), ',num2str(badChans3),' (rng)']);
