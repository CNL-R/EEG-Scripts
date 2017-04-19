function [mx,f] = power_spectrum(x,fs)

% Function to calculate the power spectrum of a signal.
% 
% Inputs:
% x - signal.
% fs - sample rate of signal.
% 
% Outputs:
% mx - power spectrum.
% f - frequency axis.

% Use next highest power of 2 greater than or equal to length(x) to 
% calculate FFT. Using a power of 2 ensures computational efficiency.
nfft = 2^nextpow2(length(x));

% Take FFT, padding with zeros so that length(fftx) is equal to nfft. Zero-
% padding improves the spectral resolution of the FFT.
fftx = fft(x,nfft);    

% Calculate the number of unique points.
numUniquePts = ceil((nfft+1)/2);

% The FFT is symmetric so we throw away the second half.
fftx = fftx(1:numUniquePts);

% Take the magnitude of FFT of x and scale the FFT so that it is not a 
% function of the length of x.
mx = abs(fftx)/length(x);

% Take the square of the magnitude of FFT of x.
mx = mx.^2;

% Since we dropped half the FFT, we multiply mx by 2 to keep the same 
% energy. The DC component and Nyquist component, if it exists, are unique 
% and should not be multiplied by 2.
if rem(nfft,2)
  mx(2:end) = mx(2:end)*2;
else
  mx(2:end-1) = mx(2:end-1)*2;
end

% This is an evenly spaced frequency vector with NumUniquePts points. 
f = (0:numUniquePts-1)*fs/nfft;