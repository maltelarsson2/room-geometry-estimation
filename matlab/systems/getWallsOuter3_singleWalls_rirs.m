function [allWalls] = getWallsOuter3_singleWalls_rirs(r, s, rirs, sampleRate, v, numPeaks, numWalls)
%GETWALLSOUTER Does not assume parallel or orthogonal conditions.
%   Detailed explanation goes here
d_grd = pdist2(r', s');
rirs = removePeaksFromRirs(rirs, d_grd, sampleRate, v, 0.05);

d_nlos_cleaned = rirsToCleanDnlos(rirs, sampleRate, v, numPeaks, r, s, d_grd);

threshold = 0.05;

allWalls = [];
for i = 1:numWalls
    [walls, ~] = getWalls_martin_noGccScore(r, s, d_nlos_cleaned, threshold, 3000);
    % [walls, ~] = getWalls_martin_rirs(r, s, d_nlos_cleaned, rirs, sampleRate, v, threshold, 10000);
    % [walls, ~] = getWalls_trilat_noGccScore(r, s, d_nlos_cleaned, threshold, 50000);
    if isempty(walls)
        break;
    end
    allWalls = [allWalls, walls];
    % plotInliers(r,s, d_nlos_cleaned, walls, threshold, scores, gccPhatSettings)
    toas = wallToToas(r, s, walls);
    rirs = removePeaksFromRirs(rirs, toas, sampleRate, v, 0.05);
    % d_nlos_cleaned = rirsToCleanDnlos(rirs, sampleRate, v, numPeaks, r, s, d_grd);
    d_nlos_cleaned = removeCloseDistancesFromTdoas(d_nlos_cleaned, toas, 0.05);
end

end

function plotInliers(r,s, d_nlos_cleaned, wall, threshold, scores, settings)
    a = 2;
    b = 3;
    inliers = find_inliers(r,s, d_nlos_cleaned, wall, threshold);
    plotGccScores(scores{b,a}, settings);
    hold on
    for i = 1:size(inliers,1)
        inlier = inliers(i,:);
        if inlier(1) == a
            ind = tdoaToGccInd(d_nlos_cleaned{a,inlier(2)}(inlier(3))-pdist2(r(:, b)', s(:, inlier(2))'), settings, false);
            plot(inlier(2), ind, "b.");
        end
    end
    plotTdoaPathInScore(r, s, wall, a, b, settings, 'm--')

end

function inliers = find_inliers(r, s, dnlos, plane, threshold)
    m = size(r, 2);
    n = size(s, 2);
    inliers = [];
    for j = 1:n
        % reflect_s = reflect(plane, s(:, j)); %TODO - change to correct function
        reflect_s = mirrorPoint3D(s(:, j), plane);

        for i = 1:m
            reflect_d = norm(r(:, i) - reflect_s);
            best_k = -1;
            bestVal = Inf;
            for k = 1:length(dnlos{i, j})
                if abs(reflect_d - dnlos{i, j}(k)) < bestVal
                    bestVal = abs(reflect_d - dnlos{i, j}(k));
                    best_k = k;
                end
            end
            if bestVal < threshold
                inliers = [inliers; i, j, best_k];
            end
        end
    end
end



