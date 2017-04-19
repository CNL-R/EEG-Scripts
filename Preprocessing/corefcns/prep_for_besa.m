% This is a script to prep the Obama data for BESA.

% Written by Ed Lalor. 08/02/10

close all; clear all; clc

subj = {'SC' 'BL' 'AS' 'AD' 'HF' 'GL' 'MH' 'LAL' 'ALV' 'JM' 'DK' 'MC' 'DM'};
type = {'A' 'V' 'AV'};
chans = 128;
window_size = 276;
w = zeros(length(subj),length(type),chans,window_size); % 13 subjects, 3 conditions, 128 channels, 276 timepoints

% Load yizzer data:
for s = 1:length(subj)
    for t = 1:length(type)
%         load(['C:\Users\TCDUSER\Documents\Data\Obama\' subj{s} '_w\' subj{s} '_' type{t} '_avg.mat']);
        load(['C:\Users\TCDUSER\Documents\Data\Obama\' subj{s} '_w\AVG_' subj{s} '_' type{t} '_avg.mat']);
        w(s,t,:,:) = w_avg;
    end
end

% % Reference data to average:
% for i = 1:size(w,1)
%     for j = 1:size(w,2)     
%         w(i,j,:,:) = w(i,j,:,:) - reshape(repmat(squeeze(mean(w(i,j,:,:),3)),1,128)',1,1,128,276);
%     end
% end

A = squeeze(mean(w(:,1,:,:),1));
V = squeeze(mean(w(:,2,:,:),1));
AV = squeeze(mean(w(:,3,:,:),1));

clear w;

% % fid_A = fopen('C:\Users\TCDUSER\Documents\Data\Obama\BESA\A_data.asc', 'w');
% fid_A = fopen('C:\Users\TCDUSER\Documents\Data\Obama\BESA\AVG_A_data.asc', 'w');
% fprintf(fid_A,[repmat('%f\t',[1 128]) '\n'], A); 
% fclose(fid_A);

% fid_V = fopen('C:\Users\TCDUSER\Documents\Data\Obama\BESA\V_data.asc', 'w');
fid_V = fopen('C:\Users\TCDUSER\Documents\Data\Obama\BESA\AVG_V_data.asc', 'w');
fprintf(fid_V,[repmat('%f\t',[1 128]) '\n'], V); 
fclose(fid_V); 

% % fid_AV = fopen('C:\Users\TCDUSER\Documents\Data\Obama\BESA\AV_data.asc', 'w');
% fid_AV = fopen('C:\Users\TCDUSER\Documents\Data\Obama\BESA\AVG_AV_data.asc', 'w');
% fprintf(fid_AV,[repmat('%f\t',[1 128]) '\n'], AV); 
% fclose(fid_AV);

