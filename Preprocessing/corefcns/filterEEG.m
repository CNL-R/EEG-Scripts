function [] = filterEEG(filename)

[EEG,trigs] = readbdf(filename);

% Low pass filter

load lpf

for i = 1:size(EEG,1)
    EEG(i,:) = filtfilt(EEG(i,:), Num, Den);
end

% High pass filter

load hpf

for i = 1:size(EEG,1)
    EEG(i,:) = filtfilt(EEG(i,:), Num, Den);
end

save (EEG, trigs, format, '-mat') 