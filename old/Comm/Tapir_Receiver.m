r = audiorecorder(44100, 16, 1);
while(1)
    recordblocking(r, 0.1);     % speak into microphone...
    p = play(r);
end
