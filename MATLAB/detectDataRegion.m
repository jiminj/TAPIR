function [ dataSignal, remainedBlk] = detectDataRegion( signal, Fc)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    
    switch Fc
        case 10000
            rxBpf = rxBpf10k;
        case 18000
            rxBpf = rxBpf18k;
        case 20000
            rxBpf = rxBpf20k;
    end
    
%     minBlkSize = 1280;

    %%%%%% Apply BPF first! (to prevent unwanted noise) %%%%%%%%%%%
    filtDelay = ceil(rxBpf.order / 2);
    extSignal = [signal; zeros(filtDelay,1)];
    bandSig = filter(rxBpf, extSignal);
    bandSig = bandSig(filtDelay+1 : end);

%     bandSig = signal;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    
    %%%% Detect Block (Double Sliding Window) %%%%
    
    % Packet Detector (Double Sliding Window)
    windowSize = 32;
    minPower = 1.0e-03;
    powerRatioThresholdOn = 20;
    [dswResult, winPower] = packetDetect_dsw(bandSig, windowSize, minPower );

    startBlockIndex = 1;
   
    thOverPoint = find(dswResult > powerRatioThresholdOn,1);
    startBlockIndex = thOverPoint;

    endBlockIndex = 0;
    
    dataSignal = [];
    remainedBlk = [];
   
    % The end of signal
    endBlockIndex = find(winPower(startBlockIndex+1:end) < minPower, 1) + startBlockIndex - 1;
    if( length(endBlockIndex) == 0 ) % is Continue
        endBlockIndex = length(bandSig);
    end
    
    dataSignal = bandSig(startBlockIndex:endBlockIndex);
    remainedBlk = bandSig(endBlockIndex+1:end);

    if (isempty(startBlockIndex))
        startBlockIndex = 0;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
%     %%%%% Detect Block (Autocorrelation) %%%%
%     TapirConf;
%     corResult = packetDetect_autocorr(bandSig, symLength, cpLength);
%     corResult = corResult / 10000;
%     corResult = corResult(cpLength*2+1:end);
%     
%     figure();
%     plot(bandSig); hold on;
%     plot(corResult,'r'); hold off;
%     
%     dataSignal = [];
%     remainedBlk = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
   
%     % autoCorrResult = packetDetect_autocorr(block, symLength, lenPrefix);
% 
% 
%     if( (startBlockIndex ~= 0) && (endBlockIndex - startBlockIndex > 500))
%         %     % Plot
%         figure;
%         subplot(2,1,1);
% %         plot(bandSig * abs(max(dswResult))); 
%         plot(bandSig * abs(max(dswResult))); hold on;
%         stem(dswResult,'r'); 
%         plot(winPower * abs(max(dswResult)) ,'g'); hold off;
% %         hold off;
%         subplot(2,1,2);
%         plot(dataSignal);
% %         startBlockIndex
% %         endBlockIndex
%         length(dataSignal)
%     end
%  
% % 


    
end

