clear all;
close all;

noDataCarrier = 16;
noTotCarrier = 64;
Ts = 1/882;
Fs = 44100;
Fc = 10000;

rxSignal = wavread(filename);

rxSignal = freqDownConversion(txSignal, Fc, Fs);
rxSignal = [zeros(1,1); rxSignal];
%%%%%% Apply LPF %%%%%%%%
rxSignal = [rxSignal; zeros(lpfDelay,1)];
filtRxSignal = filter(lpf, rxSignal);
filtRxSignal = filtRxSignal(lpfDelay+1 :end);

%%%%%%%%%%%%%%%%%%%
dumpedSignal = intdump(filtRxSignal(1:3200), Fs * Ts);
rxFftResult = fft(dumpedSignal);


figure(3);
subplot(3,2,3); plot(real(rxSignal)); hold on; plot(imag(rxSignal),'g'); hold off;
subplot(3,2,4); pwelch(filtRxSignal,[],[],[], Fs, 'centered');
subplot(3,2,5); plot(real(dumpedSignal)); hold on; plot(imag(dumpedSignal),'g'); hold off;
subplot(3,2,6); stem(real(rxFftResult)); hold on; stem(imag(rxFftResult),'g'); hold off;
