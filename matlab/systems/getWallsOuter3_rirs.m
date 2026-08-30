function [allWalls] = getWallsOuter3_rirs(r, s, rirs, sampleRate, v, numPeaks)
%GETWALLSOUTER Summary of this function goes here
%   Detailed explanation goes here
d_grd = pdist2(r', s');
rirs = removePeaksFromRirs(rirs, d_grd, sampleRate, v, 0.05);

ransac_iters = 3000;

d_nlos_cleaned = rirsToCleanDnlos(rirs, sampleRate, v, numPeaks, r, s, d_grd);
threshold = 0.05;

allWalls = [];
%First wall
[walls, ~] = getWalls_martin_noGccScore(r, s, d_nlos_cleaned, threshold, ransac_iters);
allWalls = [allWalls, walls];

[rirs, d_nlos_cleaned] = updateWithWall(r, s, rirs, sampleRate, v, d_nlos_cleaned, walls);

%Wall parallel with first wall, wall 2
% wall = findParallelWall_rir(r,s, rirs, d_nlos_cleaned, allWalls(:,1), sampleRate, v);
wall = findParallelWall_distInput(r, s, d_nlos_cleaned, allWalls(:,1), threshold);

allWalls = [allWalls, wall];

[rirs, d_nlos_cleaned] = updateWithWall(r, s, rirs, sampleRate, v, d_nlos_cleaned, allWalls(:, 2));

%"Vertical" wall, wall 3

%FNsjafk
% wall = getWalls_martin4_2_Vertical(r,s, allWalls(1:3,1), d_nlos_cleaned, 0.05, scores, gccPhatSettings, 1000, allPeaks);

[walls, ~] = getWalls_martin_vertical_noGccScore(r, s, allWalls(1:3,1), d_nlos_cleaned, threshold, ransac_iters);
allWalls = [allWalls, walls];

[rirs, d_nlos_cleaned] = updateWithWall(r, s, rirs, sampleRate, v, d_nlos_cleaned, walls);

% wall 4
% wall = findParallelWall_rir(r,s, rirs, d_nlos_cleaned, allWalls(:,3), sampleRate, v);
wall = findParallelWall_distInput(r, s, d_nlos_cleaned, allWalls(:,3), threshold);
allWalls = [allWalls, wall];
[rirs, d_nlos_cleaned] = updateWithWall(r, s, rirs, sampleRate, v, d_nlos_cleaned, wall);

%wall 5
lastNormal = cross(allWalls(1:3, 1), allWalls(1:3, 3));
% wall = findParallelWall_rir(r,s, rirs, d_nlos_cleaned, [lastNormal;0], sampleRate, v);
wall = findParallelWall_distInput(r, s, d_nlos_cleaned, [lastNormal;0], threshold);
allWalls = [allWalls, wall];
[rirs, d_nlos_cleaned] = updateWithWall(r, s, rirs, sampleRate, v, d_nlos_cleaned, wall);

%wall 6
% wall = findParallelWall_rir(r,s, rirs, d_nlos_cleaned, allWalls(:,5), sampleRate, v);
wall = findParallelWall_distInput(r, s, d_nlos_cleaned, allWalls(:,5), threshold);
allWalls = [allWalls, wall];




end

function d_nlos = shift_dnlos(d_nlos, shift_matrix)
    for i = 1:size(d_nlos, 1)
        for j = 1:size(d_nlos, 2)
            d_nlos{i,j} = d_nlos{i, j} + shift_matrix(i,j);
        end
    end
end

function d_nlos_cleaned = removeTooSmallDistances(r, s, d_nlos_cleaned)
d_grd = pdist2(r', s');
    for i = 1:size(r, 2)
        for j = 1: size(s, 2)
            for k = 1:size(d_nlos_cleaned{i,j})
                if d_nlos_cleaned{i,j}(k) < d_grd(i,j)
                    d_nlos_cleaned{i,j}(k) = nan;
                end
            end
        end
    end
end

function [rirs, d_nlos_cleaned] = updateWithWall(r, s, rirs, sampleRate, v, d_nlos_cleaned, walls)
    toas = wallToToas(r, s, walls);
    rirs = removePeaksFromRirs(rirs, toas, sampleRate, v, 0.05);
    % d_nlos_cleaned = rirsToCleanDnlos(rirs, sampleRate, v, numPeaks, r, s, d_grd);
    d_nlos_cleaned = removeCloseDistancesFromTdoas(d_nlos_cleaned, toas, 0.05);
end
