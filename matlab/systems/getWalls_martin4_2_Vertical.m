function [walls, echo_labeling] = getWalls_martin4_2_Vertical(r, s, v, dnlos, threshold, gcc_scores, gccPhatSettings, maxIters, allPeaks)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
warning('off', 'MATLAB:nearlySingularMatrix');
warning('off', 'MATLAB:singularMatrix');

if nargin < 7
    maxIters = 5000;
end

if nargin < 8
    allPeaks = computeClosestStrongPeakMatrix(gcc_scores, 0.01, 0.2, gccPhatSettings);
end


R = getRotationFromVtoN(v, [0;0;1]);
r = R*r;
s = R*s;

walls = [];
iter = 0;
echo_labeling = [];
while true
    iter = iter+1;
    fprintf("%d", iter)
    [wall, inliers] = ransac_plane(r, s, dnlos, maxIters, threshold, gcc_scores, gccPhatSettings, allPeaks);
    if isempty(wall) || size(inliers, 1) < 10 
        break
    else
        dnlos = removeInliers(dnlos, inliers);
        walls = [walls, wall];
        echo_labeling = [echo_labeling, {inliers}];
        break;
    end
end
fprintf("\n")

warning('on', 'MATLAB:nearlySingularMatrix');
warning('on', 'MATLAB:singularMatrix');
walls(1:3,:) = R'*walls(1:3,:);
end

function dnlos = removeInliers(dnlos, inliers)
    for t = 1:size(inliers, 1)
        i = inliers(t, 1);
        j = inliers(t, 2); 
        k = inliers(t, 3);
        dnlos{i,j}(k) = nan;
    end
end

function [plane, best_inliers] = ransac_plane(r, s, dnlos, iters, threshold_distance, gcc_scores, gccPhatSettings, allPeaks)
    if nargin < 4
        iters = 1000;
    end
    if nargin < 5
        threshold_distance=0.2;
    end


    best_plane = [];
    best_inliers = [];
    dynamicIters = iters;
    failed_iterations = 0;
    best_score = -Inf;
    best_score_beforeOpt = -Inf;
    m = size(r, 2);
    n = size(s, 2);
    all_pairs = [];
    for i = 1:m
        for j = 1:n
            if sum(~isnan(dnlos{i,j})) > 0
                all_pairs = [all_pairs; i,j];
            end
        end
    end
    sample_size = 2;

    for iter = 1:iters
        if mod(iter, 100) == 0
            fprintf("%i", iter)
        end
        if size(all_pairs, 1) < sample_size
            break;
        end
        % if iter>dynamicIters
        %     size(best_inliers, 1)
        %     size(all_pairs, 1)
        %     dynamicIters
        %     break;
        % end
        sample_pairs = randperm(size(all_pairs, 1), sample_size);
        rinds = all_pairs(sample_pairs, 1);
        sinds = all_pairs(sample_pairs, 2);
        
        sample_r = r(:, rinds);
        sample_s = s(:, sinds);
        sample_d = zeros(sample_size, 1);
        for k = 1:sample_size
            dnlos_cur = dnlos{rinds(k), sinds(k)};
            ind = getRandomNonNanInd(dnlos_cur);
            sample_d(k) = dnlos_cur(ind);
        end
        candidate_planes = solver_plane_vertical_3d(sample_r, sample_s, sample_d);
        if isempty(candidate_planes)
            failed_iterations = failed_iterations + 1;
        end

        for k = 1:size(candidate_planes,2)
            candidate_plane = candidate_planes(:, k);
            score = scorePlaneFromGcc2(r, s, candidate_plane, gcc_scores, gccPhatSettings);
            doOpt = false;
            if score > best_score_beforeOpt
                best_score_beforeOpt = score;
                doOpt = true;
            end
            if score > best_score %length(inliers) > length(best_inliers) %TODO: maybe not length
                best_plane = candidate_plane;
                inliers = find_inliers(r, s, dnlos, candidate_plane, threshold_distance);
                best_inliers = inliers;
                best_score = score;
                doOpt = true;
                fprintf("\nIter %d\n", iter);
            end
            if doOpt
                fprintf("\nopt, Iter %d\n", iter);
                opt_planes = optimizeAgainstStrongestClosePeak2(candidate_plane, r, s, gcc_scores, gccPhatSettings, allPeaks);
                candidate_plane = opt_planes(end,:)';
                score = scorePlaneFromGcc2(r, s, candidate_plane, gcc_scores, gccPhatSettings);
                if score > best_score %length(inliers) > length(best_inliers) %TODO: maybe not length
                    best_plane = candidate_plane;
                    inliers = find_inliers(r, s, dnlos, candidate_plane, threshold_distance);
                    best_inliers = inliers;
                    best_score = score;
                    fprintf("\nIter %d\n", iter);
                end
            end
            if ~isempty(best_inliers)
                dynamicIters = getDynamicMinIters(best_inliers, size(all_pairs, 1));
            end
        end
    end
    fprintf("\n")

    best_inliers = find_inliers(r, s, dnlos, best_plane, threshold_distance);


    if isempty(best_inliers) 
        % return nothing, best_inliers
        plane = [];
        return
    else
        % return best_plane, best_inliers
        plane = best_plane;
        return
    end
end

function dynamicIters = getDynamicMinIters(inliers, numPoints)
    numInliers = size(inliers, 1);
    dynamicIters = iterationsNeededToFindInlierSet(numInliers, numPoints-numInliers, 3, 0.99);
end

function ind = getRandomNonNanInd(d_ij)
    okInds = find(~isnan(d_ij));
    ind = okInds(randi(length(okInds)));
end

function inliers = find_inliers(r, s, dnlos, plane, threshold)
    m = size(r, 2);
    n = size(s, 2);
    inliers = [];
    for j = 1:n
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
            end
        end
    end
end

