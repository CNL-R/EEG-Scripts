% This is a script to prep the Obama data for a TANOVA.

% Written by Ed Lalor. 28/07/10.

close all; clear all; clc

subj = {'SC' 'BL' 'AS' 'AD' 'HF' 'GL' 'MH' 'LAL' 'ALV' 'JM' 'DK' 'MC' 'DM' 'EL'};
type = {'V' 'A' 'AV'};
chans = 128;
fs = 512;
windowSize = 276;
w = zeros(length(subj),length(type),chans,windowSize);

% % Load yizzer data:
% for s = 1:length(subj)
%     for t = 1:length(type)
%         load(['C:\Users\TCDUSER\Documents\Data\Obama\' subj{s} '_w\' subj{s} '_' type{t} '_resamp_filtenv_avg.mat']);
%         w(s,t,:,:) = w_avg;
%     end
% end

% Invert:
% w = w*-1;

for s = 1:length(subj)
            
    for t = 2:length(type)
            
        if t == 2
            n1peak = 116:120; % Sample 118 (110 ms) 
            p2peak = 140:144; % Sample 142 (156 ms) 
        elseif t == 3
            n1peak = 111:115; % Sample 113 (99 ms) 
            p2peak = 136:140; % Sample 138 (148 ms)
        end

        filename_n1 = ['C:\Users\TCDUSER\Documents\Data\Obama\TANOVA\Condition_' type{t} '_N1\' subj{s} '_' type{t} '_N1.eph'];
        filename_p2 = ['C:\Users\TCDUSER\Documents\Data\Obama\TANOVA\Condition_' type{t} '_P2\' subj{s} '_' type{t} '_P2.eph'];
        
        % Inverted files:
%         filename_n1 = ['C:\Users\TCDUSER\Documents\Data\Obama\TANOVA\Condition_' type{t} '_inv_N1\' subj{s} '_' type{t} '_inv_N1.eph'];
%         filename_p2 = ['C:\Users\TCDUSER\Documents\Data\Obama\TANOVA\Condition_' type{t} '_inv_P2\' subj{s} '_' type{t} '_inv_P2.eph'];
        
        fid_n1 = fopen(filename_n1,'w');
        fid_p2 = fopen(filename_p2,'w');

        temp = squeeze(w(s,t,:,:))';
        temp_n1 = mean(temp(n1peak,:),1);
        temp_p2 = -mean(temp(p2peak,:),1);

        fprintf(fid_n1,'%d\t%d\t%d\t\n',chans,1,fs);
        fprintf(fid_p2,'%d\t%d\t%d\t\n',chans,1,fs);

        for j = 1:size(temp,2)
            fprintf(fid_n1,'%f\t',temp_n1(j));
            fprintf(fid_p2,'%f\t',temp_p2(j));
        end

        fclose(fid_n1);
        fclose(fid_p2);

    end
    
end