function result = generateAudioData( binData )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

TapirConf;

% seperates msg to frames by framesize
addCols = mod(size(binData,2), modulationRate);
blockedMsg = [binData, zeros(size(binData,1),addCols)];
blockedMsg = reshape(blockedMsg, noDataFrame * modulationRate,[]);
numBlocks = size(blockedMsg, 2);

% result = zeros((Fs*Ts*noTotCarrier + cpLength), numBlocks);
result = zeros((symLength), numBlocks);



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
        
	%%%%% QAM modulation %%%%%
     
    bunchedBlk = zeros(length(block)/modulationRate,1);
    k = 1:length(bunchedBlk);
    for m = 0: modulationRate-1
        bunchedBlk(k) = bunchedBlk(k) + block(k*modulationRate-m)*(2^m);
    end
    
%     block = qammod(bunchedBlk,4);
    block = real(dpskmod(block,2));
    modBlk = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%  Add Pilot & Zero Subcarriers %%%%%     
    
    noPilot = length(pilotSig);
    blockLen = length(block);
    pilotInterval = floor(blockLen / (noPilot +1 ) );
   
    blkStIdx = 1;
    blkWithPilot = [];
    for pIdx = 1:noPilot
        blkEdIdx = blkStIdx + pilotInterval - 1;
        blkWithPilot = [blkWithPilot; block(blkStIdx : blkEdIdx);pilotSig(pIdx)];
        blkStIdx = blkEdIdx + 1;
    end
    if length(block) > blkStIdx
        blkWithPilot = [blkWithPilot; block(blkStIdx:end)];
    end
    block = blkWithPilot;
    
%     block = [ pilotSig(1); block(1:blockLen/4); pilotSig(2); block(blockLen/4+1 : 2*blockLen/4); 0; 0; block(2*blockLen/4 + 1 : 3 * blockLen/4); pilotSig(3); block(3*blockLen/4 + 1 : end); pilotSig(4);];
%     blkWithPilot = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    %%%%% Add Zero Subcarriers %%%%%
    
    %%%%% IDFT %%%%% 
    block =[block(end - length(block)/2 + 1:end); zeros(symLength - length(block), 1); block(1:length(block)/2)];
    extendedBlk = block;
    block = noDataCarrier .* ifft(block);
    transformedBlk = block;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
	%%%%% Add Cyclic Prefix %%%%%%%
    
%     block = [block(end-cpLength+1:end); block];
%     cpAddedBlk = block;
    
%     lpf = txrxLpf;
%     lpfDelay = lpf.order / 2
%     lpfExtBlock = [block; zeros(lpfDelay, 1)];
%     lpfExtBlock = filter(lpf, lpfExtBlock);
%     block = lpfExtBlock(lpfDelay+1 : end);
%     lpfExtBlock = block;

    
    subplot(numBlocks,4, idx*4-3 );
    stem(modBlk);
    subplot(numBlocks,4, idx*4-2 );
    stem(real(blkWithPilot)); hold on; stem(imag(blkWithPilot),'g'); hold off;
    subplot(numBlocks,4, idx*4-1);
    stem(real(extendedBlk)); hold on; stem(imag(extendedBlk),'g'); 
    subplot(numBlocks,4, idx*4);
    plot(real(transformedBlk)); hold on; plot(imag(transformedBlk),'g'); hold off;

%     lengthBlock = length(block)
    %     extendedBlk = block;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    result(:, idx) = block; 
end



end

