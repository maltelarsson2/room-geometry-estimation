function [planes] = solver_plane_known_normal(r, s, dnlos, n)
%SOLVER_PLANE_KNOWN_NORMAL Summary of this function goes here
%   Detailed explanation goes here

n = n/norm(n);

d = pdist2(r', s');
rn = r'*n;
sn = s'*n;
q = (d^2-dnlos^2)/4+rn*sn;
p = -(rn+sn);


if p^2/4-q < 0
    planes = [];
    return;
end
k1 = -p/2-sqrt(p^2/4-q);
k2 = -p/2+sqrt(p^2/4-q);
planes = [n, n; k1, k2];



end

