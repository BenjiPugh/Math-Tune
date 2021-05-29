function modified_channel = modify_channel(channel, fs)

    xlen = length(channel);
    t = (0:xlen-1)/fs;                  

    % define the analysis and synthesis parameters
    wlen = 1024;
    hop = wlen/8;
    nfft = 64*wlen;

    % generate analysis and synthesis windows
    anal_win = blackmanharris(wlen, 'periodic');
    synth_win = hamming(wlen, 'periodic');

    % perform time-frequency analysis
    [STFT, freq, ~] = stft(channel, anal_win, hop, nfft, fs);

    % modify the signal
    modified_stft = modify_stft(STFT, freq);
    
    % resynthesize the signal
    [modified_channel, ~] = istft(modified_stft, anal_win, synth_win, hop, nfft, fs);
end