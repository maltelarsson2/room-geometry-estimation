function R = getRotationFromA1ToA2AroundAxis(a1, a2, axis)
%GETROTATIONFROMA1TOA2ROUNDAXIS Summary of this function goes here
%   Detailed explanation goes here
omega = axis;
if size(omega,1)==1
    omega = omega';
end
if size(a1,1)==1
    a1 = a1';
end
if size(a2,1)==1
    a2 = a2';
end

a1 = a1/norm(a1);
a2 = a2/norm(a2);
v = cross(a1, a2);

if v'*omega < 0
    omega = -omega;
end
omega = omega/norm(omega);
theta = acos(a1'*a2);

K = [0, -omega(3), omega(2); omega(3), 0, -omega(1); -omega(2), omega(1), 0];
R = eye(3)+sin(theta)*K+(1-cos(theta))*K^2;
end

