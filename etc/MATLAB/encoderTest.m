clear;

TapirConf;
Fc = 20000;

msg = 'z';
binData = dec2bin(msg, 8)' - 48
% binData = [0;1;0;1;1;0;1;0]

block = binData;
%%%%% Convolutional encoding %%%%%
block = convenc(block, trel);
%     blockSize = length(block);
%     block(block == 0) = -1; % To reduce the dynamic range of output signal.
convEncBlk = block;

%%%%% Interleaver %%%%% 
interleavedBlk = matintrlv(convEncBlk, intRows, intCols);
block = interleavedBlk;

block = real(pskmod(block,2));
modBlk = block;

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
block =[block(end - length(block)/2 + 1:end); zeros(symLength - length(block), 1); block(1:length(block)/2)];
  
extendedBlk = block;
block = ifft(extendedBlk) * 2048;
transformedBlk = block;
upconvAudioData = freqUpConversion(transformedBlk, Fc, Fs);  
extendedAudioData = [upconvAudioData(end - cPreLength + 1 : end); upconvAudioData; upconvAudioData(1:cPostLength)];
% extendedAudioData(1:10)
% extendedAudioData(cPreLength - 5: cPreLength+5)
% extendedAudioData(cPreLength + symLength - 5: cPreLength + symLength + 5)
% extendedAudioData(cPreLength + cPostLength + symLength - 10 : end)


preambleData = generateSinPreamble(preambleBitLength, preambleBandwidth, Fs);
preambleData = [preambleData; preambleData];
% preambleData = filter(txLpf, preambleData);
% preambleData = preambleData(txLpfDelay+1:end);

upconvPreamble = freqUpConversion(preambleData, Fc, Fs);


decBlk = vitdec(encBlk, trel, 8, 'trunc', 'hard');


