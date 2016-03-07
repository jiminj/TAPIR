
clear;
TapirConf;
Fs = 44100;

src = wgn(Fs,1,0);

figure();
subplot(2,1,1); plot(src);
subplot(2,1,2); pwelch(src, hamming(2048),[],[],Fs,'centered');


txLpf = txrxLpf441;
txLpfDelay = txLpf.order / 2;
txHpf = hpfchev19k250;
txHpfDelay = txHpf.order / 2;
filtered = src;


% % %hpf
% filtered = [src; zeros(txHpfDelay,1)];
% filtered = filter(txHpf, filtered);  % Filtering
% filtered = filtered(txHpfDelay+1:end);

% 
filtered = [filtered; zeros(txLpfDelay,1)];
filtered = filter(txLpf, filtered);
filtered = filtered(txLpfDelay+1:end);

tC = (0:1/Fs:(length(filtered)-1)/Fs);
carrier = cos(2*pi* 18000 *tC).';
filtered = carrier .* filtered;

figure();
subplot(2,1,1); plot(filtered);
subplot(2,1,2); pwelch(filtered, hamming(2048),[],[],Fs,'centered');
    

filename = ['./filtered.wav'];
audiowrite(filename, filtered, Fs, 'BitsPerSample', 16);