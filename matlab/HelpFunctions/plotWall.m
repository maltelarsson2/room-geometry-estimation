function plotWall(wall)
%PLOTWALL Summary of this function goes here
%   Detailed explanation goes here
    swapX = false;
    swapY = false;
    if(abs(wall(3)) < 1e-1)
        if(abs(wall(2)) < 1e-1)
            swapX = true;
        else
            swapY = true;
        end
    end
    if swapX
        temp = wall(1);
        wall(1) = wall(3);
        wall(3) = temp;
    elseif swapY
        temp = wall(2);
        wall(2) = wall(3);
        wall(3) = temp;
    end
    [X, Y] = meshgrid(-2:0.1:2, -2:0.1:2);
    Z = (wall(4)-wall(1)*X-wall(2)*Y)/wall(3);
        if swapX
            temp = X;
            X = Z;
            Z = temp;
        elseif swapY
            temp = Y;
            Y = Z;
            Z = temp;
        end
    plot3(X, Y, Z, "b.")
end


