function d = removeTdoasShorterThanLos(d_nlos, dists) 
numRemoved = 0;
d = cell(size(d_nlos));
    for i = 1:size(d_nlos, 1)
        for j = 1:size(d_nlos, 2)
            curList = d_nlos{i,j};
            for k = 1:length(curList)
                if curList(k) < dists(i,j)
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
