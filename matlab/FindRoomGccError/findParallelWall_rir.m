function [parallelWall] = findParallelWall_rir(r, s, rirs, dnlos, wall, sampleRate, v, opt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin < 8
    opt = true;
end

numPoints = 20*100;
curShift = wall(4);
searchspace = [linspace(curShift-20, curShift-0.3, numPoints), linspace(curShift+0.3, curShift+20, numPoints)];
bestWall = [];
bestVal = -Inf;
vals = [];
for shifti = 1:length(searchspace)
    testWall = wall;
     
    shift = searchspace(shifti);
    testWall(4) = shift;
    val = scorePlaneFromRir(testWall, rirs, r, s, sampleRate, v);
    if val > bestVal
        bestVal = val;
        bestWall = testWall;
    end
    vals = [vals, val];
end
% figure()
% plot(searchspace, vals, ".")
if opt
    % parallelWall = optimizeAgainstStrongestClosePeak(bestWall', r, s, scores, gccPhatSettings, 0.2);
    threshold_distance = 0.05;
    parallelWall = optimizeAgainstInliers(bestWall', r, s, dnlos, threshold_distance);

    parallelWall = parallelWall(end,:)';
else
    parallelWall = bestWall;
end
end

