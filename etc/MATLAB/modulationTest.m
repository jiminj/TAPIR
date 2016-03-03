clear;
% 
% n = 10;
% mag = 1;
% phase = 0: (2*pi)/n : 2*pi - (2*pi)/n;
% value = zeros(n,1);
% 
% value = cos(phase)/mag + i * sin(phase)/mag;
% result = pskdemod(value,2,pi/2)
% 
% data = randi([0,3],10,1)
% pmod = pskmod(data,4);
% dpmod = dpskmod(data,4);
% dpmod_revert = pskdemod(dpmod,4);
% 
% 
% [data dpmod_revert]

TapirConf;
pilotLen = length(pilotSig);

pilotInterval = floor(noDataCarrier / (pilotLen+1));
pilotLocation = [];
for idx = 1:pilotLen
    pilotLocation = [pilotLocation; (idx * pilotInterval + idx)];
end