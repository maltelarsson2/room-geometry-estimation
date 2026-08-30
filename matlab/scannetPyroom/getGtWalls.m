function [gt_walls] = getGtWalls(R, t, s)
%GETGTWALLS Summary of this function goes here
%   Detailed explanation goes here
gt_walls = roomToWalls(s);
gt_walls(4,:) = gt_walls(4,:)-[s(1), s(1), s(2), s(2), s(3), s(3)]/2;
gt_walls(4,:) = gt_walls(4,:)-t*gt_walls(1:3,:);
gt_walls(1:3,:) = R*gt_walls(1:3,:);
% gt_walls(4,:) = gt_walls(4,:)-t*gt_walls(1:3,:);
end

