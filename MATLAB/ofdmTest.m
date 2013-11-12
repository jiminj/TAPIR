clear

data = -1+2*round(rand( 16, 1));
ifftData = ifft( [ zeros(1,1); data(1:8); zeros(2030,1); data(9:16); zeros(1,1)]);

lpf = txrxLpf;
lpfDelay = lpf.order / 2


lpfExtBlock = [zeros(length(ifftData),1); ifftData; ifftData; zeros(lpfDelay, 1);zeros(length(ifftData),1)];
lpfExtBlock = filter(lpf, lpfExtBlock);
sendData = freqUpConversion( lpfExtBlock(lpfDelay : end), 20000, 44100);

rcvData = awgn(sendData,1,'measured');

offset = 2;
recoveredData = freqDownConversion(rcvData(offset:end), 20000, 44100);

roi = recoveredData(4097:6144);
resultData = fft(roi);

figure();
subplot(7,1,1);
stem(data);
subplot(7,1,2);
plot(sendData);
subplot(7,1,3);
plot(real(recoveredData));
subplot(7,1,4);
plot(real(roi));
subplot(7,1,5);
stem(real(resultData)); hold on;
stem(imag(resultData),'g'); hold off;
subplot(7,2,11);
stem(real(resultData(1:20))); hold on;
stem(imag(resultData(1:20)),'g'); hold off;
subplot(7,2,12);
stem(real(resultData(2029:2048))); hold on;
stem(imag(resultData(2029:2048)),'g'); hold off;

subplot(7,1,7);
pwelch(rcvData, [],[],[],44100,'centered');