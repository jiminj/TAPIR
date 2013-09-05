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
        

        % %%%%%%% DCT %%%%%%%%%%
        block = dct(block);
        dctBlk = block;

        %%%%% Sort Result %%%%%
        %FFT
        % dataBlk = [block(symLength/2 - noCarrier/2 + 1:symLength/2); block(symLength/2 + 2 : symLength/2 + 2 + noCarrier/2 - 1)];
%         noTotalBlk = noDataCarrier + noPilotCarrier;
%         dataBlk = block(symLength/2 - noTotalBlk/2 + 1: symLength/2 + noTotalBlk/2 + 1);
        
        dataBlk = block(1:noDataCarrier);

        figure();
        subplot(noIt,4,idx*4 - 3);
        plot(signal);
        subplot(noIt,4,idx*4 - 2); 
        plot(rcvBlock);
        subplot(noIt,4,idx*4 - 1); stem(dctBlk);
        subplot(noIt,4,idx*4); stem(dataBlk);
        
        
%         pilotResult = dataBlk(pilotPos);
%         dataBlk(pilotPos) = [];
%         dcResult = dataBlk( noDataCarrier/2 + 1);
%         dataBlk(noDataCarrier/2 + 1 ) = [];

        
        % Phase Recovery
        
        dataBlk = dataBlk * sign(dataBlk(1));
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

        %%%%% DBPSK demodulation %%%%%
        block(block == 0) = -1;
        block = real(dpskdemod(block,2));

%         demodBlk = block;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        resultMat(:,idx) = block;

    end
end

