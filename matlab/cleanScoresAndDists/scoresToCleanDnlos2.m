function [d_nlos_cleaned] = scoresToCleanDnlos2(scores, gccPhatSettings, r, s, d_grd)
%SCORESTOCLEANDNLOS Summary of this function goes here
%   Detailed explanation goes here
if nargin < 5
    d_grd = pdist2(r',s');
end

scores = removeUsedGccScores(scores, r, s, [], gccPhatSettings, true, true);
% u(i,j) has j-i
u = getdelays(scores, gccPhatSettings);
d_nlos_cleaned = uToD(u, d_grd, gccPhatSettings.v, gccPhatSettings.sr);
d_nlos_cleaned = removeCloseDistancesFromTdoas(d_nlos_cleaned, d_grd, 0.05);
d_nlos_cleaned = removeTdoasShorterThanLos(d_nlos_cleaned, d_grd); 
d_nlos_cleaned = sort_dnlos(d_nlos_cleaned);
end

function d_nlos = uToD(u, d_grd, v, sampleRate)
    d_nlos = cell(size(d_grd));
    for i = 1:size(u,1)
        for j = 1:size(u,2)
            if i == j
                continue
            end
            u_cur = u{i,j}*v/sampleRate;
            for s_ind = 1:size(u_cur, 2)
                d_nlos{j,s_ind} = [d_nlos{j,s_ind}; u_cur(:, s_ind) + d_grd(i,s_ind)];
            end

        end
    end

end

function d_nlos = sort_dnlos(d_nlos)
    for i = 1:size(d_nlos, 1)
        for j = 1:size(d_nlos, 2)
            d_nlos{i,j} = sort(d_nlos{i,j});
        end
    end
end
