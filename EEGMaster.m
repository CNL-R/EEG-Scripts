% EEG Analysis Master fcn. This manages the conversion of your data into a matlab
% friendly format and carries it through preprocessing

clear all;
clc;
rootdir = uigetdir;
load('chanlocs32.mat');

bdf2mat(rootdir,chanlocs);

preprocdat(rootdir,chanlocs);

