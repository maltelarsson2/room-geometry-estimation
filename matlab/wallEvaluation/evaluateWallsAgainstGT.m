function [rotationErrors, translationErrors, sortedWalls] = evaluateWallsAgainstGT(walls, walls_gt)
%EVALUATEWALLSAGAINSTGT Summary of this function goes here
%   Detailed explanation goes here
walls = walls./vecnorm(walls(1:3,:));
walls_gt = walls_gt./vecnorm(walls_gt(1:3,:));

sortedWalls = zeros(size(walls));
sortedWalls_gt = zeros(size(walls));
numWalls = min(size(walls, 2), size(walls_gt, 2));
% sortorder = zeros(1,numWalls);
for i = 1:numWalls
    [ii, jj, flip] = findBestWallPair(walls, walls_gt);
    if ii == -1
        continue;
    end
    if flip
        sortedWalls(:, i) = -walls(:, ii);
    else
        sortedWalls(:, i) = walls(:, ii);
    end
   
    sortedWalls_gt(:, i) = walls_gt(:, jj);
    walls = walls(:, [1:ii-1, ii+1:end]);
    walls_gt = walls_gt(:, [1:jj-1, jj+1:end]);
    % sortorder(ii) = i;
end
rotationErrors = [];
translationErrors = [];
for i = 1:numWalls
    v = acos(sortedWalls_gt(1:3, i)'*sortedWalls(1:3, i));
    % if imag(v)~=0
    %     warning("non-real angle: %d", v);
    % end
    v = real(v);
    rotationErrors = [rotationErrors, v];
    translationErrors = [translationErrors, sortedWalls_gt(4, i)-sortedWalls(4, i)];
end

rotationErrors = 180/pi*rotationErrors;

% rotationErrors(sortorder) = rotationErrors;
% translationErrors(sortorder) = translationErrors;

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