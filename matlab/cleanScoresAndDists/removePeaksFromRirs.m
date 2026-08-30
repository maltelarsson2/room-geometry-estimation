function rirs = removePeaksFromRirs(rirs, d, sampleRate, v, d_threshold)
%REMOVEPEAKSFROMRIRS Summary of this function goes here
%   Detailed explanation goes here
ind_thresh = round(d_threshold/v*sampleRate);
for i = 1:size(rirs, 1)
    for j = 1:size(rirs, 2)
        rir = rirs{i,j};
        ind = round(d(i,j)/v*sampleRate);
        rirs{i,j} = removePeaksFromRir(rir, ind, ind_thresh); 
    end
end



end

function rir = removePeaksFromRir(rir, ind, ind_thresh)
    for i = ind-ind_thresh:ind+ind_thresh
        if i < 1 || i > length(rir)
            continue;
        end
        rir(i) = 0;
    end

end

