

TapirConf;

cPreLength = 0;
cPostLength = 0;
Fc = 20000;


txLpf = txrxLpfRC;
txLpfDelay = txLpf.order / 2;

txBpf = txrxHpf;
txBpfDelay = ceil(txBpf.order / 2);

msg = 'g';
binData = dec2bin(msg, 8)' - 48
genAudioData = generateAudioData(binData);
% extendedAudioData = zeros(size(genAudioData,1) + cPreLength + cPostLength, size(genAudioData,2));

for idx=1:size(genAudioData, 2)
    lpfAudioData = [genAudioData(:,idx); zeros(txLpfDelay,1)];
    lpfAudioData = filter(txLpf, lpfAudioData);
    lpfAudioData = lpfAudioData(txLpfDelay+1:end);
    upconvAudioData = freqUpConversion(lpfAudioData(:,idx), Fc, Fs);    
    % Add Cyclic prefix&postfix
%     extendedAudioData(1:length(extendedAudioData),idx) = [upconvAudioData(end - cPreLength + 1 : end); upconvAudioData; upconvAudioData(1:cPostLength)];
end
% extendedAudioData = [extendedAudioData; zeros(guardInterval, size(extendedAudioData,2))];
audioData = reshape(upconvAudioData, [], 1);

testAudioData = audioData;
testAudioData = [testAudioData; zeros(txBpfDelay,1)];
testAudioData = filter(txBpf, testAudioData);  % Filtering
testAudioData = testAudioData(txBpfDelay+1:end);

% figure();
% plot(real(testAudioData));
% plot(imag(testAudioData));
% audiowrite('g.wav', testAudioData, Fs, 'BitsPerSample', 16);