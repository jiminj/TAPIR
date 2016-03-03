f=17640;
t = 1/44100:1/44100:2000/44100;
sig = sin(2*pi*f*t);
zero = zeros(1,2000);
sigs = [sig zero sig zero sig zero sig zero sig zero sig zero sig zero sig zero sig zero sig zero sig zero sig zero sig zero sig zero];
sigs = [sigs sigs sigs sigs sigs sigs];
sound(sig,44100);