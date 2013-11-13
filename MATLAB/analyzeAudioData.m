function [ resultMat ] = analyzeAudioData( signal, Fc)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    TapirConf;
%   
    sigLength = length(signal);
    pilotLen = length(pilotSig);
    roiBitLength = noDataCarrier + pilotLen;
    pilotInterval = floor(noDataCarrier / (pilotLen+1));
    
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
    
    
    while pos < sigLength
        endPos = pos + symLength;
        curDataBlk = signal(pos + 1: endPos);
        curDataBlk = freqDownConversion(curDataBlk, Fc, Fs);
        
        lpfCurDataBlk = [curDataBlk; zeros(rxLpfDelay,1)];
        lpfCurDataBlk = filter(rxLpf, lpfCurDataBlk);
        lpfCurDataBlk = lpfCurDataBlk(rxLpfDelay+1:end);
        
        
        fftData = fft(lpfCurDataBlk);
        roiData = [fftData(end - roiBitLength/2+1:end); fftData(1:roiBitLength/2)];
        
        % Channel Estimation
        LsEst = zeros(pilotLen,1);
        
        k = 1:pilotLen;
        LsEst(k) = roiData(pilotLocation(k)) ./ pilotSig(k); 
        
%         LsEst(pilotLocation) = roiData(pilotLocation) ./ pilotSig;
        H = interpolate(LsEst, pilotLocation, length(roiData), 'linear');
        
        chanEstData = roiData .* H';

        chanEstData(pilotLocation) = [];
        dataBlk = chanEstData;
        
        %%%%% QAM demodulation %%%%%
        demodBlk = qamdemod(dataBlk,4);
        demodBlk = de2bi(demodBlk);
        demodBlk = demodBlk(:,end:-1:1);
        binDemodBlk = reshape(demodBlk',[],1);
  
        %%%%% DeInterleaver %%%%%%
        deIntBlk = matdeintrlv(binDemodBlk,intRows,intCols);

        %%%%% Viterbi Decoding %%%%%
        decodedBlk = vitdec(deIntBlk, trel, tbLen, 'trunc', 'hard');
        analyzedMat(:,blkIdx) = decodedBlk;

        %%%%%%%%%%%%% PLOT %%%%%%%%%%%%%                
        subplot(noBlksPerSig,6,blkIdx*6-5);
        plot(signal(pos + 1: endPos));
        subplot(noBlksPerSig,6,blkIdx*6-4);
        plot(real(lpfCurDataBlk)); hold on;
        plot(imag(lpfCurDataBlk),'g');
        subplot(noBlksPerSig,6,blkIdx*6-3);
        stem(real(fftData)); hold on;
        stem(imag(fftData),'g');
        subplot(noBlksPerSig,6,blkIdx*6-2);
        stem(real(roiData)); hold on;
        stem(imag(roiData),'g');
        subplot(noBlksPerSig,6,blkIdx*6-1);
        stem(real(chanEstData)); hold on;
        stem(imag(chanEstData),'g');
        plot(real(H),'r'); 
        plot(imag(H),'y'); hold off;
        subplot(noBlksPerSig,6,blkIdx*6);
        scatter(real(roiData),imag(roiData),'*'); hold on;
        scatter(real(chanEstData),imag(chanEstData),'*','r');        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        blkIdx = blkIdx + 1;
        pos = endPos + guardInterval + cPreLength + cPostLength;
        
    end

  


%         demodBlk = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    resultMat = analyzedMat;
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %     rcvDataLen = length(rcvDataBlk)
% %     pilotLen = length(pilotIndex)
%     
% %     figure();
% %     subplot(4,3,1);
% %     plot(real(signal)); hold on; plot(imag(signal),'g');hold off;
% %     subplot(4,3,2); 
% %     plot(real(rcvBlock)); hold on; plot(imag(rcvBlock),'g'); hold off;
% %     subplot(4,3,3); 
% % %     plot(real(dumpedBlk)); hold on; plot(imag(dumpedBlk),'g'); hold off;
% %     subplot(4,3,4); stem(real(transformedBlk)); hold on; stem(imag(transformedBlk),'g'); hold off;
% %     subplot(4,3,5); stem(real(phRecBlock)); hold on; stem(imag(phRecBlock),'g'); hold off;
% %     %     subplot(4,3,5); stem(real(remainedBlk)); hold on; stem(imag(remainedBlk),'g'); hold off;
% %     subplot(4,3,6); stem(real(rcvDataBlk)); hold on; stem(imag(rcvDataBlk),'g'); hold off;
% %     subplot(4,3,7); 
% %     scatter(real(transformedBlk),imag(transformedBlk)); grid on; hold on; 
% %     scatter(real(transformedBlk(1:(length(rcvDataBlk)+length(pilotIndex))/2)), imag(transformedBlk(1:(length(rcvDataBlk)+length(pilotIndex))/2)),'r');
% %     scatter(real(transformedBlk((length(rcvDataBlk)+length(pilotIndex))/2+1 : end )), imag(transformedBlk((length(rcvDataBlk)+length(pilotIndex))/2+1 : end )),'g');  hold off;
% %     noDisp = num2str((1:length(transformedBlk))', '%d');
% %     text(real(transformedBlk),imag(transformedBlk), noDisp, 'horizontal','left', 'vertical','bottom');
% %     hold off;
% %     subplot(4,3,8); 
% %     scatter(real(phRecBlock),imag(phRecBlock)); grid on; 
% % 
% %     
% %     subplot(4,3,9); pwelch(rcvBlock,[],[],[],Fs, 'centered');
% %     
%     
% %         subplot(4,3,10); 
% 
% %         stem(real(h)); hold on; stem(imag(h),'g'); hold off;
% %         stem(real(eqTransformedBlk)); hold on; stem(imag(eqTransformedBlk),'g'); hold off;
% %         subplot(4,3,11); 
% %         scatter(real(eqTransformedBlk),imag(eqTransformedBlk)); grid on; hold on; 
% %         scatter(real(eqDataBlk(1:length(eqDataBlk)/2)), imag(eqDataBlk(1:length(eqDataBlk)/2)),'r');
% %         scatter(real(eqDataBlk(length(eqDataBlk)/2+1 : end )), imag(eqDataBlk(length(eqDataBlk)/2+1 : end )),'g'); hold off;
% %         subplot(4,3,12);
% %         pwelch(h,[],[],[],64,'center');
% %         subplot(noIt,5,idx*5); stem(transformedBlk(end - noDataCarrier/2 - 20 + 1:end - noDataCarrier/2));
% 
%     resultMat = block;

end

