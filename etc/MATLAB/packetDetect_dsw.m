% function [dsw, revDsw] = packetDetect_dsw( vec, windowSize, minPower)
function [dsw, windowedBlkPower] = packetDetect_dsw( vec, windowSize, minPower)

    if (nargin < 3)
        minPower = 0;
    end

    windowedBlk = buffer(vec, windowSize, windowSize-1);
    windowedBlkPower = sum(abs(windowedBlk).^2);

    delayedWindowedBlkPower= [zeros(1,windowSize), windowedBlkPower];
    windowedBlkPower = [windowedBlkPower, zeros(1,windowSize)];
    
    dsw = windowedBlkPower ./ delayedWindowedBlkPower;
%     revDsw = 1 ./dsw;

    dsw(isnan(dsw)) = 0;
    dsw(isinf(dsw)) = 1000;
    dsw(windowedBlkPower < minPower) = 0;
    dsw = dsw(1 :end - windowSize);
    
    windowedBlkPower = windowedBlkPower(1:end-windowSize);
    
    
    
%     revDsw(delayedWindowedBlkPower < minPower) = 0;
%     revDsw(isnan(revDsw)) = 0;
%     revDsw(isinf(revDsw)) = 1000;
% 
%     revDsw = revDsw(1: end - windowSize);
    
    
    
end

