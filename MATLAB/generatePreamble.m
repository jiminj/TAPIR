function result = generatePreamble(preambleLen, dcOffset)

%     preambleLen = 2048;
%     dcOffset = 2;

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
    result = ifftPreamble;
    
end