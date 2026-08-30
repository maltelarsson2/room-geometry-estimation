function [toas] = rirsToToas(rirs, sampleRate, v, numPeaks)
%RIRTOTOAS Summary of this function goes here
%   Detailed explanation goes here
numR = size(rirs, 1);
numS = size(rirs, 2);

toas = cell(size(rirs));
for i = 1:numR
    for j = 1:numS
        toas{i,j} = extract_peaks(rirs{i,j}, numPeaks)*v/sampleRate;
    end
end


end


function peak_inds = extract_peaks(values, num_peaks)
    peak_inds = nan([1, num_peaks]);
    peak_values = -Inf*ones(1, num_peaks);
    for i = 1:length(values)
        isPeak = true;
        if i < length(values)
            if values(i)<values(i+1)
                isPeak = false;
            end
        end
        if i > 1
            if values(i)<values(i-1)
                isPeak = false;
            end            
        end
        if isPeak
            [peak_inds, peak_values] = maxList(peak_inds, peak_values, i, values(i));
        end
    end
end
