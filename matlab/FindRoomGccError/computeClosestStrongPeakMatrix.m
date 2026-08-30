function [peaksInd] = computeClosestStrongPeakMatrix(gccScores,scoreLim, distThreshold, gccSettings)
%COMPUTECLOSESTSTRONGPEAKMATRIX Summary of this function goes here
%   Detailed explanation goes here
    indThresh = round(distThreshold/gccSettings.v*gccSettings.sr);

    peaksInd = cell(size(gccScores)); 
    for i = 1:size(gccScores, 1)
        for j = 1:size(gccScores, 2)
            score = gccScores{i,j};
            peaks = nan(size(score)+[2*indThresh, 0]);
            [~, order] = sort(score);
            for k = 1:size(score, 2)
                for t = 1:size(order,1)
                    pos = order(t,k);
                    if score(pos, k) < scoreLim %0.01
                        continue;
                    end
                    peaks(pos:(pos+2*indThresh),k) = pos;
                end
            end
            peaksInd{i,j} = peaks((indThresh+1):(end-indThresh),:);
        end
    end

end

