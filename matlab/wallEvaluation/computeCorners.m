function [corners] = computeCorners(walls)
%COMPUTECORNERS Assumes walls are arranged as p11,p12, p21,p22, p31, p32,
%where px1 is parallel to px2
corners = [];
for i = 1:2
    for j = 3:4
        for k = 5:6
            corner = walls(1:3, [i,j,k])'\walls(4, [i,j,k])';
            corners = [corners, corner];
        end
    end
end

end

