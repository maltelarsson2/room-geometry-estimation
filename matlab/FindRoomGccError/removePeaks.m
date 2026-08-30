function [score] = removePeaks(score, inds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for i = 1:size(score, 2)
    curInd = inds(i);
    if isnan(curInd) || curInd <1 || curInd > size(score, 1)
        continue;
    end
    curVal = score(curInd, i);
    increasing = true;
    for k = (curInd+1):size(score, 1)
        if increasing
            if score(k, i) < curVal
                increasing = false;
            end
            curVal = score(k,i);
            score(k,i) = 0;
        else
            if score(k, i) > curVal
                break;
            end
            curVal = score(k,i);
            score(k,i) = 0;
        end
    end

    curVal = score(curInd, i);
    increasing = true;
    for k = (curInd-1):-1:1
        if increasing
            if score(k, i) < curVal
                increasing = false;
            end
            curVal = score(k,i);
            score(k,i) = 0;
        else
            if score(k, i) > curVal
                break;
            end
            curVal = score(k,i);
            score(k,i) = 0;
        end
    end
    
    score(curInd, i) = 0;
end


end

