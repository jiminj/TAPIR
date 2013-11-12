clear;
TapirConf;

Fc = 20000;
preambleLen = 2048;
hPreambleLen = preambleLen / 2;
qPreambleLen = preambleLen / 4;


%temp Data
data = -1+2*round(rand( 16, 1));
ifftData = ifft( [ zeros(1,1); data(1:8); zeros(2030,1); data(9:16); zeros(1,1)]);

hpn = comm.PNSequence('Polynomial',[3 2 0],'SamplesPerFrame', 4, 'InitialConditions',[0 0 1]);
pnSeq4 = step(hpn);
pnSeq4(pnSeq4 == 0) = -1;
% pnSeq = reshape([zeros(4,1), pnSeq4]',8,1);
pnSeq = pnSeq4;

qPreamble = [pnSeq(1:length(pnSeq)/2); zeros(qPreambleLen - length(pnSeq),1); pnSeq(length(pnSeq)/2 +1 : end ); ];
ifftQPreamble = ifft(qPreamble);

% pnSeq16 = [pnSeq8; step(hpn)];
% pnSeq16(pnSeq16 == 0) = -1;
% preambleWithZeros = reshape([zeros(8,1), pnSeq8]',16,1)
% preambleWithZeros = pnSeq8

% extendedPreamble = [zeros(dcOffset,1); pnSeq(1:length(pnSeq)/2); zeros(preambleLen - length(pnSeq) - dcOffset ,1); pnSeq(length(pnSeq)/2 +1 : end ); ];

ifftPreamble = [-ifftQPreamble; ifftQPreamble; -ifftQPreamble; -ifftQPreamble];
% dataWithPreamble = ifftPreamble;
dataWithPreamble = [ifftPreamble; zeros(preambleLen/2,1) ;ifftData];

% 
lpfData = dataWithPreamble;
sendSig = freqUpConversion(lpfData, Fc, Fs);

rcvSig = [zeros(preambleLen,1); sendSig; zeros(preambleLen,1)];
rcvSig = awgn(rcvSig,1,'measured');

% 
% h_matchedFilter = knownPreamble;
% h_len = length(h_matchedFilter);
% 


distance = 512;
P = zeros(1,length(rcvSig));
R = zeros(1,length(rcvSig));
Rf = R;
Rf2 = R;

for idx = (preambleLen + 1):(length(P) - distance)
    denom = 0;
    for k = 0:1
        for m = 0:distance-1
            b = rcvSig(idx - m - (2*k)*distance);
            P(idx) = P(idx) + rcvSig(idx - m - (2*k+1)*distance) * b;
            R(idx) = R(idx) + abs(b)^2;
        end
    end
end

M = ( abs(P) .^ 2 ) ./ (R.^2);

% M = zeros(length(rcvSig),1);
% 
% for idx=h_len+1:length(rcvSig)
%     for k = 0:(h_len-1)
%         M(idx) = M(idx) + rcvSig(idx - k) * h_matchedFilter(h_len-k);
%     end
% end;
% M = M(h_len+1:end - h_len);
% tufvesson = zeros(length(M),1);
% for idx = h_len+1:length(M)
% tufvesson(idx) = M(idx) * M(idx - h_len);
% end
% % 
% % for idx=1:length(M)
% %     for
% % end
% 
% 
% 
% 
% 
figure();
subplot(8,1,1);
stem(pnSeq);

subplot(8,1,2);
plot(real(ifftPreamble)); hold on;
plot(imag(ifftPreamble),'g'); 

subplot(8,1,3);
plot(sendSig);

for idx=1:4
    subplot(8,4,12+idx);
    plot(real(sendSig((idx-1)*qPreambleLen + 1 : idx*qPreambleLen ))); hold on;
    plot(imag(sendSig((idx-1)*qPreambleLen + 1 : idx*qPreambleLen )),'g'); hold off;
end

subplot(8,1,4);
plot(rcvSig);

subplot(8,1,5);
plot(P);
subplot(8,1,6);
plot(R);
subplot(8,1,7);
plot(M);

% 
% subplot(4,1,4);
% plot(sendSig);
% subplot(8,1,5);
% plot(rcvSig);
% 
% subplot(8,1,6);
% plot(real(M)); hold on; plot(imag(M),'g'); hold off;
% subplot(8,1,7);
% plot(abs(tufvesson));
subplot(8,1,8);
pwelch(sendSig, [],[],[],Fs,'centered');
