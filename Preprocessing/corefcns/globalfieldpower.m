function gfp = globalfieldpower(TRF)
%GLOBALFIELDPOWER Reference-independent measure of response strength.
%   [GFP] = GLOBALFIELDPOWER(TRF) calculates the standard deviation across 
%   time of all channels of temporal response function data TRF and returns 
%   a measure of global field power GFP.
% 
%   Inputs:
%   TRF - temporal response function (channels x time)
%     
%   Outputs:
%   gfp  - global field power (1 x time)
% 
%   Example: 
%   128-channel EEG was recorded at 512Hz. Stimulus was natural speech, 
%   presented at 48kHz for 60 seconds. The envelope of the speech waveform 
%   was got using a Hilbert transform and was then downsampled to 512Hz.
%      >> [w,t] = mTRF(envelope,EEG,512,4.4e2,-220,520);
%      >> gfp = globalfieldpower(w);
%      >> plot(t,gfp); 
%
%   See also MTRF, STIMULIRECONSTRUCTION.

%   References:
%      [1] Lehmann D, Skrandies W (1980). Reference-free identification of 
%          components of checkerboard-evoked multichannel potential fields.
%          Electroencephalography and Clinical Neurophysiology, 48:609–21.
%      [2] Murray MM, Brunet D, Michel CM (2008). Topographic ERP analyses: 
%          a step-by-step tutorial review. Brain Topography, 20:249–264.
%      [3] Lalor EC, Power AP, Reilly RB, Foxe JJ (2009). Resolving precise 
%          temporal processing properties of the auditory system using 
%          continuous stimuli. Journal of Neurophysiology, 102(1):349-359.

%   Author: Edmund Lalor & Lab, Trinity College Dublin
%   Email: edmundlalor@gmail.com
%   Website: http://sourceforge.net/projects/aespa/
%   Version: 1.0
%   Last revision: 20 March 2014

% % Old method
% gfp = zeros(1,size(TRF,1));
% for i = 1:size(TRF,1)
%     gfp(i) = sqrt(sum((TRF(i,:)-mean(TRF(i,:))).^2)/size(TRF,2));
% end

% New method
gfp = sqrt(sum((TRF-repmat(mean(TRF,2),[1,size(TRF,2)])).^2,2)/size(TRF,2)); 

% % Ah for fuck sake
% gfp = std(TRF);

end