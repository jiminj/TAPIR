function [ resultMat ] = testDecoding( signal, Fc)
    TapirConf;
    pilotLen = length(pilotSig);
    roiBitLength = noDataCarrier + pilotLen;
    pilotInterval = floor(noDataCarrier / (pilotLen+1));
    noBlksPerSig = 1;
    
    
    pilotLocation = [];
    for idx = 1:pilotLen
        pilotLocation = [pilotLocation; (idx * pilotInterval + idx)];
    end
    
    analyzedMat = zeros(noDataFrame * modulationRate, noBlksPerSig);
    blkIdx = 1;
    pos = preambleInterval + cPreLength;
    
    rxLpf = txrxLpfRC;
    rxLpfDelay = rxLpf.order / 2;
    
    figure();    
    
    
    
    curDataBlk = signal
    curDataBlk = freqDownConversion(curDataBlk, Fc, Fs);
    lpfCurDataBlk = curDataBlk;
%         lpfCurDataBlk = [curDataBlk; zeros(rxLpfDelay,1)];
%         lpfCurDataBlk = filter(rxLpf, lpfCurDataBlk);
%         lpfCurDataBlk = lpfCurDataBlk(rxLpfDelay+1:end);

    fftData = fft(lpfCurDataBlk);
    roiData = [fftData(end - roiBitLength/2+1:end); fftData(1:roiBitLength/2)]

    % Channel Estimation
    LsEst = zeros(pilotLen,1);
    length(roiData);
    k = 1:pilotLen;
    LsEst(k) = roiData(pilotLocation(k)) ./ pilotSig(k);


    H = interpolate(LsEst, pilotLocation, length(roiData), 'linear');

    chanEstData = roiData .* H';
%         chanEstData = roiData;
    chanEstData(pilotLocation) = [];
    dataBlk = chanEstData

    %%%%% QAM demodulation %%%%%
%         demodBlk = qamdemod(dataBlk,4);
%         demodBlk = de2bi(demodBlk);
%         demodBlk = demodBlk(:,end:-1:1);

    demodBlk = pskdemod(dataBlk,2);
    binDemodBlk = reshape(demodBlk',[],1);

    %%%%% DeInterleaver %%%%%%
    deIntBlk = matdeintrlv(binDemodBlk,intRows,intCols);

    %%%%% Viterbi Decoding %%%%%
    decodedBlk = vitdec(deIntBlk, trel, tbLen, 'trunc', 'hard');
    analyzedMat(:,blkIdx) = decodedBlk;

    %%%%%%%%%%%%% PLOT %%%%%%%%%%%%%                
    subplot(noBlksPerSig,6,blkIdx*6-5);
    plot(signal);
    subplot(noBlksPerSig,6,blkIdx*6-4);
    plot(real(lpfCurDataBlk)); hold on;
    plot(imag(lpfCurDataBlk),'g');
    subplot(noBlksPerSig,6,blkIdx*6-3);
    stem(real(fftData)); hold on;
    stem(imag(fftData),'g');
    subplot(noBlksPerSig,6,blkIdx*6-2);
    stem(real(roiData)); hold on;
    stem(imag(roiData),'g');
    plot(real(H),'r'); 
    plot(imag(H),'y'); hold off;

    subplot(noBlksPerSig,6,blkIdx*6-1);
    stem(real(chanEstData)); hold on;
    stem(imag(chanEstData),'g');
    subplot(noBlksPerSig,6,blkIdx*6);
    scatter(real(roiData),imag(roiData),'*'); hold on;
    scatter(real(chanEstData),imag(chanEstData),'*','r');        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%         subplot(1,1,1);
%         plot(signal(pos + 1: endPos));
%         cnt = cnt+1;
%         if(cnt == 3)
%             rd = signal(pos+1:endPos);
%             save('SonyThird', 'rd');
end