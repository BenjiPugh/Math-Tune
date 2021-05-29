function modified_stft = modify_stft(stft_decomp, freq)
    % Take a short time fourier transform decomposition and modify it using
    % modify_slice algorithm to align the harmonic bands with 12TET
    % Note: I don't believe harmonic band is a real term, but what I mean
    % by it are essentially the frequency bands seen on a spectrogram at
    % each of the harmonics and the fundamental.
    %
    % Args:
    %   stft: a matrix representing the short time fourier transform
    %         decomposition of some signal.
    
    
    norm_stft = abs(stft_decomp);
    angle_stft = angle(stft_decomp);
    
    modified_slices = zeros(size(stft_decomp));
    for i = 1 : size(stft_decomp, 2)
        current_slice = norm_stft(:, i);
        modified = modify_slice(current_slice, freq);
        modified_slices(:, i) = modified;
    end
    
    % Eulers equation to reconvert to complex
    modified_stft = modified_slices .* exp(angle_stft);
end