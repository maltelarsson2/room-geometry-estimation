function [planes] = optimizeAgainstStrongestClosePeak3(plane0, r, s, gccScores, gccSettings, allPeaks)
%OPTIMIZEAGAINSTSTRONGESTCLOSEPEAK Summary of this function goes here
%   Detailed explanation goes here
if isequal(size(plane0), [4, 1])
    plane0 = plane0';
end
numR = size(r, 2);
numS = size(s, 2);
d_los = pdist2(r', s');
planes = [plane0/norm(plane0(1:3))];
for i = 1:30
    plane = planes(end,:);
    [~, peaksDists] = findStrongestClosePeak3(r, s, plane, gccScores, gccSettings, allPeaks);
    
    options = optimset;
    options.MaxFunEvals = 1000000;
    tdoas1 = zeros(numR, numS*numR);
    tdoas2 = zeros(numR, numS*numR);
    tdoas3 = zeros(numR, numS*numR);
    for a = 1:numR
        for b = 1:numR
            tdoas1(a, (b-1)*numS+1:b*numS) = peaksDists{a,b}(1,:);
            tdoas2(a, (b-1)*numS+1:b*numS) = peaksDists{a,b}(2,:);
            tdoas3(a, (b-1)*numS+1:b*numS) = peaksDists{a,b}(3,:);
        end
    end
    % f = @(x) errorFun(r, s, x, peaksDists, d_los);
    % f = @(x) errorFun2(r, s, x, peaksDists, peaksInds, gccScores);
    plane = optimizePlane2(r, s, planes(end,:), tdoas1, tdoas2, tdoas3);
    plane = plane/norm(plane(1:3));
    planes = [planes; plane];
    if norm(planes(end,:)-planes(end-1,:)) < 1e-4
        break
    end
end


end

function error = errorFun(r, s, plane, peaksDists, d_los)
    error = 0;
    r_mirrors = mirrorPoint3D(r, plane);
    d_mirrored = pdist2(r_mirrors', s');
    for i = 1:size(r, 2)
        for j = i+1:size(r, 2)
            tdoas = -getTdoasForPlane(r, s, plane, i, j, d_los, d_mirrored);
            % error = error + sum((peaksDists{j,i}-tdoas).^2, "all","omitnan");
            error = error + sum(abs(peaksDists{i,j}-tdoas), "all","omitnan");
        end
    end
end

function error = errorFun2(r, s, plane, peaksDists, peaksInds, scores)
    error = 0;
    for i = 1:size(r, 2)
        for j = i+1:size(r, 2)
            score = scores{j,i};
            tdoas = getTdoasForPlane(r, s, plane, i, j);
            pInds = peaksInds{j,i};
            pInds(pInds<1) = nan;%1;
            pInds(pInds > size(score, 1)) = nan;%size(score1, 1);
            % error = error + sum((peaksDists{j,i}-tdoas).^2, "all","omitnan");
            inds = sub2ind(size(score), pInds, repmat(1:size(score, 2), [3, 1]));
            nanInds = isnan(inds);
            inds(nanInds) = 1;
            posScores = score(inds);
            posScores(nanInds) = nan;
            error = error + sum(posScores.*abs(peaksDists{j,i}-tdoas), "all","omitnan");
        end
    end
end

