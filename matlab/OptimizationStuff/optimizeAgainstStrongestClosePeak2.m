function [planes] = optimizeAgainstStrongestClosePeak2(plane0, r, s, gccScores, gccSettings, allPeaks)
%OPTIMIZEAGAINSTSTRONGESTCLOSEPEAK Summary of this function goes here
%   Detailed explanation goes here
if isequal(size(plane0), [4, 1])
    plane0 = plane0';
end
d_los = pdist2(r', s');
planes = [plane0];
for i = 1:20
    plane = planes(end,:);
    [~, peaksDists] = findStrongestClosePeak3(r, s, plane, gccScores, gccSettings, allPeaks);
    
    options = optimset;
    options.MaxFunEvals = 1000;
    f = @(x) errorFun(r, s, x, peaksDists, d_los);
    plane = fminsearch(f, plane, options);
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
            % error = error + sum(min(abs(peaksDists{i,j}-tdoas), 0.1), "all","omitnan");
        end
    end
end


