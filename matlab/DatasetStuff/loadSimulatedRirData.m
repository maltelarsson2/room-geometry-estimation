function [r, s, room, rirs, fs] = loadSimulatedRirData(folder)
%LOADSIMULATEDRIRDATA Summary of this function goes here
%   Detailed explanation goes here
[r, s, ~, room] = readDataFromFiles(folder);
fs = readmatrix(folder + "sample_rate.txt");

rirs = cell(size(r,2), size(s,2));
for i = 1:size(r,2)
    rirs_mic = my_readMatrix(folder + "rirs_mic" + i + ".txt");
    for j = 1:size(rirs_mic, 1)
        rirs{i,j} = rirs_mic(j,:);
    end
end



end

