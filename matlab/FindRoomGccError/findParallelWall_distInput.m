function [parallelWall] = findParallelWall_distInput(r, s, d_nlos, wall, threshold, opt, do_plot)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin < 6
    opt = true;
end
if nargin < 7
    do_plot = false;
end

maxWidth = 20;
numPoints = maxWidth*100;
curShift = wall(4);
searchspace = [linspace(curShift-maxWidth, curShift-0.3, numPoints), linspace(curShift+0.3, curShift+maxWidth, numPoints)];
bestWall = [];
bestVal = -Inf;
vals = zeros(1, length(searchspace));
for shifti = 1:length(searchspace)
    testWall = wall;
     
    shift = searchspace(shifti);
    testWall(4) = shift;
    [inliers, inlierDistances] = find_inliers(r, s, d_nlos, testWall, threshold);
    val = size(inliers, 1);
    % errors = abs(inlierDistances-wallToToas(r, s, testWall));
    % errors(isnan(errors)) = threshold;
    % val = -sum(errors, "all");
    if val > bestVal
        bestVal = val;
        bestWall = testWall;
    end
    vals(shifti) = val;
end
if do_plot
    figure()
    plot(searchspace, vals, ".")
end
if opt
    % parallelWall = optimizeAgainstStrongestClosePeak(bestWall', r, s, scores, gccPhatSettings, 0.2);
    parallelWall = optimizeAgainstInliers(bestWall, r, s, d_nlos, threshold);

    parallelWall = parallelWall(end,:)';
else
    parallelWall = bestWall;
end
end

