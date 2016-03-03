clear;

filename = 'test20.wav';
filename = [pwd, '/', filename];
rxAudioData = audioread(filename);
rxAudioData = rxAudioData(7000:20000);

recAudioData = audioread('recSample.wav');

figure();
subplot(1,2,1);
plot(rxAudioData,'k');
xlabel('Samples');
ylabel('Amplitude');
axis([0 15000 -1.0 1.0]);
title('Waveform');
subplot(1,2,2);
pwelch(rxAudioData, hamming(2048),[],[],44100,'centered');

% subplot(1,2,1);
% plot(recAudioData,'k');
% axis([0 200000 -1.0 1.0]);
% xlabel('Samples');
% ylabel('Amplitude');
% 
% subplot(1,2,2);
% specgram(recAudioData,512,44100,kaiser(500,5),475);
% %  imagesc(abs(S));