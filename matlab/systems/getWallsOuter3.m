function [allWalls] = getWallsOuter3(r, s, gcc_scores, gccPhatSettings, allPeaks)
%GETWALLSOUTER Summary of this function goes here
%   Detailed explanation goes here
if nargin < 5
    allPeaks = computeClosestStrongPeakMatrix(gcc_scores, 0.01, 0.2, gccPhatSettings);
end
ransac_iters = 4000;

d_grd = pdist2(r', s');
scores = gcc_scores;

d_nlos_cleaned = scoresToCleanDnlos2(scores, gccPhatSettings, r, s, d_grd);


allWalls = [];
%First wall
[walls, ~] = getWalls_martin4_2(r, s, d_nlos_cleaned, 0.05, scores, gccPhatSettings, ransac_iters, allPeaks);
allWalls = [allWalls, walls];

scores = removeUsedGccScores(scores, r, s, allWalls(:,1), gccPhatSettings);
%Wall parallel with first wall, wall 2
wall = findParallelWall(r, s, gccPhatSettings, scores, allWalls(:,1), allPeaks);
allWalls = [allWalls, wall];
scores = removeUsedGccScores(scores, r, s, allWalls(:,2), gccPhatSettings);

%"Vertical" wall, wall 3

d_nlos_cleaned = scoresToCleanDnlos2(scores, gccPhatSettings, r, s, d_grd);

wall = getWalls_martin4_2_Vertical(r,s, allWalls(1:3,1), d_nlos_cleaned, 0.05, scores, gccPhatSettings, ransac_iters, allPeaks);
allWalls = [allWalls, wall];

% wall 4
wall = findParallelWall(r, s, gccPhatSettings, scores, allWalls(:,3), allPeaks);
allWalls = [allWalls, wall];

%wall 5
lastNormal = cross(allWalls(1:3, 1), allWalls(1:3, 3));
wall = findParallelWall(r, s, gccPhatSettings, scores, [lastNormal;0], allPeaks);
allWalls = [allWalls, wall];

%wall 6
wall = findParallelWall(r, s, gccPhatSettings, scores, allWalls(:,5), allPeaks);
allWalls = [allWalls, wall];




end

