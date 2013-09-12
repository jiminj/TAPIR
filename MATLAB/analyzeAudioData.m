function [ resultMat ] = analyzeAudioData( signal )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    TapirConf;
% 
    

    sigLength = length(signal)
    %%% ZP-OFDM %%%
    
    block = [];
    resultMat = [];
    
    if(length(signal) > symLength + cpLength)
        block = signal(cpLength+1:cpLength+symLength);
    elseif( length(signal) > symLength)
        block = signal(length(signal) - symLength + 1 : end);
    else
        return;
    end
    
%     lenEachSym = symLength + cpLength;
%     thSymLength = symLength;
%     redunLen = mod(length(signal),lenEachSym);
%     if(mod(redunLen,lenEachSym) > thSymLength)
%         fittedSig = [signal(1:end); zeros(lenEachSym - redunLen,1)];
%     else
%         fittedSig = signal;
%     end    

%     blockedSig = reshape(fittedSig,lenEachSym,[]);
%     noIt = size(blockedSig,2);
%   block = blockedSig(:,idx);


    rcvBlock = block;
%     block = intdump(rcvBlock(1:symLength), Fs * Ts);
    %%%%%%% FFT %%%%%%%%%%
    block = fft(block);
%     dataBlk = [block((1:noDataCarrier/2)); block(end - noDataCarrier/2 +1 : end)];
%     rcvDataBlk = dataBlk;
%     remainedBlk = block(noDataCarrier/2+1: end - noDataCarrier/2);

    %%%%%%%%% DCT %%%%%%%%%%
%         block = real(block);
%         block = dct(block);
%         dataBlk = block(1:noDataCarrier);
%         rcvDataBlk = dataBlk;
%         remainedBlk = block(noDataCarrier+1 : end);

%         
    transformedBlk = block;

%         pilotResult = dataBlk(pilotPos);
%         dataBlk(pilotPos) = [];
%         dcResult = dataBlk( noDataCarrier/2 + 1);
%         dataBlk(noDataCarrier/2 + 1 ) = [];

    % Phase Recovery
    
    pilotIndex = [1,6,length(block)-5,length(block)];
    phRecBlock = block;
%     lenBlock = length(phRecBlock)

%     figure();
%     subplot(length(pilotIndex)+1,1,1);
%     stem(real(phRecBlock)); hold on; stem(imag(phRecBlock),'g'); hold off;
    for idx=1:length(pilotIndex)/2;
        ang = angle(phRecBlock(pilotIndex(idx)));
        phRecBlock(pilotIndex(idx):length(phRecBlock)/2) = phRecBlock(pilotIndex(idx):length(phRecBlock)/2) * exp(-1i*ang);
%         subplot(length(pilotIndex)+1,1, idx+1);
%         stem(real(phRecBlock)); hold on; stem(imag(phRecBlock),'g'); hold off;
    end
    for idx=length(pilotIndex):-1:length(pilotIndex)/2+1
        ang = angle(phRecBlock(pilotIndex(idx)));
        
        phRecBlock(length(phRecBlock)/2 + 1 : pilotIndex(idx)) = phRecBlock(length(phRecBlock)/2 + 1 : pilotIndex(idx)) * exp(-1i*ang);
        
%         subplot(length(pilotIndex)+1,1, idx+1);
%         stem(real(phRecBlock)); hold on; stem(imag(phRecBlock),'g'); hold off;
    end
    
    block = phRecBlock;
    block(pilotIndex) = [];
    dataBlk = [block((1:noDataCarrier/2)); block(end - noDataCarrier/2 +1 : end)];
    rcvDataBlk = dataBlk;
    remainedBlk = block(noDataCarrier/2+1: end - noDataCarrier/2);
    


    %%%%% DBPSK demodulation %%%%%
    dataBlk(dataBlk == 0) = -1;
    dataBlk = real(dpskdemod(dataBlk,2));

%         demodBlk = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%% DeInterleaver %%%%%%
    deIntBlk = matdeintrlv(dataBlk,intRows,intCols);

    deIntBlk(deIntBlk>0) = 1;
    deIntBlk(deIntBlk<0) = 0;
    deIntBlk = [deIntBlk; zeros(length(deIntBlk),1)];

    %%%%% Viterbi Decoding %%%%%

    % block = [block; zeros(64,1)];
    block = vitdec(deIntBlk, trel, tbLen, 'trunc', 'hard');

    block = block(1:length(deIntBlk)/4);

%         decodedBlk = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %     rcvDataLen = length(rcvDataBlk)
% %     pilotLen = length(pilotIndex)
%     figure();
%     subplot(4,3,1);
%     plot(real(signal)); hold on; plot(imag(signal),'g');hold off;
%     subplot(4,3,2); 
%     plot(real(rcvBlock)); hold on; plot(imag(rcvBlock),'g'); hold off;
%     subplot(4,3,3); 
% %     plot(real(dumpedBlk)); hold on; plot(imag(dumpedBlk),'g'); hold off;
%     subplot(4,3,4); stem(real(transformedBlk)); hold on; stem(imag(transformedBlk),'g'); hold off;
%     subplot(4,3,5); stem(real(phRecBlock)); hold on; stem(imag(phRecBlock),'g'); hold off;
%     %     subplot(4,3,5); stem(real(remainedBlk)); hold on; stem(imag(remainedBlk),'g'); hold off;
%     subplot(4,3,6); stem(real(rcvDataBlk)); hold on; stem(imag(rcvDataBlk),'g'); hold off;
%     subplot(4,3,7); 
%     scatter(real(transformedBlk),imag(transformedBlk)); grid on; hold on; 
%     scatter(real(transformedBlk(1:(length(rcvDataBlk)+length(pilotIndex))/2)), imag(transformedBlk(1:(length(rcvDataBlk)+length(pilotIndex))/2)),'r');
%     scatter(real(transformedBlk((length(rcvDataBlk)+length(pilotIndex))/2+1 : end )), imag(transformedBlk((length(rcvDataBlk)+length(pilotIndex))/2+1 : end )),'g');  hold off;
%     noDisp = num2str((1:length(transformedBlk))', '%d');
%     text(real(transformedBlk),imag(transformedBlk), noDisp, 'horizontal','left', 'vertical','bottom');
%     hold off;
%     subplot(4,3,8); 
%     scatter(real(phRecBlock),imag(phRecBlock)); grid on; 
% 
%     
%     subplot(4,3,9); pwelch(rcvBlock,[],[],[],Fs, 'centered');
%         subplot(4,3,10); 

%         stem(real(h)); hold on; stem(imag(h),'g'); hold off;
%         stem(real(eqTransformedBlk)); hold on; stem(imag(eqTransformedBlk),'g'); hold off;
%         subplot(4,3,11); 
%         scatter(real(eqTransformedBlk),imag(eqTransformedBlk)); grid on; hold on; 
%         scatter(real(eqDataBlk(1:length(eqDataBlk)/2)), imag(eqDataBlk(1:length(eqDataBlk)/2)),'r');
%         scatter(real(eqDataBlk(length(eqDataBlk)/2+1 : end )), imag(eqDataBlk(length(eqDataBlk)/2+1 : end )),'g'); hold off;
%         subplot(4,3,12);
%         pwelch(h,[],[],[],64,'center');
%         subplot(noIt,5,idx*5); stem(transformedBlk(end - noDataCarrier/2 - 20 + 1:end - noDataCarrier/2));

    resultMat = block;

end

