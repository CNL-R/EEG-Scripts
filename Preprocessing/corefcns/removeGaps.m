function y = removeGaps(x,fs,t,thr,newGap)

% Inputs:
% x = signal with gaps to be removed
% fs = sample rate of x
% t = minimum time window of gaps (s)
% thr = amplitude threshold of gaps
% 
% Outputs:
% y = signal with gaps removed

y = x;
gap = fs*t;
idx = find(abs(x)<thr);
consec = diff(idx)==1;
idxRange = idx([false;consec]~=[consec;false]);
sizeGaps = diff(idxRange);
sizeGaps(2:2:end-1) = 0;
idxGapsMin = idxRange(sizeGaps>gap);
idxGapsMax = idxRange(find(sizeGaps>gap)+1);

for j = 1:length(idxGapsMin)
    if newGap == 0
        y(idxGapsMin(end-j+1):idxGapsMax(end-j+1)) = [];
    elseif newGap == 1
        y(idxGapsMin(end-j+1)+gap:idxGapsMax(end-j+1)) = [];
    else
        error('Not a valid input.')
    end
end

end

