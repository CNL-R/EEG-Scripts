function [data,trigs,Fs] = readbdf(filename)

dat = openbdf(filename);

headLen = dat.Head.HeadLen;
nRec = dat.Head.NRec;
Fs = dat.Head.SampleRate(1);
nChans = dat.Head.NS;
oneSec = Fs*nChans;

fid = fopen(filename,'r');

data = zeros(nRec*Fs,nChans);

n = 0;
while fseek(fid,(headLen+(n+1)*oneSec*3),'bof') == 0
    fseek(fid,(headLen+n*oneSec*3),'bof');
    for j = 1:nChans
        data(n*Fs+(1:Fs),j) = fread(fid,Fs,'bit24')';
    end        
    n = n+1;
end

fclose(fid);

trigs = data(:,nChans)-min(data(:,nChans));
trigs(trigs>2^8) = trigs(trigs>2^8)-2^16;
data = data(:,1:(nChans-1))*524e3/2^24;

end