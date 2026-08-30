function [errors] = evaluateCornersAgainstGT(walls, walls_gt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

corners = computeAllCorners(walls);
corners_gt = computeAllCorners(walls_gt);

errors = zeros(1, 6);
for i = 1:6
    bestErr = Inf;
    ind = -1;
    for j = 1:size(corners_gt, 2)
        dist = pdist2(corners(:, i)', corners_gt(:,j)');
        if dist < bestErr
            bestErr = dist;
            ind = j;
        end
    end
    errors(i) = bestErr;
    corners_gt = [corners_gt(:, 1:ind-1), corners_gt(:, ind+1:end)];
end

end


function corners = computeAllCorners(walls)
    corners = zeros(3, 6);
    curPos = 1;
    for i = 1:2
        for j = 3:4
            for k = 5:6
                corners(:, curPos) = computeCorner(walls(:, i), walls(:, j), walls(:, k));
                curPos = curPos + 1;
            end
        end
    end
end

function corner = computeCorner(wall1, wall2, wall3)
    A = [wall1(1:3)';wall2(1:3)';wall3(1:3)'];
    b = [wall1(4); wall2(4); wall3(4)];
    corner = A\b;
end
