function result = generateAudioData( binData )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

TapirConf;

% seperates msg to frames by framesize
blockedMsg = reshape(binData, noDataFrame,[]);
numBlocks = size(blockedMsg, 2);

% txSignal = zeros((symLength+lenPrefix) * numBlocks + guardInterval,1);
result = zeros((Fs*Ts*noTotCarrier + lenPrefix), numBlocks);

figure(1);

%for each block
for idx = 1:numBlocks

    block = blockedMsg(:,idx);

    
    %%%%% Convolutional encoding %%%%%
    block = convenc(block, trel);
%     blockSize = length(block);
%     block(block == 0) = -1; % To reduce the dynamic range of output signal.
    convEncBlk = block;
    
    %%%%% Interleaver %%%%% 
    block = matintrlv(convEncBlk, intRows, intCols);
    interleavedBlk = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
	%%%%% DBPSK modulation %%%%%
%     block(block == -1) = 0; % For Convolutional Encoding
    block = real(dpskmod(block,2));
    modBlk = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%% Add Pilot & DC %%%%%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    %%%%% Add Zero Subcarriers %%%%%
    
    
    %%%%% IDFT %%%%% 
    block =[block(1:length(block)/2); zeros(noTotCarrier - noDataCarrier, 1); block(end - length(block)/2 + 1:end)];
    block = noDataCarrier .* ifft(block);
    transformedBlk = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%% IDCT %%%%%
%     block = [block; zeros(noTotCarrier - noDataCarrier,1)];
%     block = noDataCarrier .* idct(block);
%     transformedBlk = block;


    %%%%% Extend block by pulse shaping and applying LPF %%%%%
    extBlock = rectpulse(block, Fs * Ts);
    lpf = txrxLpf;
    lpfDelay = ceil(lpf.order / 2);
    lpfExtBlock = [extBlock; zeros(lpfDelay, 1)];
    lpfExtBlock = filter(lpf, lpfExtBlock);
    block = lpfExtBlock(lpfDelay+1 : end);
    
	%%%%% Add Cyclic Prefix %%%%%%%
    
    block = [block(end-lenPrefix+1:end); block];
    cpAddedBlk = block;
    
    subplot(numBlocks,3, idx*3-2 );
    stem(modBlk);
    subplot(numBlocks,3, idx*3-1);
    plot(real(transformedBlk)); hold on; plot(imag(transformedBlk),'g'); hold off;
    subplot(numBlocks,3, idx*3);
    plot(real(cpAddedBlk)); hold on; plot(imag(cpAddedBlk),'g'); hold off;

    %     extendedBlk = block;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%% Add Preamble %%%%%
    
%     block = [ repmat(shortPreamble, noPreambleRepeat, 1); block];
%     preambledBlock = block;

%     startIdx = (idx-1) * (txBlockLength) + 1;

    result(:, idx) = block; 
end



end

