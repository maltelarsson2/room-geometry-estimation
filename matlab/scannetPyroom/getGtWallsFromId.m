function [gt_walls] = getGtWallsFromId(room_id)
%GETGTWALLSFROMID Summary of this function goes here
%   Detailed explanation goes here
[R, t, s] = getGtCuboid(room_id);
gt_walls = getGtWalls(R, t, s);
end

