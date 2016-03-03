

%  bandSig = VarName2(500000:1000000);
% bandSig = VarName2(1:400000);
% bandSig = a(170000:200000)
bandSig = VarName4;

TapirConf;
preambleLen = Fs * preambleBitLength / preambleBandwidth;
origCorrResult = zeros(length(bandSig),1);
corrResult = zeros(length(bandSig),1);
searchMaxStPoint = 0;

for idx=2*preambleLen+1:length(bandSig)       
    denom = 0;
    firstHalf = bandSig(idx - (2*preambleLen)+1 : idx - preambleLen);
    lastHalf = bandSig(idx - preambleLen + 1 : idx);
    origCorrResult(idx) = dot(firstHalf, lastHalf);
    corrResult(idx) = origCorrResult(idx) / (sum(abs(lastHalf))/ preambleLen);
    
%     denom = 0;
%     for k = 0:(preambleLen - 1)
%         corrResult(idx) = corrResult(idx) + bandSig(idx - k) * bandSig(idx - k - preambleLen);
%         denom = denom + abs(bandSig(idx-k));
%     end
%     origCorrResult(idx) = corrResult(idx);
%     corrResult(idx) = corrResult(idx) / (denom / preambleLen);
%     
%     for k = 0:(preambleLen - 1)
%         corrResult(idx) = corrResult(idx) + bandSig(idx - k) * bandSig(idx - k - preambleLen);
%         denom = denom + abs(bandSig(idx-k));
%     end
end;

figure();
subplot(4,1,1);
plot(bandSig);
subplot(4,1,2);
plot(origCorrResult);
subplot(4,1,3);
specgram(origCorrResult,512,Fs,kaiser(500,5),475)
subplot(4,1,4);
plot(corrResult);