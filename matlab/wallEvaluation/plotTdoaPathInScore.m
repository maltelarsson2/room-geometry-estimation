function plotTdoaPathInScore(r, s, plane, i, j, settings, color, colorRGB)
    tdoas = getTdoasForPlane(r, s, plane, i, j);
    inds = tdoaToGccInd(tdoas, settings);
    if nargin < 7
        plot(1:size(s, 2), inds)
    elseif nargin < 8
        numLines = 3;
        if isempty(plane)
            numLines = 1;
        end
        plot(1:size(s, 2), inds(1:numLines,:), color)
    else
        % plot(1:size(s, 2), ind(2:4,:), Color=colorRGB, Marker=".", LineStyle='none')
        plot(1:size(s, 2), inds, Color=colorRGB, LineStyle='-')
    end
end

