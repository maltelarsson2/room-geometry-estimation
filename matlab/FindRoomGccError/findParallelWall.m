function [parallelWall] = findParallelWall(r, s, gccPhatSettings, scores, wall, allPeaks, opt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin < 6
    allPeaks = computeClosestStrongPeakMatrix(scores, 0.01, 0.2, gccPhatSettings);
end
if nargin < 7
    opt = true;
end
maxWidth = 20;
numPoints = maxWidth*100;
curShift = wall(4);
searchspace = [linspace(curShift-maxWidth, curShift-0.3, numPoints), linspace(curShift+0.3, curShift+maxWidth, numPoints)];
bestWall = [];
bestVal = -Inf;
for shifti = 1:length(searchspace)
    testWall = wall;
     
    shift = searchspace(shifti);
    testWall(4) = shift;
    val = scorePlaneFromGcc2(r, s, testWall', scores, gccPhatSettings);
    if val > bestVal
        bestVal = val;
        bestWall = testWall;
    end
end
if opt    
    parallelWall = optimizeAgainstStrongestClosePeak2(bestWall', r, s, scores, gccPhatSettings, allPeaks);
    parallelWall = parallelWall(end,:)';
else
    parallelWall = bestWall;
end
end

