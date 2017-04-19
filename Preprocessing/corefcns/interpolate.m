function eegInterp = interpolate(eeg,Fs,chanLocs,badChans)

if ~isempty(badChans)

    % Format data for EEGLAB
    EEG.setname = 'NAME';
    EEG.data = eeg';
    EEG.srate = Fs;
    EEG.nbchan = size(eeg,2);
    EEG.pnts = size(eeg,1);
    EEG.xmin = 0;
    EEG.xmax = 60;
    EEG.trials = 1;
    EEG.chanlocs = chanLocs; 
    EEG.ref = 'common';
    EEG.epoch = [];
    EEG.event = [];
    EEG.reject = [];
    EEG.stats = [];
    EEG.etc = [];
    EEG.specdata = [];
    EEG.specicaact = [];
    EEG.icaact = [];
    EEG.icawinv = [];
    EEG.icasphere  = [];
    EEG.icaweights = [];
    EEG.icachansind = [];

    % Interpolate bad channels
    iEEG = eeg_interp(EEG,badChans);
    
    eegInterp = iEEG.data';
    
else
    
    eegInterp = eeg;
    
end

end
