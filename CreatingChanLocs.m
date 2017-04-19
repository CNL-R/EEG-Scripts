%make chanlocsXXX.mat file from excel file

xlfile = uigetfile('*');

[NUM, TXT, RAW] = xlsread(xlfile);

chanlocs = struct('Y',[],'X',[],'Z',[],'labels',[],'sph_theta',[],'sph_radius',[],'theta',[],'radius',[],'urchan',[]);

for i = 1:length(RAW)
    chanlocs(i).labels = RAW{i,1};
    chanlocs(i).theta = RAW{i,2};
    chanlocs(i).sph_theta = -1*RAW{i,2};
    chanlocs(i).sph_radius = RAW{i,3};
    chanlocs(i).radius = RAW{i,3};
    chanlocs(i).urchan = i;
    chanlocs(i).X = RAW{i,4};
    chanlocs(i).Y = RAW{i,5};
    chanlocs(i).Z = RAW{i,6};
end

