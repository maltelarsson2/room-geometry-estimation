function [r, s, times, room] = readDataFromFiles(foldername, is_scannet_room)
%READDATAFROMFILES Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    is_scannet_room = false;
end
r = readmatrix(foldername + "receivers.txt");
if size(r, 2) == 3
    r = r';
end
s = readmatrix(foldername + "senders.txt");
if size(s, 2) == 3
    s = s';
end
times = readmatrix(foldername + "times.txt");
if is_scannet_room
    temp_data = load(foldername + "room.mat");
    room = temp_data.gt_walls;
else
    room = readmatrix(foldername + "room.txt");
end
end


