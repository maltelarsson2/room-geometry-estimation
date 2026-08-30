function [toas] = wallToToas(r, s, wall)
%WALLTOTOAS Summary of this function goes here
%   Detailed explanation goes here
r_mirrored = mirrorPoint3D(r, wall);
toas = pdist2(r_mirrored', s');
end

