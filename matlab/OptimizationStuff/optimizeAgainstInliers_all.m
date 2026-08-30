function [plane] = optimizeAgainstInliers_all(plane0, r, s, d_nlos, threshold)
%OPTIMIZEAGAINSTSTRONGESTCLOSEPEAK Summary of this function goes here
%   Detailed explanation goes here
if isequal(size(plane0), [4, 1])
    plane0 = plane0';
end
plane0 = plane0/norm(plane0(1:3));


options = optimset;
options.Display = 'none';
options.MaxFunEvals = 1000;
f = @(x) errorFun2(r, s, x, d_nlos, threshold);
plane = fminsearch(f, plane0, options);
% plane = fminunc(f, plane, options);

plane = plane/norm(plane(1:3));


end

function error = errorFun(r, s, plane, d_nlos, inliers)
    error = 0;
    r_mirrors = mirrorPoint3D(r, plane);
    d_mirrored = pdist2(r_mirrors', s');
    for i = 1:size(inliers, 1)
        r_ind = inliers(i, 1);
        s_ind = inliers(i, 2);
        d_ind = inliers(i, 3);
        % error = error + (d_mirrored(r_ind, s_ind) - d_nlos{r_ind, s_ind}(d_ind))^2;
        error = error + abs(d_mirrored(r_ind, s_ind) - d_nlos{r_ind, s_ind}(d_ind));
    end
end

function error = errorFun2(r, s, plane, d_nlos, threshold)
    error = 0;
    r_mirrors = mirrorPoint3D(r, plane);
    d_mirrored = pdist2(r_mirrors', s');
    for r_ind = 1:size(d_nlos, 1)
        for s_ind = 1:size(d_nlos, 2)
            reflect_d = d_mirrored(r_ind, s_ind);
            hi_ind = binarySearch(d_nlos{r_ind, s_ind}, reflect_d+threshold);
            lo_ind = binarySearch(d_nlos{r_ind, s_ind}, reflect_d-threshold);
            for d_ind = lo_ind:(hi_ind-1)
                error = error + (reflect_d - d_nlos{r_ind, s_ind}(d_ind))^2;
                % error = error + abs(d_mirrored(r_ind, s_ind) - d_nlos{r_ind, s_ind}(d_ind));
            end
            error = error + (length(d_nlos{r_ind, s_ind})-(hi_ind-lo_ind))*threshold^2;
        end
    end
end


function inliers = find_inliers(r, s, dnlos, plane, threshold)
    m = size(r, 2);
    n = size(s, 2);
    inliers = [];
    for j = 1:n
        % reflect_s = reflect(plane, s(:, j)); %TODO - change to correct function
        reflect_s = mirrorPoint3D(s(:, j), plane);

        for i = 1:m
            reflect_d = norm(r(:, i) - reflect_s);
            for k = 1:length(dnlos{i, j})
                if abs(reflect_d - dnlos{i, j}(k)) < threshold
                    inliers = [inliers; i, j, k];
                end
            end
        end
    end
end


