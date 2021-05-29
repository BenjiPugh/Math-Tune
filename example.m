clear, clc, close all

% load an audio signal
[x, fs] = audioread('track.wav');
% channel_1 = x(:, 1);
% channel_2 = x(:, 2);
x = x(:, 1);
audiowrite('validate_track.wav', x, fs)
% signal parameters
xlen = length(x);
t = (0:xlen-1)/fs;                  

% define the analysis and synthesis parameters
wlen = 1024;
hop = wlen/8;
nfft = 64*wlen;

% generate analysis and synthesis windows
anal_win = blackmanharris(wlen, 'periodic');
synth_win = hamming(wlen, 'periodic');

% perform time-frequency analysis and resynthesis of the signal
[STFT, freq, ~] = stft(x, anal_win, hop, nfft, fs);
% [STFT_1, ~, ~] = stft(channel_1, anal_win, hop, nfft, fs);
% [STFT_2, ~, ~] = stft(channel_2, anal_win, hop, nfft, fs);


% %spectral noise gate 
% is_louder = STFT > 0.1 * repmat(max(abs(STFT)), size(STFT,1), 1);
% STFT = STFT .* is_louder * 2;


[x_istft, t_istft] = istft(STFT, anal_win, synth_win, hop, nfft, fs);
% [istft_1, ~] = istft(STFT_1, anal_win, synth_win, hop, nfft, fs);
% [istft_2, ~] = istft(STFT_2, anal_win, synth_win, hop, nfft, fs);
 
% plot the original signal
figure(1)
plot(t, x, 'b')
grid on
xlim([0 max(t)])
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Time, s')
ylabel('Signal amplitude')
title('Original and reconstructed signal')
% 
length(x_istft)
% plot the resynthesized signal 
hold on
plot(t_istft, x_istft, '-.r')
legend('Original signal', 'Reconstructed signal')




% Save the resynthesized signal as a wave file
% full_reconstruct = [istft_1; istft_2]';
audiowrite('resynth_track.wav', x_istft, fs)