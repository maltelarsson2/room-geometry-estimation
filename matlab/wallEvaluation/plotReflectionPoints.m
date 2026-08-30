function plotReflectionPoints(r, s, wall, color)
%PLOTREFLECTIONPOINTS Summary of this function goes here
%   Detailed explanation goes here

mirror_r = mirrorPoint3D(r, wall);
m = size(r, 2);
n = size(s, 2);
points = zeros(3, m*n);
ind = 1;
for i = 1:m
    for j = 1:n
        points(:, ind) = intersectLineAndPlane(mirror_r(:,i), s(:, j), wall);
        ind = ind+1;
    end
end
plot3(points(1,:), points(2, :), points(3, :), color);

end

function p = intersectLineAndPlane(p1, p2, wall)
    t = (wall(4)-wall(1:3)'*p1)/(wall(1:3)'*(p2-p1));
    p = p1+t*(p2-p1);
end