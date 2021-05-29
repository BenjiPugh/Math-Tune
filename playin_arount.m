% Normalize the complex 
spectro = abs(STFT);
% get a slice of the STFT at a somewhat arbitrary point in time
slice = spectro(:, 150);
norm_image = 255 * slice / max(slice);

% Display the spectrogram at that slice in time
% clf
% image(norm_image);
% colormap 'default'

% Get the harmonic frequencies, which are the local maxima of the fourier 
[harmonics,locs] = findpeaks(slice);
frequencies = freq(locs)';
peaks = sortrows([harmonics, locs, frequencies], 'descend');

threshold = 0.01;

%get rid of the peaks that are below our threshold for importance
for i = 2 : size(peaks, 1)
    if peaks(i,1) < threshold * peaks(1,1)
        peaks = peaks(1:i-1, :);
        break
    end
end

% Calculate the region at which the frequency band is for e
upper_limits = peaks(:,1);
lower_limits = upper_limits;
for peak = 1 : size(peaks,1)
    for neighbor = peaks(peak,2) + 1 : length(slice)
        if slice(neighbor) > slice(neighbor - 1)
            break
        end
        upper_limits(peak) = neighbor;
    end
    for neighbor = peaks(peak,2) - 1 : -1 : 1
        if slice(neighbor) > slice(neighbor + 1)
            break
        end
        lower_limits(peak) = neighbor;
    end
end
peaks = [peaks, upper_limits, lower_limits];

base = 8.175799;
piano = @(x) base * 2 .^ (x ./ 12);
max_piano = floor(12 * log2(max(freq) / base));
ideal_freq = piano(1:max_piano);

% create the grid of 12 tone equal temperament frequencies that we will
% align to
A = repmat(freq',[1 length(ideal_freq)]);
[~,piano_index] = min(abs(A-ideal_freq),[],1);
closest_piano_freq = freq(piano_index');

% Calculate where the notes should transform to
original_pitches = peaks(:, 3);

A = repmat(closest_piano_freq',[1 length(original_pitches)]);
[~,transformed_index] = min(abs(A-original_pitches'),[],1);
transformed_freq = closest_piano_freq(transformed_index');
transformed_index = piano_index(transformed_index);
peaks = [peaks, transformed_freq', transformed_index'];


% Move the harmonic bands to their spaces
subtracted = slice;
rearranged = zeros(size(slice));
index_diff = peaks(:,7) - peaks(:,2);
for i = 1 : size(peaks, 1)
    for place = peaks(i,5) : peaks(i,4)
        if place + index_diff(i) > 0
            rearranged(place + index_diff(i)) = rearranged(place+index_diff(i)) + subtracted(place);
            subtracted(place) = 0;
        end
    end
end
modified = subtracted + rearranged;
norm_image = 255 * [slice, modified] / max(modified);
clf
image(norm_image);
colormap 'default'
