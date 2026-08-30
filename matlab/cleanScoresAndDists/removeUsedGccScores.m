function cleaned_scores = removeUsedGccScores(scores, r, s, plane, gccPhatSettings, removeZeros, removeLos)
    if nargin < 6
        removeZeros = false;
    end
    if nargin < 7
        removeLos = false;
    end
    howMuchToRemove = 10; %30
    cleaned_scores = scores;
    for i = 1:size(cleaned_scores, 1)
        for j = 1:size(cleaned_scores, 2)
            if i == j
                % continue
            end
            cleaned_score = cleaned_scores{j,i};
            if ~isempty(plane)
                cleaned_score = remove_used_score(cleaned_score, r, s, plane, i, j, gccPhatSettings, howMuchToRemove);
            end
            if removeZeros
                cleaned_score = remove_zeros(cleaned_score, gccPhatSettings, howMuchToRemove);
            end
            if removeLos
                cleaned_score = remove_los(cleaned_score, r, s, i, j, gccPhatSettings, howMuchToRemove);
            end
            cleaned_scores{j, i} = cleaned_score;
        end
    end
end

function clean_score = remove_zeros(score, gccPhatSettings, howMuchToRemove)
    clean_score = score;
    inds = tdoaToGccInd(zeros(1, size(score,2)), gccPhatSettings);
    for k = -howMuchToRemove:howMuchToRemove
        gccInd = inds+k;
        gccInd = capInds(gccInd, score);
        gccInd = sub2ind(size(score), gccInd, repmat(1:size(gccInd, 2), [size(gccInd,1), 1]));
        gccInd = gccInd(~isnan(gccInd));
        clean_score(gccInd) = 0;
    end

end

function clean_score = remove_los(score, r, s, i, j, gccPhatSettings, howMuchToRemove)
    clean_score = score;
    tdoas = getTdoasForPlane(r, s, [0,0,1,0], i, j);
    inds = tdoaToGccInd(tdoas, gccPhatSettings);
    inds = inds(1,:);
    for k = -howMuchToRemove:howMuchToRemove
        gccInd = inds+k;
        gccInd = capInds(gccInd, score);
        gccInd = sub2ind(size(score), gccInd, repmat(1:size(gccInd, 2), [size(gccInd,1), 1]));
        gccInd = gccInd(~isnan(gccInd));
        clean_score(gccInd) = 0;
    end
end

function clean_score = remove_used_score(score, r, s, plane, i, j, gccPhatSettings, howMuchToRemove)
    clean_score = score;
    tdoas = getTdoasForPlane(r, s, plane, i, j);
    inds = tdoaToGccInd(tdoas, gccPhatSettings);
    for k = -howMuchToRemove:howMuchToRemove
        gccInd = inds+k;
        gccInd = capInds(gccInd, score);
        gccInd = sub2ind(size(score), gccInd, repmat(1:size(gccInd, 2), [size(gccInd,1), 1]));
        gccInd = gccInd(~isnan(gccInd));
        clean_score(gccInd) = 0;
    end
end

function tdoas = getTdoasForPlane(r, s, plane, i, j)
    d_los = pdist2(r', s');
    nbr_receivers = size(r, 2);
    nbr_senders = size(s, 2);
    if isempty(plane)
        tdoas = d_los(i,:)-d_los(j,:); 
    else
        r_mirrors = mirrorPoint3D(r, plane);
        d_mirrored = pdist2(r_mirrors', s');

        tdoas = zeros(4, nbr_senders);
        tdoas(1,:) = d_los(i,:)-d_los(j,:); 
        tdoas(2,:) = d_mirrored(i,:)-d_los(j,:);
        tdoas(3,:) = d_los(i,:)-d_mirrored(j,:);
        tdoas(4,:) = d_mirrored(i,:)-d_mirrored(j,:);
    end

end

function inds = capInds(inds, gcc_score)
    inds(inds > size(gcc_score, 1)) = size(gcc_score, 1);
    inds(inds < 1) = 1;
end

