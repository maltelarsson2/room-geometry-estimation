function [allWalls] = getWallsOuter3_singleWalls(r, s, r_ref, gcc_scores, gccPhatSettings, numWalls, allPeaks)
%GETWALLSOUTER Does not assume parallel or orthogonal conditions.
%   Detailed explanation goes here
if nargin < 7
    allPeaks = computeClosestStrongPeakMatrix(gcc_scores, 0.01, 0.2, gccPhatSettings);
end
d_grd = pdist2(r', s');
scores = gcc_scores;
% d_nlos_cleaned = scoresToCleanDnlos(scores, gccPhatSettings, r, s, d_grd, r_ref);
d_nlos_cleaned = scoresToCleanDnlos2(scores, gccPhatSettings, r, s, d_grd);

allWalls = [];
for i = 1:numWalls
    [walls, ~] = getWalls_martin4_2(r, s, d_nlos_cleaned, 0.05, scores, gccPhatSettings, 4000);
    % [walls, ~] = getWalls_martin_noGccScore(r, s, d_nlos_cleaned, 0.05, 2000);
    % [walls, ~] = getWalls_trilat4_2(r, s, d_nlos_cleaned, 0.05, scores, gccPhatSettings, 2000);
    % [walls, ~] = getWalls_martin4_3(r, s, d_nlos_cleaned, 0.05, scores, gccPhatSettings, 1000);
    if isempty(walls)
        break;
    end
    allWalls = [allWalls, walls];
    
    scores = removeUsedGccScores(scores, r, s, allWalls(:,i), gccPhatSettings);
    % d_nlos_cleaned = scoresToCleanDnlos(scores, gccPhatSettings, r, s, d_grd, r_ref);
    d_nlos_cleaned = scoresToCleanDnlos2(scores, gccPhatSettings, r, s, d_grd);

end



end

