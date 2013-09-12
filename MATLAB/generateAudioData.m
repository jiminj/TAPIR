function result = generateAudioData( binData )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

TapirConf;

% seperates msg to frames by framesize
blockedMsg = reshape(binData, noDataFrame,[]);
numBlocks = size(blockedMsg, 2);

% result = zeros((Fs*Ts*noTotCarrier + cpLength), numBlocks);
result = zeros((symLength+cpLength), numBlocks);

% figure(1);

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
    
    %%%%% Add Pilot %%%%%    
    blockLen = length(block);

    block = [ pilotSig(1); block(1:blockLen/4); pilotSig(2); block(blockLen/4+1 : 2*blockLen/4); block(2*blockLen/4 + 1 : 3 * blockLen/4); pilotSig(3); block(3*blockLen/4 + 1 : end); pilotSig(4);];
    blkWithPilot = block;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    %%%%% Add Zero Subcarriers %%%%%
    
    
    %%%%% IDFT %%%%% 
    block =[block(1:length(block)/2); zeros(symLength - length(block), 1); block(end - length(block)/2 + 1:end)];
    block = noDataCarrier .* ifft(block);
    transformedBlk = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%% IDCT %%%%%
%     block = [block; zeros(noTotCarrier - noDataCarrier,1)];
%     block = noDataCarrier .* idct(block);
%     transformedBlk = block;

%     %%%%% Extend block by pulse shaping and applying LPF %%%%%
%     block = rectpulse(block, Fs * Ts);
%     extBlock = block;
    
	%%%%% Add Cyclic Prefix %%%%%%%
    
    block = [block(end-cpLength+1:end); block];
    cpAddedBlk = block;
    
%     lpf = txrxLpf;
%     lpfDelay = lpf.order / 2
%     lpfExtBlock = [block; zeros(lpfDelay, 1)];
%     lpfExtBlock = filter(lpf, lpfExtBlock);
%     block = lpfExtBlock(lpfDelay+1 : end);
    lpfExtBlock = block;

%     
%     subplot(numBlocks,5, idx*5-4 );
%     stem(modBlk);
%     subplot(numBlocks,5, idx*5-3 );
%     stem(blkWithPilot );
%     subplot(numBlocks,5, idx*5-2);
%     plot(real(transformedBlk)); hold on; plot(imag(transformedBlk),'g'); hold off;
%     subplot(numBlocks,5, idx*5-1);
%     plot(real(cpAddedBlk)); hold on; plot(imag(cpAddedBlk),'g'); hold off;
%     subplot(numBlocks,5, idx*5);
%     plot(real(block)); hold on; plot(imag(block),'g'); hold off;

    lengthBlock = length(block)
    %     extendedBlk = block;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%% Add Preamble %%%%%
    
%     block = [ repmat(shortPreamble, noPreambleRepeat, 1); block];
%     preambledBlock = block;

%     startIdx = (idx-1) * (txBlockLength) + 1;

    result(:, idx) = block; 
end



end

