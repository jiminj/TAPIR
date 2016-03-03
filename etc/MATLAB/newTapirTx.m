
clear all;
close all;

noDataCarrier = 16;
noTotCarrier = 64;
Ts = 1/882;
Fs = 44100;
Fc = 10000;


% data =-1+2*round(rand( noDataCarrier, 1));
data = [1; -1; -1; -1; 1; -1; 1; 1; -1; -1; -1; 1; 1; 1; -1; 1];
origData = data;
data =[data(1:length(data)/2); zeros(noTotCarrier - noDataCarrier, 1); data(end - length(data)/2 + 1:end)];

signal = noDataCarrier .* ifft(data);
extSignal = rectpulse(signal, Fs*Ts);

%%%%%% Apply LPF %%%%%%%%
lpf = txrxLpf;
lpfDelay = ceil(lpf.order / 2);
extSignal = [extSignal; zeros(lpfDelay,1)];
lpfExtSignal = filter(lpf, extSignal);
lpfExtSignal = lpfExtSignal(lpfDelay+1 : end);

% [filtNum,filtDen] = butter(15, 1/100 ); %reconstruction filter 
% filtSignal = filter(filtNum, filtDen, extSignal);

% txLpf = txLpf_441;
% txLpfDelay = ceil(txLpf.order / 2);
% extSignal = [extSignal];
% lpfExtSignal = filter(txLpf, extSignal);
% lpfExtSignal = lpfExtSignal(txLpfDelay+1:end);

txSignal = freqUpConversion(lpfExtSignal, Fc, Fs);
sound(txSignal,Fs);



figure(1);
subplot(2,2,1); stem(origData);
subplot(2,2,2); stem(data);
subplot(2,2,3); plot(real(signal)); hold on; plot(imag(signal),'g'); hold off;
subplot(2,2,4); pwelch(signal,[],[],[], Ts, 'centered');

figure(2);
subplot(3,3,1); plot(real(extSignal)); hold on; plot(imag(extSignal),'g'); hold off;
subplot(3,3,2); stem(real(fft(extSignal)));
subplot(3,3,3); pwelch(extSignal,[],[],[], Fs, 'centered');
subplot(3,3,4); plot(real(lpfExtSignal)); hold on; plot(imag(lpfExtSignal),'g'); hold off;
subplot(3,3,5); stem(real(fft(lpfExtSignal)));
subplot(3,3,6); pwelch(lpfExtSignal,[],[],[], Fs, 'centered');
subplot(3,3,7); plot(txSignal);
subplot(3,3,8); pwelch(txSignal,[],[],[], Fs, 'centered');

