
clear;
% pnCode = [1;1;1;1;1;-1;-1;1;1;-1;1;-1;1];


hBCode = comm.BarkerCode('SamplesPerFrame', 4);
barkerSeq = step(hBCode);

Fc = 20000;
Fs = 44100;

bandwidth = 441;
samplesPerPhase = Fs/bandwidth;

t=0:1/Fs:(samplesPerPhase * length(barkerSeq) -1 ) / Fs;
modMatrix = rectpulse(barkerSeq, samplesPerPhase);
% carrier = cos(2 * pi * Fc * t)';
% modCarrier = modMatrix .* carrier;
modCarrier = freqUpConversion(modMatrix, Fc,Fs)

% http://www.ndt.net/article/v08n07/armanav/armanav.htm

lenPn = length(modCarrier);


data = -1+2*round(rand( 16, 1));
ifftData = ifft( [ zeros(1,1); data(1:8); zeros(2030,1); data(9:16); zeros(1,1)]);


upData = freqUpConversion(ifftData, Fc, 20000);

sig = [zeros(2000,1); modCarrier; modCarrier; upData; zeros(2000,1)];




txBpf = txBpf20k;
txBpfDelay = ceil(txBpf.order / 2);
filteredSig = filter(txBpf, sig);  % Filtering



% rcvSig = awgn(filteredSig,1,'measured');
rcvSig = filteredSig;


% rxAudioData = audioread('testSync_rec.wav');
% rcvSig = rxAudioData;

result = zeros(length(rcvSig),1);
for idx=lenPn*2+1:length(result)
    for k = 0:(lenPn - 1)
        result(idx) = result(idx) + rcvSig(idx - k) * rcvSig(idx - k - lenPn);
    end
end;


% result = result(lenPn+1:end);
% audiowrite('testSync.wav', filteredSig, Fs, 'BitsPerSample', 16)

figure();
subplot(4,1,1);
plot(sig);

subplot(4,1,2);
plot(rcvSig);


subplot(4,1,3);
plot(result);

subplot(4,1,4);
pwelch(rcvSig, [],[],[], Fs,'centered');
