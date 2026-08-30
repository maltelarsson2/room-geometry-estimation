function [settings, scores, r, s, room] = loadPyroomData(folder, is_scannet_data)
%LOADDATA Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    is_scannet_data = false;
end
[r, s, ~, room] = readDataFromFiles(folder, is_scannet_data);
numMics = size(r, 2);
[settings, scores] = gccPhatPyroomSim(folder, numMics);
s = recalculateSenders(linspace(0, 1, size(s, 2)), linspace(0, 1, size(scores{1,1}, 2)), s);
end

function [settings, scores] = gccPhatPyroomSim(folder, numMics)
    settings.v = 343; %340        %speed of sound
    settings.mm = numMics;         %number of microphones
    settings.channels = 1:numMics; %channels to read
    settings.refChannel = 1; %reference channel
    [a,settings.sr] = getAudio(folder, numMics);
    settings.nbrOfSamples = length(a);
    
    settings.wf = @(x) 1./(abs(x)+(abs(x)<5e-3)); %weighting function
    settings.firstSamplePoint = 1; %center sample point of first frame
    settings.frameSize = 2048;%4096;%2048;     %width of frame in sample points
    % settings.frameSize = 5000;     %width of frame in sample points
    settings.dx = 500;%1000;            %distance between frames in sample points
    settings.frameOverlap = settings.frameSize-settings.dx; %overlap between frames
    settings.sw = 1200;%2400;%800;             %clipping of search window
    % settings.sw = 800;             %clipping of search window
    %Default: [@(x) 1./(abs(x)+(abs(x)<5e-3)),1,2048,1048,800]
    
    scores = gccscores(a,settings);
    
    settings.nbrOfFrames = size(scores{1,1},2);
    
    settings.nbrOfPeaks = 4;       %max number of peaks - 4 default
    settings.minPeakHeight = 0.01; %min value of local maxima
    %Default: [4,0.01]
end


function [a, sr] = getAudio(folder, numMics)
prefix = "sim_mic";
suffix = ".wav";
a = zeros(numMics, 1);
for i = 1:numMics
    audiofile = folder + prefix+i+suffix;
    [y,Fs1] = audioread(audiofile);
    if length(y) > size(a, 2)
        a_temp = zeros(numMics, length(y));
        a_temp(:, 1:size(a,2)) = a;
        a = a_temp;
    end
    a(i,1:length(y)) = y;
    sr = Fs1;
end
end