function result = packetDetect_autocorr(vec, lagLength, corLength)

    windowedBlk = buffer(vec, corLength, corLength-1);
    delayedWindowedBlk = [zeros(corLength, lagLength), windowedBlk];
    windowedBlk = [windowedBlk, zeros(corLength, lagLength)];

    corrResult = zeros(1,length(windowedBlk));
    for idx=1:length(windowedBlk)-lagLength
        corrResult(1,idx) = sum(abs(xcorr(windowedBlk(:,idx), delayedWindowedBlk(:,idx))));
    end
    
    
    dWinPower = sum(abs(delayedWindowedBlk).^2);
    result = corrResult ./ dWinPower;

end

