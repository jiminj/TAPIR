Microphone = dsp.AudioRecorder(44100,4096);
Speaker = dsp.AudioPlayer;
SpecAnalyzer = dsp.SpectrumAnalyzer;

tic;
while (toc < Inf)
    audio = step(Microphone);
    step(SpecAnalyzer, audio);
    step(Speaker, audio);
end
