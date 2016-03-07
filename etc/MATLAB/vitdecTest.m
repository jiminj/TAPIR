clear;

TapirConf;

noIt = 500;
result = zeros(noIt,1);

for idx=1:noIt

    block = round(rand( 32, 1));
    convEncBlk = convenc(block, trel);
%     extBlk = [convEncBlk; zeros(length(convEncBlk),1)];
    extBlk = convEncBlk;
    decodedBlk = vitdec(extBlk, trel, tbLen, 'trunc', 'hard');
%     decodedBlk = decodedBlk(1:length(block));

    result(idx) = sum(xor(block, decodedBlk));
end

figure();
plot(result);

% [block, decodedBlk]



% decodedBlk = decodedBlk(1:length(decodedBlk)/2)
% analyzedMat(:,blkIdx) = decodedBlk;