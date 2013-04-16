function x2 = SoundGenerate(x,f,msg1)

t = 1/44100:1/44100:2000/44100;
sig = sin(2*pi*f*t);
x2 = 0;

sig1 = sig;
sig2 = sig;
sig3 = sig;
for i=1:30
    sig1(i) = sig1(i) * i/30;
    sig2(i) = sig2(i) * i/30;
    sig2(2001-i) = sig2(2001-i) * i/30;
    sig3(2001-i) = sig3(2001-i) * i/30;
end

msg(1:6) = dec2bin(63);
for j=1:length(msg1)
    msg1(j)
    if(msg1(j) == -38)  % ':'
        msg(6*j+1) = dec2bin(0);
        tmp = dec2bin(27,5);
    elseif(msg1(j) == 30)  % '~'
        msg(6*j+1) = dec2bin(0); 
        tmp = dec2bin(28,5);
    elseif(msg1(j) == -49)  % '/'
        msg(6*j+1) = dec2bin(0); 
        tmp = dec2bin(29,5);
    elseif(msg1(j) == -50)  % '.'
        msg(6*j+1) = dec2bin(0); 
        tmp = dec2bin(30,5);
    elseif(msg1(j) == -51)  % '-'
        msg(6*j+1) = dec2bin(0);
        tmp = dec2bin(31,5);
    elseif(msg1(j) > 0)
        msg(6*j+1) = dec2bin(1);
        tmp = dec2bin(msg1(j),5);
    elseif(msg1(j) < 0)
        msg1(j) = msg1(j) + 32;
        msg(6*j+1) = dec2bin(0);
        tmp = dec2bin(msg1(j),5);
    end
    
    
    msg(6*j+2) = tmp(1);
    msg(6*j+3) = tmp(2);
    msg(6*j+4) = tmp(3);
    msg(6*j+5) = tmp(4);
    msg(6*j+6) = tmp(5);
end
msg(6*(length(msg1)+1)+1:6*(length(msg1)+1)+6) = dec2bin(63);
msg
a = 0.7;
b = 0.3;

i = 1;
bin_0 = dec2bin(0);
bin_1 = dec2bin(1);

if(msg(1) == bin_0)
    x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000);
else
    if(msg(2) == bin_1)
      x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000) + b*transpose(sig1);
    else
      x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000) + b*transpose(sig2);
    end
end    

i = length(msg);

if(msg(length(msg)) == bin_0)
    x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000);
else
    if(msg(length(msg)-1) == bin_1)
      x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000) + b*transpose(sig3);
    else
      x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000) + b*transpose(sig2);
    end
end   

for i=2:length(msg)-1
    if msg(i) == bin_0
        x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000);
    else
        if msg(i-1) == bin_0 && msg(i+1) == bin_0
            x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000) + b*transpose(sig2);
        else if msg(i-1) == bin_0
                x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000) + b*transpose(sig1);
            else if msg(i+1) == bin_0
                x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000) + b*transpose(sig3);
            else
                x2((i-1)*2000+1:i*2000) = a*x((i-1)*2000+1:i*2000) + b*transpose(sig);
                end
            end
        end
    end
end


