function result = generateSinPreamble(codeLength, bandwidth, Fs)

%     preambleLen = 2048;
%     dcOffset = 2;

    hBCode = comm.BarkerCode('SamplesPerFrame', codeLength);
    barkerSeq = step(hBCode);
%     bandwidth = 441;
    samplesPerPhase = Fs/bandwidth;

%     t=0:1/Fs:(samplesPerPhase * length(barkerSeq) -1 ) / Fs;
    result = rectpulse(barkerSeq, samplesPerPhase);
%     carrier = cos(2 * pi * Fc * t)';
    
%     result = modMatrix .* carrier;
    
end