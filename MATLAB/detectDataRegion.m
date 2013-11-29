function [ dataSignal, remainedBlk] = detectDataRegion( signal, Fc)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    TapirConf;
    
%     switch Fc
%         case 10000
%             rxBpf = rxBpf10k;
%         case 18000
%             rxBpf = rxBpf18k;
%         case 20000
%             rxBpf = rxBpf20k;
%     end
%     
%     
	rxFilter = txrxHpf;
%     minBlkSize = 1280;

    %%%%%% Apply BPF first! (to prevent unwanted noise) %%%%%%%%%%%
    filtDelay = ceil(rxFilter.order / 2);
    extSignal = [signal; zeros(filtDelay,1)];
    bandSig = filter(rxFilter, extSignal);
    bandSig = bandSig(filtDelay+1 : end);

%     bandSig = signal;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    preambleLen = Fs * preambleBitLength / preambleBandwidth;
    corrResult = zeros(length(bandSig),1);
    blockLen = symLength + guardInterval + cPreLength + cPostLength;
    
    findFlag = 0;
    searchMaxStPoint = 0;
    corrThreshold = 2;
   
    for idx=2*preambleLen+1:length(bandSig)       
        denom = 0;
        for k = 0:(preambleLen - 1)
            corrResult(idx) = corrResult(idx) + bandSig(idx - k) * bandSig(idx - k - preambleLen);
            denom = denom + abs(bandSig(idx-k));
        end
        corrResult(idx) = corrResult(idx) / (denom / preambleLen);
        
        if(abs(corrResult(idx)) > corrThreshold) && (findFlag ~= 1)
            findFlag = 1;
            searchMaxStPoint = idx;
        end
    end;

    
    [~, peakPoint] = max(abs(corrResult(searchMaxStPoint : searchMaxStPoint+preambleLen)));
    peakPoint = peakPoint + searchMaxStPoint - 1;
    
    
    length(bandSig)
    peakPoint + blockLen * noBlksPerSig + preambleInterval
    dataSignal = bandSig(peakPoint+1:peakPoint + blockLen * noBlksPerSig + preambleInterval);
    
    figure();
    subplot(4,1,1);
    plot(signal); 
    
    subplot(4,1,2);
    plot(bandSig(1:peakPoint)); hold on;
    plot( peakPoint+1:peakPoint + length(dataSignal), dataSignal,'r');
    plot( peakPoint+length(dataSignal)+1:length(bandSig), bandSig(peakPoint+length(dataSignal)+1:end ));
    subplot(4,1,3);
    plot(abs(corrResult));

    subplot(4,1,4);
    plot(dataSignal);
    
%     %%%% Detect Block (Double Sliding Window) %%%%
%     
%     % Packet Detector (Double Sliding Window)
%     windowSize = 32;
%     minPower = 1.0e-03;
%     powerRatioThresholdOn = 20;
%     [dswResult, winPower] = packetDetect_dsw(bandSig, windowSize, minPower );
% 
%     startBlockIndex = 1;
%    
%     thOverPoint = find(dswResult > powerRatioThresholdOn,1);
%     startBlockIndex = thOverPoint;
% 
%     endBlockIndex = 0;
%     
%     dataSignal = [];
%     remainedBlk = [];
%    
%     % The end of signal
%     endBlockIndex = find(winPower(startBlockIndex+1:end) < minPower, 1) + startBlockIndex - 1;
%     if( length(endBlockIndex) == 0 ) % is Continue
%         endBlockIndex = length(bandSig);
%     end
%     
%     dataSignal = bandSig(startBlockIndex:endBlockIndex);
%     remainedBlk = bandSig(endBlockIndex+1:end);
% 
%     if (isempty(startBlockIndex))
%         startBlockIndex = 0;
%     end
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     
% %     %%%%% Detect Block (Autocorrelation) %%%%
% %     TapirConf;
% %     corResult = packetDetect_autocorr(bandSig, symLength, cpLength);
% %     corResult = corResult / 10000;
% %     corResult = corResult(cpLength*2+1:end);
% %     
% %     figure();
% %     plot(bandSig); hold on;
% %     plot(corResult,'r'); hold off;
% %     
% %     dataSignal = [];
% %     remainedBlk = [];
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     
%    
% %     % autoCorrResult = packetDetect_autocorr(block, symLength, lenPrefix);
% % 
% % 
% %     if( (startBlockIndex ~= 0) && (endBlockIndex - startBlockIndex > 500))
% %         %     % Plot
% %         figure;
% %         subplot(2,1,1);
% % %         plot(bandSig * abs(max(dswResult))); 
% %         plot(bandSig * abs(max(dswResult))); hold on;
% %         stem(dswResult,'r'); 
% %         plot(winPower * abs(max(dswResult)) ,'g'); hold off;
% % %         hold off;
% %         subplot(2,1,2);
% %         plot(dataSignal);
% % %         startBlockIndex
% % %         endBlockIndex
% %         length(dataSignal)
% %     end
% %  
% % % 
% 

    
end

