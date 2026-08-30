function [score] = scorePlaneFromGcc2(r, s, plane, gcc_scores, gccPhatSettings)
%SCOREPLANEFROMGCC Summary of this function goes here
%   Detailed explanation goes here

score = 0;
r_mirrors = mirrorPoint3D(r, plane);
d_mirrored = pdist2(r_mirrors', s');
d_los = pdist2(r', s');
nbr_receivers = size(r, 2);
nbr_senders = size(s, 2);
% numVals = 0;
for i = 1:nbr_receivers
    for j = i+1:nbr_receivers
        gcc_score = gcc_scores{j,i};
        
        % gcc_score = max(gcc_score, 0);

        tdoas = zeros(4, nbr_senders);
        tdoas(1,:) = d_los(i,:)-d_los(j,:);
        tdoas(2,:) = d_mirrored(i,:)-d_los(j,:);
        tdoas(3,:) = d_los(i,:)-d_mirrored(j,:);
        tdoas(4,:) = d_mirrored(i,:)-d_mirrored(j,:);
        
        for k = 1:4
            for l = k+1:4
                tdiff = tdoas(k,:)-tdoas(l,:);
                % tdoas(l,abs(tdiff)< 0.05) = nan;
                tdoas(l,abs(tdiff)< 0.1) = nan;
            end
        end

        
        gccInd = tdoaToGccInd(tdoas, gccPhatSettings, false);
        
        % gccInd(gccInd > size(gcc_score, 1)) = size(gcc_score, 1);
        % gccInd(gccInd < 1) = 1;
        
        gccInd(gccInd > size(gcc_score, 1)) = nan;
        gccInd(gccInd < 1) = nan;


        gccInd = sub2ind(size(gcc_score), gccInd, repmat(1:nbr_senders, [size(gccInd,1), 1]));
        gccInd = gccInd(~isnan(gccInd));
        floorInd = floor(gccInd);
        ceilInd = ceil(gccInd);
        score = score + sum((ceilInd-gccInd).*gcc_score(floorInd) + (gccInd-floorInd).*gcc_score(ceilInd), 'all');
        % score = score + sum(gcc_score(gccInd), 'all');
        % numVals = numVals + numel(gcc_score(floorInd));
    end
end


score = double(score);
% score = score/numVals;

end

