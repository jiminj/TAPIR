function result = freqUpConversion( signal, Fc, Fs)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    TapirConf;
    
    tS = (0:1/Fs:(length(signal)-1)/Fs);

    % %%%%% I&Q Modulation & Frequency Upconversion %%%%%

    tC = (0:1/Fs:(length(signal)-1)/Fs);
    carrier = 2 * exp(1i*2*pi*Fc*tC).';
    rePulse = real(signal) .* real(carrier);
    imPulse = imag(signal) .* imag(carrier);
    modulatedSig = rePulse + imPulse;

    % Scaling
    modulatedSig = modulatedSig * (0.95 / max(abs(modulatedSig)));
    result = modulatedSig;
end

