function [ resultMat ] = analyzeAudioData( signal )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    TapirConf;
% 
    lenEachSym = symLength;
    thSymLength = 0.8 * lenEachSym;
    redunLen = mod(length(signal),lenEachSym);
    if(mod(redunLen,lenEachSym) > thSymLength)
        fittedSig = [signal(1:end); zeros(lenEachSym - redunLen,1)];
    else
        fittedSig = signal(1:end-redunLen);
    end    

    
    blockedSig = reshape(fittedSig,lenEachSym,[]);
    noIt = size(blockedSig,2);

    resultMat = zeros(noDataFrame, noIt);

    for idx=1:noIt
        
        block = blockedSig(:,idx);
        rcvBlock = block;
%         block = wholeBlock(lenPrefix+1:end);
        
        block = intdump(rcvBlock(1:symLength), Fs * Ts);
        dumpedBlk = block;
        %%%%%%% FFT %%%%%%%%%%
        block = fft(block);
        dataBlk = [block((1:noDataCarrier/2)); block(end - noDataCarrier/2 +1 : end)];
        rcvDataBlk = dataBlk;
        remainedBlk = block(noDataCarrier/2+1: end - noDataCarrier/2);
%         %%%%%%%%% DCT %%%%%%%%%%
%         block = dct(block);
%         dataBlk = block(1:noDataCarrier);
%         
        transformedBlk = block;
        
%         pilotResult = dataBlk(pilotPos);
%         dataBlk(pilotPos) = [];
%         dcResult = dataBlk( noDataCarrier/2 + 1);
%         dataBlk(noDataCarrier/2 + 1 ) = [];


        %%%%% DBPSK demodulation %%%%%
        dataBlk(dataBlk == 0) = -1;
        dataBlk = real(dpskdemod(dataBlk,2));

%         demodBlk = block;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        
        % Phase Recovery
        h = fft(remainedBlk,64);
        
        
%         dataBlk = dataBlk * sign(dataBlk(1));
%         anglePilot = angle(pilot * pilotResult);
%         dataBlk = dataBlk * exp(1i*anglePilot)';
%         
% 
%         subplot(noIt,4,idx*4); stem(real(dataBlk) ); hold on; stem(imag(dataBlk),'g'); hold off;
%         dataBlk = real(dataBlk);
        
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

        figure();
        subplot(3,3,1);
        plot(real(signal)); hold on; plot(imag(signal),'g');hold off;
        subplot(3,3,2); 
        plot(real(rcvBlock)); hold on; plot(imag(rcvBlock),'g'); hold off;
        subplot(3,3,3); 
        plot(real(dumpedBlk)); hold on; plot(imag(dumpedBlk),'g'); hold off;
        subplot(3,3,4); stem(real(transformedBlk)); hold on; stem(imag(transformedBlk),'g'); hold off;
        subplot(3,3,5); stem(real(remainedBlk)); hold on; stem(imag(remainedBlk),'g'); hold off;
        subplot(3,3,6); stem(real(rcvDataBlk)); hold on; stem(imag(rcvDataBlk),'g'); hold off;
        subplot(3,3,7); stem(real(h)); hold on; stem(imag(h),'g'); hold off;
        subplot(3,3,8); scatter(real(transformedBlk),imag(transformedBlk)); grid on; hold on; scatter(real(rcvDataBlk),imag(rcvDataBlk),'r');
        subplot(3,3,9); pwelch(rcvBlock,[],[],[],Fs, 'centered');
%         subplot(noIt,5,idx*5); stem(transformedBlk(end - noDataCarrier/2 - 20 + 1:end - noDataCarrier/2));
        
        resultMat(:,idx) = block;

    end
end

