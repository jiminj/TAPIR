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

    
    
    %%%%% Detect Block (Double Sliding Window / Autocorrelation) %%%%
    
    % Packet Detector (Double Sliding Window)
    windowSize = 32;
%     receiverBufSize = 1024;
    minPower = 1.0e-03;
    powerRatioThresholdOn = 20;
%     powerRatioThresholdOff = 5;
        
    [dswResult, winPower] = packetDetect_dsw(bandSig, windowSize, minPower );

    maxVal = max(dswResult);
    maxWinPower = max(winPower);
   
%     
    
%     overThPoints = find(dswResult > powerRatioThresholdOn);
%     searchingSetStPoint = 1;
%     searchingSetEndPoint = 1;


    startBlockIndex = 1;
   
    thOverPoint = find(dswResult > powerRatioThresholdOn,1);
    startBlockIndex = thOverPoint;

    endBlockIndex = 0;
    
    dataSignal = [];
    remainedBlk = [];
   
%     for idx=2:length(overThPoints)
%         if( overThPoints(idx) - overThPoints(idx-1) == 1 && (idx ~= length(overThPoints)) ) 
%             searchingSetEndPoint = idx;        
%         else
%             %Search the max value and index of continuing overthreshold values
%             [maxVal, maxIndex] = max( dswResult(overThPoints(searchingSetStPoint):overThPoints(searchingSetEndPoint)) );
%             startBlockIndex = maxIndex + overThPoints(searchingSetStPoint) - 1;
% 
%             % The end of signal
%             endBlockIndex = find(winPower(startBlockIndex:end) < minPower, 1) + startBlockIndex - 1;
%             if(length(endBlockIndex) == 0) %What if there's no sample under the minPower
%                 endBlockIndex = length(bandSig);
%                 flagCont = 1;
%             else
%                 flagCont = 0;
%             end
% 
%             % continuing
%             dataSignal = bandSig(startBlockIndex:endBlockIndex);
%             break;
%             if(idx ~= length(overThPoints))
%                 searchingSetStPoint = idx;
%             end
%         end
%     end

   
    % The end of signal
    endBlockIndex = find(winPower(startBlockIndex+1:end) < minPower, 1) + startBlockIndex - 1;
    if( length(endBlockIndex) == 0 ) % is Continue
        endBlockIndex = length(bandSig);
    end
    
    dataSignal = bandSig(startBlockIndex:endBlockIndex);
    remainedBlk = bandSig(endBlockIndex+1:end);

%     % continuing
%     if(startBlockIndex < 10)
%         startBlockIndex = 1;
%     end
    

            
    
    
    %         endPoint = find(revDsw(overThPoints(idx):end))
%     startingPoint = find(dswResult > powerRatioThresholdOn, 1);
%     endPoint = find(revDsw(overThPoints(idx):end) > powerRatioThresholdOff, 1) + startingPoint - 1;
    
    if (isempty(startBlockIndex))
        startBlockIndex = 0;
    end
   
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

