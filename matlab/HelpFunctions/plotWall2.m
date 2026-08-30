function plotWall2(wall, boxMin, boxMax, gridStep)
%PLOTWALL Summary of this function goes here
%   Detailed explanation goes here
    grid = boxMin:gridStep:boxMax;
    % [X,Y,Z] = meshgrid(grid,grid,grid);
    % wallVals = wall(1)*X+wall(2)*Y+wall(3)*Z-wall(4);
    % okPoints = abs(wallVals)<0.1; 

    % plot3(X(okPoints), Y(okPoints), Z(okPoints), "b.", "MarkerSize", 1)

    [X,Y] = meshgrid(grid,grid);
    Z = -(wall(1)*X+wall(2)*Y-wall(4))/wall(3);

    % surf(X, Y, Z, 'FaceAlpha',0.3)
    % surf(X, Y, Z, 'FaceAlpha',0.3, EdgeAlpha=0.5)
    surf(X, Y, Z, 'FaceAlpha',0.3, EdgeAlpha=0.5, FaceColor=rand(3, 1))
    

end


