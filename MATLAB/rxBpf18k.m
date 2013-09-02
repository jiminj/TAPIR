function Hd = rxBpf18k
%RXBPF18K Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 8.1 and the Signal Processing Toolbox 6.19.
% Generated on: 24-Aug-2013 18:17:07

% FIR Window Bandpass filter designed using the FIR1 function.

% All frequency values are in Hz.
Fs = 44100;  % Sampling Frequency

N    = 30;       % Order
Fc1  = 17000;    % First Cutoff Frequency
Fc2  = 19000;    % Second Cutoff Frequency
flag = 'scale';  % Sampling Flag
Beta = 0.2;      % Window Parameter
% Create the window vector for the design algorithm.
win = kaiser(N+1, Beta);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, [Fc1 Fc2]/(Fs/2), 'bandpass', win, flag);
Hd = dfilt.dffir(b);

% [EOF]
