function result = freqDownConversion( signal, Fc, Fs )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    % %%%% Downconversion %%%%%%
    
    tC = (0:1/Fs:(length(signal)-1)/Fs);

    phaseOffset = 0;
    % phaseOffset = pi/4;
    carrier = sqrt(2) * exp(1i * (2 * pi * Fc * tC + phaseOffset) )';

%     basebandSig = real(signal .* carrier);
    
    realRx = signal .* real(carrier);
    imagRx = signal .* imag(carrier);    
    basebandSig = realRx + 1i*imagRx;



    % %%%%% LPF %%%%%%%%%%% 
%     lpf = txrxLpf;
%     lpfDelay = ceil(lpf.order / 2);
%     basebandSig = [basebandSig; zeros(lpfDelay,1)];
%     filteredSig = filter(lpf, basebandSig);
%     
%     result = filteredSig(lpfDelay+1 :end);

    result = basebandSig;
    
end

