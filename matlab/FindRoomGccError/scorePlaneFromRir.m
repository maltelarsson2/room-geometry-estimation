function score = scorePlaneFromRir(plane,rirs, r, s, sampleRate, v)
%SCOREPLANEFROMRIR Summary of this function goes here
%   Detailed explanation goes here

d_thresh = 0.05;
ind_thresh = round(d_thresh/v*sampleRate);
score = 0;
d_wall = wallToToas(r, s, plane);
numR = size(r, 2);
numS = size(s, 2);
for i = 1:numR
    for j = 1:numS
        rir = rirs{i,j};
        ind = round(d_wall(i, j)/v*sampleRate);
        score = score + getScoreFromRir(rir, ind, ind_thresh);
    end
end




end


function score = getScoreFromRir(rir, ind, threshold)
    score = -Inf;
    for i = ind-threshold:ind+threshold
        if i < 1 || i > length(rir)
            continue;
        end
        score = max(score, rir(i));
    end
end

