function [d_nlos_cleaned] = rirsToCleanDnlos(rirs, samplerate, v, numPeaks, r, s, d_grd)
%SCORESTOCLEANDNLOS Summary of this function goes here
%   Detailed explanation goes here
if nargin < 7
    d_grd = pdist2(r',s');
end
d_nlos_cleaned = rirsToToas(rirs, samplerate, v, numPeaks);
% d_nlos_cleaned = shift_dnlos(d_nlos_cleaned, repmat(d_grd(r_ref, :), [size(d_nlos_cleaned, 1), 1]));
d_nlos_cleaned = removeCloseDistancesFromTdoas(d_nlos_cleaned, d_grd, 0.05);
d_nlos_cleaned = removeTdoasShorterThanLos(d_nlos_cleaned, d_grd); 
end

