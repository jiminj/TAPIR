
clear;

%settings
TapirConf;
Fc = 20000;

src = [];

for idx = 1:21
    src = [src, 5*idx + 69];
end

pwd = './result/'
filenamePrefix = 'Paris';
srcRepeat = 2;
resultRepeat = 10;

%generation
    
txLpf = lpfbtw208;
txLpfDelay = txLpf.order / 2;
txHpf = bpfchev19k21k250;
txHpfDelay = txHpf.order / 2;


figure(11);

for fIdx = 1:length(src)

    msg = repmat(src(fIdx), 1, srcRepeat);
    msg = [msg, 3]; %ETX Code

    binData = dec2bin(msg, 8)' - 48;
    genAudioData = generateAudioData(binData);
    extendedAudioData = zeros(size(genAudioData,1) + cPreLength + cPostLength, size(genAudioData,2));
  
    for idx=1:size(extendedAudioData, 2)

        upconvAudioData = freqUpConversion(genAudioData(:,idx), Fc, Fs);    
        % Add Cyclic prefix&postfix
        extendedAudioData(1:length(extendedAudioData),idx) = [upconvAudioData(end - cPreLength + 1 : end); upconvAudioData; upconvAudioData(1:cPostLength)];
    end
    extendedAudioData = [extendedAudioData; zeros(guardInterval, size(extendedAudioData,2))];
    audioData = reshape(extendedAudioData, [], 1);
    
    %Prepend Preamble
    preambleData = generateSinPreamble(preambleBitLength, preambleBandwidth, Fs);
    preambleData = [preambleData; preambleData; zeros(txLpfDelay,1)];
    preambleData = filter(txLpf, preambleData);
    preambleData = preambleData(txLpfDelay+1:end);
    
    upconvPreamble = freqUpConversion(preambleData, Fc, Fs);

    audioData = [upconvPreamble; zeros(preambleInterval,1); audioData];
    
    %lpf
    audioData = [audioData; zeros(txLpfDelay*2,1)];
    audioData = filter(txLpf, audioData);
    audioData = audioData(txLpfDelay+1:end);
    
    %hpf
    audioData = [audioData; zeros(txHpfDelay*2,1)];
    audioData = filter(txHpf, audioData);  % Filtering
    audioData = [zeros(floor(Fs/5),1);audioData;zeros(floor(Fs/5),1)];
%     

    
    audioData = repmat(audioData, resultRepeat, 1);
    figure(11);
    subplot(length(src),2,fIdx * 2 - 1); plot(real(audioData));
    subplot(length(src),2,fIdx * 2); pwelch(audioData, hamming(1024),[],[],Fs,'centered');

    
    %write
    filename = [filenamePrefix, '_', int2str(fIdx), '_', int2str(src(fIdx))];
    filename = [pwd, filename, '.wav'];
    audiowrite(filename, audioData, Fs, 'BitsPerSample', 16);
    
    
end

    