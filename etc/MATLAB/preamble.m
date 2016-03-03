clear;
TapirConf;

Fc = 20000;
preambleLen = 2048;
dcOffset = 2;

%temp Data
data = -1+2*round(rand( 16, 1));
ifftData = ifft( [ zeros(1,1); data(1:8); zeros(2030,1); data(9:16); zeros(1,1)]);

hpn = comm.PNSequence('Polynomial',[3 2 0],'SamplesPerFrame', 8, 'InitialConditions',[0 0 1]);
pnSeq8 = step(hpn);
pnSeq8(pnSeq8 == 0) = -1;
pnSeq = reshape([zeros(8,1), pnSeq8]',16,1);

% pnSeq16 = [pnSeq8; step(hpn)];
% pnSeq16(pnSeq16 == 0) = -1;
% preambleWithZeros = reshape([zeros(8,1), pnSeq8]',16,1)
% preambleWithZeros = pnSeq8

extendedPreamble = [zeros(dcOffset,1); pnSeq(1:length(pnSeq)/2); zeros(preambleLen - length(pnSeq) - dcOffset ,1); pnSeq(length(pnSeq)/2 +1 : end ); ];

ifftPreamble = ifft(extendedPreamble);

dataWithPreamble = [ifftPreamble; zeros(preambleLen/2,1) ;ifftData];


% % % % % LPF
% lpf = txrxLpf;
% lpfDelay = lpf.order / 2;
% lpfExtBlock = [dataWithPreamble; zeros(lpfDelay, 1)];
% lpfExtBlock = filter(lpf, lpfExtBlock);
% lpfData = lpfExtBlock(lpfDelay+1 : end);
lpfData = dataWithPreamble;

sendSig = freqUpConversion(lpfData, Fc, Fs);

knownPreamble = freqUpConversion(ifftPreamble, Fc, Fs);
knownPreamble = knownPreamble(1:length(knownPreamble)/2);

hPreambleLen = preambleLen / 2;
qPreambleLen = preambleLen / 4;

h_matchedFilter = knownPreamble;
h_len = length(h_matchedFilter);

rcvSig = [zeros(h_len,1); sendSig; zeros(h_len,1)];
rcvSig = awgn(rcvSig,1,'measured');
M = zeros(length(rcvSig),1);

for idx=h_len+1:length(rcvSig)
    for k = 0:(h_len-1)
        M(idx) = M(idx) + rcvSig(idx - k) * h_matchedFilter(h_len-k);
    end
end;

% 
% for idx=h_len*2+1:length(rcvSig)
%     for k = 0:(h_len-1)
%         M(idx) = M(idx) + rcvSig(idx - k) * rcvSig(idx-k-1024);
%     end
% end;

M = M(h_len+1:end - h_len);
tufvesson = zeros(length(M),1);
for idx = h_len+1:length(M)
tufvesson(idx) = M(idx) * M(idx - h_len);
end
% 
% for idx=1:length(M)
%     for
% end





figure();
subplot(8,1,1);
stem(pnSeq8);

subplot(8,1,2);
plot(real(ifftPreamble)); hold on;
plot(imag(ifftPreamble),'g'); hold off;

for idx=1:4
    subplot(8,4,8+idx);
    plot(real(ifftPreamble((idx-1)*qPreambleLen + 1 : idx*qPreambleLen ))); hold on;
    plot(imag(ifftPreamble((idx-1)*qPreambleLen + 1 : idx*qPreambleLen )),'g'); hold off;

    
end

subplot(8,1,4);
plot(sendSig);
subplot(8,1,5);
plot(rcvSig);

subplot(8,1,6);
plot(real(M)); hold on; plot(imag(M),'g'); hold off;
subplot(8,1,7);
plot(abs(tufvesson));
subplot(8,1,8);
pwelch(sendSig, [],[],[],Fs,'centered');
