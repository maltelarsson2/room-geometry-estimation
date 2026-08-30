function [inliers, inlierDistances] = find_inliers(r, s, dnlos, plane, threshold)
    m = size(r, 2);
    n = size(s, 2);
    inliers = [];
    inlierDistances = nan(m, n);
    for j = 1:n
        % reflect_s = reflect(plane, s(:, j)); %TODO - change to correct function
        reflect_s = mirrorPoint3D(s(:, j), plane);

        for i = 1:m
            reflect_d = norm(r(:, i) - reflect_s);
            best_k = -1;
            bestVal = Inf;
            for k = 1:length(dnlos{i, j})
                if abs(reflect_d - dnlos{i, j}(k)) < bestVal
                    bestVal = abs(reflect_d - dnlos{i, j}(k));
                    best_k = k;
                end
            end
            if bestVal < threshold
                inliers = [inliers; i, j, best_k];
                inlierDistances(i, j) = dnlos{i, j}(best_k);
            end
        end
    end
end


