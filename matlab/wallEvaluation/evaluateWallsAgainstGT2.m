function [rotationErrors, translationErrors] = evaluateWallsAgainstGT2(walls, walls_gt, sort)
%EVALUATEWALLSAGAINSTGT Summary of this function goes here
%   Detailed explanation goes here
walls = walls./vecnorm(walls(1:3,:));
walls_gt = walls_gt./vecnorm(walls_gt(1:3,:));
initial_walls = walls;
numWalls = min(size(walls, 2), size(walls_gt, 2));
sortedWalls = zeros(4, numWalls);
sortedWalls_gt = zeros(4, numWalls);

for i = 1:numWalls
    [ii, jj, flip] = findBestWallPair(walls, walls_gt);
    if flip
        sortedWalls(:, i) = -walls(:, ii);
    else
        sortedWalls(:, i) = walls(:, ii);
    end
   
    sortedWalls_gt(:, i) = walls_gt(:, jj);
    walls = walls(:, [1:ii-1, ii+1:end]);
    walls_gt = walls_gt(:, [1:jj-1, jj+1:end]);
end
rotationErrors = [];
translationErrors = [];
for i = 1:numWalls
    v = acos(sortedWalls_gt(1:3, i)'*sortedWalls(1:3, i));
    rotationErrors = [rotationErrors, v];
    translationErrors = [translationErrors, sortedWalls_gt(4, i)-sortedWalls(4, i)];
end

numLeft = size(initial_walls, 2)-numWalls;
sortedWalls = [sortedWalls, walls];
rotationErrors = [rotationErrors, nan(1, numLeft)];
translationErrors = [translationErrors, nan(1, numLeft)];

rotationErrors = 180/pi*rotationErrors;
sortorder = zeros(1,size(initial_walls, 2));
for i = 1:size(initial_walls, 2)
    ind = getIndexOfWall(sortedWalls(:, i), initial_walls);
    sortorder(ind) = i;
end
if sort
    rotationErrors = rotationErrors(sortorder);
    translationErrors = translationErrors(sortorder);
end
end

%This should probably be some better error
function [error, flip] = errorWallToWall(wall1, wall2)
    error = sqrt(sum((wall1-wall2).^2));
    err2 = sqrt(sum((wall1+wall2).^2));
    flip = false;
    if err2 < error
        error = err2;
        flip = true;
    end
end

function [error, flip] = errorWallToWall2(wall1, wall2)
    err = sum((wall1(1:3)-wall2(1:3)).^2);
    err2 = sum((wall1(1:3)+wall2(1:3)).^2);
    flip = false;
    if err2 < err
        flip = true;
    end
    if flip
        error = sum((wall1+wall2).^2);
    else
        error = sum((wall1-wall2).^2);
    end
end


function [ii, jj, flip] = findBestWallPair(walls1, walls2)

minErr = Inf;
ii = -1;
jj = -1;
flip = false;
for i = 1:size(walls1, 2)
    for j= 1:size(walls2, 2)
        [err, shouldFlip] = errorWallToWall2(walls1(:, i), walls2(:, j));
        if err < minErr
            minErr = err;
            ii = i;
            jj = j;
            flip = shouldFlip;
        end
    end
end

 
end

function ind =  getIndexOfWall(wall, originalWalls)
    for i = 1:size(originalWalls, 2)
        if min(norm(wall-originalWalls(:, i)),norm(wall+originalWalls(:, i))) < 0.00001
            ind = i;
            break;
        end
    end
end

