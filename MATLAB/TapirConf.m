
Fs = 44100; % Sampling Frequency
% Fc = 18000; % Carrier Frequency

noDataFrame = 8; % FrameSize
encodingRate = 1/2; % Channel Encoding Rate
modulationRate = 1; % DPSK Modulation Rate
noDataCarrier = noDataFrame / modulationRate / encodingRate;

% %%% Pilot 
% 
% pilot = [1,1,1,1];
% noPilotCarrier = length(pilot);
% noDcCarrier = 1; 
% 
% lenBitsBetweenPilot = noDataCarrier / noPilotCarrier;
% pilotPos = zeros(1, length(pilot));
% for idx=1:length(pilot)
%     if(idx <= length(pilot)/2)
%         position = idx + (idx-1) * lenBitsBetweenPilot;
%     else
%         position = idx + idx * lenBitsBetweenPilot + noDcCarrier;
%     end
%     pilotPos(idx) = position;
% end
% % pilotPos = [1,6,16,21]; %temp
% 
% 
% noTotCarrier = noDataCarrier + noDcCarrier + noPilotCarrier;

% Trellis Code for Convolutional Encoding
trel = poly2trellis(7, [133 171]);
tbLen = 16; %Traceback Length for Viterbi decoder

intRows = 4;
intCols = (noDataCarrier)/intRows;

% symLength = 1024;
% lenPrefix = 256;
symLength = 2048;
% lenPrefix = symLength / 4;
lenPrefix = 0;

guardInterval = 1024;


% Symbol & GI Length (without preamble)
% txBlockLength = symLength + lenPrefix;
% txBitRate = Fs / (txBlockLength) * noDataFrame;
% totalDataRate = Fs / (txBlockLength + guardInterval) * noDataFrame;


% IEEE 802.11a preamble
% shortPreambleData = sqrt(8/3) * [0; 0; 0; 0; 0; 0; 0; 0; ...
%                                  1+1i; 0; 0; 0; -1-1i; 0; 0; 0; ...
%                                  1+1i; 0; 0; 0; -1-1i; 0; 0; 0; ...
%                                  -1-1i; 0; 0; 0; 1+1i; 0; 0; 0; ...
%                                  0; 0; 0; 0; -1-1i; 0; 0; 0; ...
%                                  -1-1i; 0; 0; 0; 1+1i; 0; 0; 0; ...
%                                  1+1i; 0; 0; 0; 1+1i; 0; 0; 0; ...
%                                  1+1i; 0; 0; 0; 0; 0; 0; 0]; 
% 
% shortPreamble = ifft(shortPreambleData);
% figure(1); subplot(2,1,1); plot(real(shortPreamble));
% subplot(2,1,2); pwelch(repmat(shortPreamble,32,1),hamming(512),[],[],44100,'centered')  
% shortPreamble = shortPreamble(1:length(shortPreamble)/4);
% 
% noPreambleRepeat = 10;

%%%%% Raised Cosine Filter for Pulse Shaping %%%%
    
% Nsym = 20;           % Filter order in symbol durations
% beta = 0.2;         % Roll-off factor
% % filterDelay = Nsym/2 * samplesPerSym;
% shape = 'Square Root Raised Cosine';    % Shape of the pulse shaping filter

% Specifications of the raised cosine filter with given order in symbols
% raisedCosSpec = fdesign.pulseshaping(samplesPerSym, shape,'Nsym,beta', Nsym, beta);
% raisedCosFltTx = design(raisedCosSpec);
% normFact = max(raisedCosFltTx.Numerator);
% % raisedCosFltTx.Numerator = raisedCosFltTx.Numerator / normFact;
% 
% 
% % Filter at the receiver.
% raisedCosFltRcv = design(raisedCosSpec);
% raisedCosFltRcv.Numerator = raisedCosFltRcv.Numerator * (normFact*samplesPerSym);
% 
% 
% raisedCosDecSpec = fdesign.decimator(samplesPerSym, shape, samplesPerSym, 'Nsym,beta', Nsym, beta);
% raisedCosFltDecRcv = design(raisedCosDecSpec);
% raisedCosFltDecRcv.Numerator = raisedCosFltDecRcv.Numerator * (normFact*samplesPerSym);
% 



