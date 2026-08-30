function [gccInds] = tdoaToGccInd(tdoas, gccPhatSettings, shouldRound)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if nargin < 3
    shouldRound = true;
end
if shouldRound
    gccInds = round(tdoas/gccPhatSettings.v*gccPhatSettings.sr)+ gccPhatSettings.sw + 1;
else
    gccInds = tdoas/gccPhatSettings.v*gccPhatSettings.sr+ gccPhatSettings.sw + 1;
end
end