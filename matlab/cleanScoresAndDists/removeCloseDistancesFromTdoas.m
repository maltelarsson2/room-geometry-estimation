function d = removeCloseDistancesFromTdoas(d_nlos, dists, threshold) 
numRemoved = 0;
d = cell(size(d_nlos));
    for i = 1:size(d_nlos, 1)
        for j = 1:size(d_nlos, 2)
            curList = d_nlos{i,j};
            for k = 1:length(curList)
                if abs(curList(k) -dists(i,j)) < threshold
                    curList(k) = nan;
                    numRemoved = numRemoved+1;
                end
            end
            curList = curList(~isnan(curList));
            d{i,j} = curList;
        end
    end
% numRemoved
end
