
testVal = [0,0,1,1,zeros(1,2040),0,0,1,1];
fftTest = fft(testVal); 
fftTest = [fftTest, fftTest];
ifftTest = ifft(fftTest(2:2049));


figure();
subplot(3,1,1); 
stem(testVal); 
subplot(3,1,2); 
plot(real(fftTest)); 
subplot(3,1,3); 
stem(real(ifftTest)); hold on; stem(imag(ifftTest),'g');