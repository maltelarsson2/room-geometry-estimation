function plotWalls_corners2(walls, walls_gt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

show_face = true;
if ~isempty(walls_gt)
    corners_gt = computeCorners(walls_gt);
    plot_outline(corners_gt);
    hold on
end
if ~isempty(walls)
    corners = computeCorners(walls);
    plotStuff(corners, [1,2,3,4], show_face);
    hold on
    plotStuff(corners, [1,3,5,7], show_face);
    plotStuff(corners, [2, 4, 6, 8], show_face);
    plotStuff(corners, [1,2, 5, 6], show_face);
    plotStuff(corners, [3, 4, 7, 8], show_face);
    plotStuff(corners, [7, 8, 5, 6], show_face);
end
end


function plotStuff(corners, inds, show_face)
    corners = corners(:, inds);
    X = [corners(1,1), corners(1,2); corners(1,3), corners(1,4)];
    Y = [corners(2,1), corners(2,2); corners(2,3), corners(2,4)];
    Z = [corners(3,1), corners(3,2); corners(3,3), corners(3,4)];
    % c = zeros(2, 2, 3);
    % c(:,:, 3) = 1;
    c = 1*ones(2,2);

    % surf(X,Y,Z, c, 'FaceAlpha',0.2);
    c = rand(3, 1);
    if show_face
        surf(X,Y,Z, 'FaceAlpha',0.2, "FaceColor", c);
    else
        surf(X,Y,Z, 'FaceAlpha',0, "FaceColor", c, "LineStyle","--");
    end
end

function plot_outline(corners)
    inds = [1, 2;
        1, 3;
        1, 5;
        2, 4;
        2, 6;
        3, 4;
        3, 7;
        4, 8;
        5, 6;
        5, 7;
        6, 8;
        7, 8];
    for i = 1:12
        plot3(corners(1, inds(i,:)), corners(2, inds(i,:)), corners(3, inds(i,:)), "k--");
    end
end
