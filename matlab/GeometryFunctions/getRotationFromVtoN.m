function R = getRotationFromVtoN(v,n)
%GETWALLPARTIALNORMAL Summary of this function goes here
%   Detailed explanation goes here
if isequal(size(v), [1,3])
    v = v';
end
if isequal(size(n), [1,3])
    n = n';
end
v = v/norm(v);
n = n/norm(n);
omega = cross(v,n);
if isequal(omega, [0,0,0]')
    R = eye(3);
    return;
end
omega = omega/norm(omega);
theta = acos(n'*v);

K = [0, -omega(3), omega(2); omega(3), 0, -omega(1); -omega(2), omega(1), 0];
R = eye(3)+sin(theta)*K+(1-cos(theta))*K^2;
end

