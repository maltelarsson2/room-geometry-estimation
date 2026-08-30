function mirroredPoints = mirrorPoint3D(points, plane)
% Mirrors the 3d-points in points (3xn), in the plane. plane is assumed to have 4
% values corresponding to a, b, c and k in ax+by+cz=k.
    mirroredPoints = zeros(size(points));
    a = plane(1);
    b = plane(2);
    c = plane(3);
    k = plane(4);
    for i = 1:size(points, 2)
        r1 = points(1, i);
        r2 = points(2, i);
        r3 = points(3, i);
        coeff = 2*(a*r1+b*r2+c*r3-k)/(a^2+b^2+c^2);
        mirroredPoints(:, i) = points(:, i)-coeff*[a, b, c]';
    end
end