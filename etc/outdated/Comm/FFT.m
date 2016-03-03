y = x2;
L = length(y);

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
%subplot(2,1,1);
plot(f,20*log10(2*abs(Y(1:NFFT/2+1)))) 
xlabel('Frequency (Hz)')
ylabel('Magnitude(dB)')


