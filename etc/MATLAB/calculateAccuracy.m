function [resultAccuracyRatio, receivedAccuracyRatio, resultFrameAccuracyRatio, receivedFrameAccuracyRatio] = calculateAccuracy( originalString, receivedData, Fc )

noSubjects = size(receivedData, 2);
noSymbols = size(originalString,2);
TapirConf;

lenOriginalData = noDataFrame * modulationRate;
lenEncodedData = lenOriginalData * encodingRate;

%%%%make original data %%%%

originalDataBits = dec2bin(originalString, 8)' - 48;
encodedDataBits = zeros(lenEncodedData , size(originalDataBits,2));

numBlocks = size(originalDataBits, 2);
for idx = 1:numBlocks
    block = originalDataBits(:,idx);

    %%%%% Convolutional encoding %%%%%
    block = convenc(block, trel);
    %     blockSize = length(block);
    %     block(block == 0) = -1; % To reduce the dynamic range of output signal.
    convEncBlk = block;

    encodedDataBits(:,idx) = block;
    %%%%% Interleaver %%%%% 
    block = matintrlv(convEncBlk, intRows, intCols);
    interleavedBlk = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%% QAM modulation %%%%%
    block = real(pskmod(block,2));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%



noTotSymbols = noSymbols * noSubjects;
noCorrectEncodedSymbols = 0;
noCorrectResultSymbols = 0;

noCorrectEncodedFrames = 0;
noCorrectResultFrames = 0;
% 
% noEncodedBits = lenEncodedData * noSubjects * noSymbols ;
% noResultBits = lenOriginalData * noSubjects * noSymbols ;
% noCorrectEncodedBits = 0;
% noCorrectResultBits = 0;

%%% analysis
for idx = 1:noSubjects

    signal = receivedData(:,idx);
    
    receivedMat = zeros(lenEncodedData , noBlksPerSig);
    decodedMat = zeros(lenOriginalData, noBlksPerSig);
    
    sigLength = length(signal);
    pilotLen = length(pilotSig);
    roiBitLength = noDataCarrier + pilotLen;
    pilotInterval = floor(noDataCarrier / (pilotLen+1));
    
    pilotLocation = [];
    for idx = 1:pilotLen
        pilotLocation = [pilotLocation; (idx * pilotInterval + idx)];
    end
    
    blkIdx = 1;
    pos = preambleInterval + cPreLength;
    
    rxLpf = txrxLpfRC;
    rxLpfDelay = rxLpf.order / 2;
 
    
    cnt = 0;
    while pos < sigLength
        endPos = pos + symLength;
        curDataBlk = signal(pos + 1: endPos);
       
        curDataBlk = freqDownConversion(curDataBlk, Fc, Fs);

        lpfCurDataBlk = curDataBlk;
%         lpfCurDataBlk = [curDataBlk; zeros(rxLpfDelay,1)];
%         lpfCurDataBlk = filter(rxLpf, lpfCurDataBlk);
%         lpfCurDataBlk = lpfCurDataBlk(rxLpfDelay+1:end);
        
        fftData = fft(lpfCurDataBlk);
        roiData = [fftData(end - roiBitLength/2+1:end); fftData(1:roiBitLength/2)];
        
        % Channel Estimation
        LsEst = zeros(pilotLen,1);
        length(roiData);
        k = 1:pilotLen;
        LsEst(k) = roiData(pilotLocation(k)) ./ pilotSig(k);
        
        H = interpolate(LsEst, pilotLocation, length(roiData), 'linear');
        
        chanEstData = roiData .* H';
        chanEstData(pilotLocation) = [];
        dataBlk = chanEstData;
        
        demodBlk = pskdemod(dataBlk,2);
        binDemodBlk = reshape(demodBlk',[],1);
  
        %%%%% DeInterleaver %%%%%%
        deIntBlk = matdeintrlv(binDemodBlk,intRows,intCols);
        receivedMat(:, blkIdx) = deIntBlk;
        
        %%%%% Viterbi Decoding %%%%%
        decodedBlk = vitdec(deIntBlk, trel, tbLen, 'trunc', 'hard');
        decodedMat(:,blkIdx) = decodedBlk;

        blkIdx = blkIdx + 1;
        pos = endPos + guardInterval + cPreLength + cPostLength;
    end
    
    %%%% comparement %%%
    
    hitEncodedSymbols = 0;
    hitResultSymbols = 0;
    
    for nosym = 1:noSymbols
        origSym = originalDataBits(:, nosym);
        if(size(origSym(origSym == decodedMat(:, nosym)), 1) == lenOriginalData)
            hitResultSymbols = hitResultSymbols + 1;
%             noCorrectResultSymbols = noCorrectResultSymbols + 1;
        end
        
        encodedSym = encodedDataBits(:, nosym);
        if(size(encodedSym(encodedSym == receivedMat(:, nosym)), 1) == lenEncodedData )            
            hitEncodedSymbols = hitEncodedSymbols + 1;
%             noCorrectEncodedSymbols = noCorrectEncodedSymbols + 1;
        end
    end

    noCorrectResultSymbols = noCorrectResultSymbols + hitResultSymbols;
    noCorrectEncodedSymbols = noCorrectEncodedSymbols + hitEncodedSymbols;
    
    if(hitResultSymbols == noSymbols)
        noCorrectResultFrames = noCorrectResultFrames + 1;
    end
    
    if(hitEncodedSymbols == noSymbols)
        noCorrectEncodedFrames = noCorrectEncodedFrames + 1;
    end
    
%     origSingleLine = reshape(originalDataBits,[],1);
%     decodedSingleLine = reshape(decodedMat,[],1);
%     decodedSingleLine = decodedSingleLine(1:size(origSingleLine,1));
%     
% %     numResultBits = numResultBits + size(origSingleLine,1); 
%     noCorrectResultBits = noCorrectResultBits + size(origSingleLine( origSingleLine == decodedSingleLine),1);
%     
%     encodedSingleLine = reshape(encodedDataBits,[],1);
%     receivedSingleLine = reshape(receivedMat,[],1);
%     receivedSingleLine = receivedSingleLine(1:size(encodedSingleLine,1));
%     
% %     numEncodedBits = numEncodedBits + size(encodedSingleLine,1);
%     noCorrectEncodedBits = noCorrectEncodedBits + size(encodedSingleLine( encodedSingleLine == receivedSingleLine),1);
%     
end
% noTotSymbols
% noSubjects
% noCorrectEncodedFrames
% noCorrectResultFrames
% 
receivedFrameAccuracyRatio = noCorrectEncodedFrames / noSubjects;
resultFrameAccuracyRatio = noCorrectResultFrames / noSubjects;

receivedAccuracyRatio = noCorrectEncodedSymbols / noTotSymbols;
resultAccuracyRatio = noCorrectResultSymbols / noTotSymbols; 


end

