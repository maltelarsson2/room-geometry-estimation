function tdoas = getTdoasForPlane(r, s, plane, i, j, d_los, d_mirrored)
    if nargin < 6
        d_los = pdist2(r', s');
    end
    if isempty(plane)
        tdoas = d_los(i,:)-d_los(j,:);
        return
    end
    if nargin < 7
        r_mirrors = mirrorPoint3D(r, plane);
        d_mirrored = pdist2(r_mirrors', s');
    end
    nbr_senders = size(s, 2);
    tdoas = zeros(3, nbr_senders);
    tdoas(1,:) = d_mirrored(i,:)-d_los(j,:);
    tdoas(2,:) = d_los(i,:)-d_mirrored(j,:);
    tdoas(3,:) = d_mirrored(i,:)-d_mirrored(j,:);
    
end
