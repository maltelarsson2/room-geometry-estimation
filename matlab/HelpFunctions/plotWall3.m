function plotWall3(walls, corner0, corner1, numPoints)
%PLOTWALL Summary of this function goes here
%   Detailed explanation goes here
    points = rand(3, numPoints);
    points = (corner1-corner0).*points+corner0;
    okPoints = false(1, numPoints);
    for i = 1:size(walls, 2)
        okPoints = okPoints | abs(walls(1:3,i)'*points-walls(4,i))<0.01; 
    end

    plot3(points(1, okPoints), points(2, okPoints), points(3, okPoints), "b.", "MarkerSize", 3)
end


