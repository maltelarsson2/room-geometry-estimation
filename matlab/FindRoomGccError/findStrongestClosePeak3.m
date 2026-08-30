function [peaksInd, peaksDists] = findStrongestClosePeak3(r,s, plane, gccScores, gccSettings, allPeaks)
%FINDSTRONGESTCLOSEPEAK Summary of this function goes here
%   Detailed explanation goes here

peaksInd = cell(size(gccScores));
peaksDists = cell(size(gccScores));
d_los = pdist2(r',s');
r_mirrors = mirrorPoint3D(r, plane);
d_mirrored = pdist2(r_mirrors', s');
for i = 1:size(gccScores, 1)
    for j = 1:size(gccScores, 2)
        tdoas = getTdoasForPlane(r, s, plane, i, j, d_los, d_mirrored);
        for k = 1:3
            inds = findStrongestClosePeakInner(-tdoas(k,:), gccSettings, allPeaks{i,j});
            peaksInd{i,j} = [peaksInd{i,j}; inds];
            peaksDists{i,j} = [peaksDists{i,j}; (inds-gccSettings.sw-1)*gccSettings.v/gccSettings.sr];

        end
    end
end
end

function peakInds = findStrongestClosePeakInner(tdoas, gccSettings, peakMatrix)
    inds = tdoaToGccInd(tdoas, gccSettings, true);
    inds(inds>size(peakMatrix,1)) = nan;
    inds(inds<1) = nan;
    subInds = sub2ind(size(peakMatrix), inds, 1:size(peakMatrix, 2));
    nanInds = isnan(subInds);
    subInds(nanInds) = 1;
    peakInds = peakMatrix(subInds);
    peakInds(nanInds) = nan;
end

