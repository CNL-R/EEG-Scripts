function [data,trigs] = loadbdfSKed(filename)

% filename = 'F:\Data\Visual Motion\DD\Raw\DD_magna_2.bdf';

% loads a bdf file, returns the continuous data filtered up to 45 Hz with channels in the columns, 
% and the trigger values and trigger times in sample points

a = sopen(filename);

numelecs = a.NS-1;
fs = a.SPR;

[data, trigs] = readbdfedall_thegoodone(filename);

% [B,A]=butter(4,2*45/fs);
[H,G]=butter(4,1/fs,'high');   % 0.5 Hz low cutoff

B = load('LowPassFilter.txt');
A = 1;

if (numelecs == 72)
    [ELA,nearest] = getnearest('dublin_CORRECTED.sfp',numelecs,6);     % gets 6 nearest electrodes
elseif (numelecs == 168)
    [ELA,nearest] = getnearest('BioSemi168.sfp',numelecs,6);     % gets 6 nearest electrodes
else
    [ELA,nearest] = getnearest('Skelly-136.sfp',numelecs,6);     % gets 6 nearest electrodes
end

% Get triggers
trigs=trigs-min(trigs);
trigs(trigs>256) = trigs(trigs>256)-min(trigs(trigs>256));
trigs(trigs>256) = trigs(trigs>256)-min(trigs(trigs>256));
for i = 2:length(trigs)-1
    if (trigs(i) ~= trigs(i-1))&&(trigs(i) ~= trigs(i+1))
        trigs(i) = trigs(i-1);
    end
end
% stimes = find(trig(2:end)<256 & trig(2:end)>0.5 & trig(1:end-1)<0.5)+1;
% trigs = trig(stimes);

disp([filename ': ' num2str(length(trigs)) ' triggers']);
if length(trigs)<2, data=[]; return; end

% if size(data,1)>numelecs+1, 
    data(abs(data(:,100)-median(data(numelecs-8:end,100)))<0.1,:)= zeros(size(data(abs(data(:,100)-median(data(numelecs-8:end,100)))<0.1,:),1),size(data,2));    % arbitrarily chose data point 100 to find flat channels
% end
% data(end,:)=[];
% if size(data,1)>numelecs, disp([filename ' has ' num2str(size(data,1)) ' channels, channel 168 is ' a.Label(168,:)]); end
% if size(data,1)<numelecs, disp([filename ' has ' num2str(size(data,1)) ' channels, skipping it...']); return; end

% start = stimes(find(trigs>1,1)); fin = stimes(find(trigs>1,1,'last'));
start = find(trigs>1,1); fin = find(trigs>1,1,'last');
numparts=5;
SD=zeros(numelecs,numparts);
for q=1:numelecs
    data(q,:) = filtfilt(B,A,data(q,:));
    % break into 5 parts so that a channel won't be assigned as bad if it's only bad for a few seconds (need interp in main code then):
    for p=1:numparts
        SD(q,p) = std(filtfilt(H,G,data(q,start+(p-1)*floor((fin-start)/numparts)+[1:floor((fin-start)/numparts)])));
    end
end

% ***************     find bad channels:
BCparts = zeros(numelecs,numparts);
for p=1:numparts
    BC = find(SD(:,p)>15);
    for n=fliplr(1:length(BC))
        % if it's not at least 50% bigger than the SDs of at least half the 6 neighboring ones then it's not really a bad channel
        if length(find(SD(nearest(BC(n),:),p)*1.5<SD(BC(n),p))) <3  % if it's not at least 50% bigger than the SDs of at least 2 surrounding ones
            BC(n)=[];                                               % then it's not really a bad channel
        end
    end
    BCparts(BC,p)=1;
end
% Only mark channels as bad if they are bad for more than 1 of the parts:
BC = find(sum(BCparts,2)>1);
notsoBC = find(sum(BCparts,2)>0);

% and zero channels
Flatparts = zeros(numelecs,numparts);
for p=1:numparts
    flat = find(SD(:,p)<0.5);
    for n=fliplr(1:length(flat))
        % if it's not smaller than half the SD of at least half of the 6 neighboring channels ...
        if length(find(SD(nearest(flat(n),:),p)*.5>SD(flat(n),p))) <3
            flat(n)=[];
        end
    end
    Flatparts(flat,p)=1;
end
flat = find(sum(Flatparts,2)>0);

disp([num2str(length(BC)) ' bad channels found:'])
for n=1:length(BC),disp(ELA{BC(n)}); end;
disp([num2str(length(flat)) ' flat channels found:'])
for n=1:length(flat),disp(ELA{flat(n)}); end;

% join:
notsoBC = [notsoBC;flat];
BC = [BC;flat];
% Don't interpolate eye channels:
BC(BC==numelecs | BC==numelecs-1 | BC==numelecs-7 | BC==numelecs-6) = [];
notsoBC(notsoBC==numelecs | notsoBC==numelecs-1 | notsoBC==numelecs-7 | notsoBC==numelecs-6) = [];

% Interpolate bad channels (linear)
for n=1:length(BC)
    clear neighbors
    % Average across the nearest 3 or 4 electrodes that aren't bad
    k=0; for m=1:6, if isempty(find(notsoBC==nearest(BC(n),m),1)), k=k+1; neighbors(k)=nearest(BC(n),m); if m>=4 && k>=3,break,end, end, end
    data(BC(n),:) = mean(data(neighbors,:));
end

H = load('HighPassFilter.txt');
G = 1;

for q=1:numelecs
    data(q,:) = filtfilt(H,G,data(q,:));
end

% re-reference:
% data = X.Record(1:numelecs,:)' - repmat(mean(X.Record(1:numelecs,:)),[numelecs,1])';      % average reference
% data = X.Record(1:numelecs,:)' - repmat(X.Record(numelecs-1,:),[numelecs,1])';      % reference to Nas
data = data(1:numelecs,:);
clear X