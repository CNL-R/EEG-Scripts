% Reads in electrode locations

function [ELA,nearest] = getnearest(filename,numelecs,numneighbor)

[ELA,Ex,Ey,Ez]=textread(filename,'%s %n %n %n');
Ex(strmatch('Fid',ELA))=[];Ey(strmatch('Fid',ELA))=[];Ez(strmatch('Fid',ELA))=[];ELA(strmatch('Fid',ELA))=[];
Ex=Ex(1:numelecs);Ey=Ey(1:numelecs);Ez=Ez(1:numelecs);ELA=ELA(1:numelecs);

for n=1:length(ELA)
    for m=1:length(ELA)
        dis(m)=((Ex(m)-Ex(n))^2+(Ey(m)-Ey(n))^2+(Ez(m)-Ez(n))^2)^0.5; 
    end
    [temp,I]=sort(dis); clear temp
    nearest(n,:)=I(2:numneighbor+1);
end


for n = 1:length(ELA)
    for m = 1:length(ELA)
        dist(m) = sqrt((Ex(m)-Ex(n))^2+(Ey(m)-Ey(n))^2+(Ez(m)-Ez(n))^2);
    end
    [quax,afos] = sort(dist); clear temp
    nearnear(n,:) = afos(2:numneighbor+1);
end