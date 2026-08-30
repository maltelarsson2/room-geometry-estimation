function [newWalls] = optimizeRoom2(r, s, allPeaks, walls, gccScores, gccSettings)
%OPTIMIZEROOM Summary of this function goes here
%   Detailed explanation goes here
d_los = pdist2(r', s');
curWalls = setOrientationOnWalls(walls);
for i = 1:20
    all_peaksDists = cell(1, 6);
    for j = 1:6
        [~, all_peaksDists{j}] = findStrongestClosePeak3(r, s, curWalls(:, j), gccScores, gccSettings, allPeaks);
    end
    f = @(x) roomErrorFunction(x(1:3), x(4:6), x(7:end), r, s, all_peaksDists, d_los);
    startPoint = [curWalls(1:3,1); curWalls(1:3,3); curWalls(4,:)'];
    nextPoint = fminsearch(f, startPoint);
    curWalls = createWallsFromStuff(nextPoint(1:3), nextPoint(4:6), nextPoint(7:end));
end
newWalls = curWalls;
end

function walls = setOrientationOnWalls(walls)
    n1 = walls(1:3, 1);
    if walls(1:3,2)'*n1 < 0
        walls(:, 2) = -walls(:, 2);
    end
    n2 = walls(1:3, 3);
    if walls(1:3,4)'*n2 < 0
        walls(:, 4) = -walls(:, 4);
    end
    n3 = cross(n1, n2);
    if walls(1:3,5)'*n3 < 0
        walls(:, 5) = -walls(:, 5);
    end
    if walls(1:3,6)'*n3 < 0
        walls(:, 6) = -walls(:, 6);
    end
    
end


function error = roomErrorFunction(n, n2, wallShifts, r, s, all_peaksDists, d_los) %should use better rotation representation
    walls = createWallsFromStuff(n, n2, wallShifts);
    error = 0;
    for i = 1:6
        error = error + errorFun(r, s, walls(:, i), all_peaksDists{i}, d_los);
    end
end

function walls = createWallsFromStuff(n, n2, wallShifts)
    R1 = getRotationFromVtoN([1,0,0], n);
    R2 = getRotationFromA1ToA2AroundAxis(R1*[0,1,0]', n2, n); %rotation to match up wall 2
    R = R2*R1; %Or the other way around?
    walls = [1,0,0,wallShifts(1);
        1,0,0,wallShifts(2);
        0,1,0,wallShifts(3);
        0,1,0,wallShifts(4);
        0,0,1,wallShifts(5);
        0,0,1,wallShifts(6)]';
    walls(1:3,:) = R*walls(1:3,:);

end

function error = errorFun(r, s, plane, peaksDists, d_los)
    error = 0;
    r_mirrors = mirrorPoint3D(r, plane);
    d_mirrored = pdist2(r_mirrors', s');
    for i = 1:size(r, 2)
        for j = i+1:size(r, 2)
            tdoas = -getTdoasForPlane(r, s, plane, i, j, d_los, d_mirrored);
            % error = error + sum((peaksDists{j,i}-tdoas).^2, "all","omitnan");
            % error = error + sum(abs(peaksDists{i,j}-tdoas), "all","omitnan");
            error = error + sum(min(abs(peaksDists{i,j}-tdoas), 0.1), "all","omitnan");
        end
    end
end


