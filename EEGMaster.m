% EEG Analysis Master fcn. This manages the conversion of your data into a matlab
% friendly format and carries it through preprocessing
% Testing edits to branches
clear all;
clc;
rootdir = uigetdir;
load('chanlocs256.mat');
bdf2mat(rootdir,chanlocs);