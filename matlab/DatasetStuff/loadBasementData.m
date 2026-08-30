function [settings, scores, r, s, walls_gt] = loadBasementData(folder, timeInterval, numMics, frameSize, dx, sw)
%LOADDATA Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    timeInterval = [10, 20];
end
if nargin < 3
    numMics = 12;
end
if nargin< 4
    frameSize = 8000;
    dx = 2000;
    sw = 3200;
end
r = [4.27, 1.47, 1.51;
    5.85, 3.84, 1.60;
    5.21, 1.45, 0.15;
    6.82, 2.56, 1.05;
    5.92, 2.40, 1.04;
    6.72, 1.47, 0.21;
    7.16, 3.68, 1.33;
    4.70, 3.18, 1.39;
    5.14, 3.86, 0.24;
    6.80, 3.48, 0.23;
    5.50, 2.97, 0.18;
    4.28, 2.60, 0.15]';
walls_gt = [0, 0, 1, 0;
    0, 0, 1, 2.97;
    0, 1, 0, 0;
    0, 1, 0, 4.93;
    1, 0, 0, 0;
    1, 0, 0, 8.82]';

[settings, scores] = gccPhatBasement(numMics, timeInterval, frameSize, dx, sw, folder);

data = load(folder + "detectionsMatlab.mat", "tdoa", "times");
times = data.times;
% times = times+10; %Due to cropping the sound file to where it actually starts
usedPoints = (times>timeInterval(1)) & (times<timeInterval(2));
time_inds = interp1(timeInterval, [0, size(scores{1, 2}, 2)], times(usedPoints));
temp = load(folder + "senders_basement.mat");
s_opt = temp.s_opt';
s_opt = s_opt(:, usedPoints);
s = interp1(time_inds, s_opt', 1:size(scores{1, 2}, 2), "linear", "extrap")';


end

function [settings, scores] = gccPhatBasement(numMics, timeInterval, frameSize, dx, sw, folder)
    settings.v = 343; %340        %speed of sound
    settings.mm = numMics;         %number of microphones
    settings.channels = 1:numMics; %channels to read
    settings.refChannel = 1; %reference channel
    [a,settings.sr] = getAudio(numMics, timeInterval, folder);
    settings.nbrOfSamples = length(a);
    
    settings.wf = @(x) 1./(abs(x)+(abs(x)<5e-3)); %weighting function
    settings.firstSamplePoint = 1; %center sample point of first frame
    settings.frameSize = frameSize;     %width of frame in sample points
    settings.dx = dx;            %distance between frames in sample points
    settings.frameOverlap = settings.frameSize-settings.dx; %overlap between frames
    settings.sw = sw;             %clipping of search window
    %Default: [@(x) 1./(abs(x)+(abs(x)<5e-3)),1,2048,1048,800]
    

    scores = gccscores(a,settings);
    
    settings.nbrOfFrames = size(scores{1,1},2);
    
    settings.nbrOfPeaks = 4;       %max number of peaks - 4 default
    settings.minPeakHeight = 0.01; %min value of local maxima
    %Default: [4,0.01]
end


function [a, sr] = getAudio(numMics, timeInterval, folder)

prefix = folder + "Track ";
suffix = ".wav";
a = zeros(numMics, 1);
clapPoint = 1;
for i = 1:numMics
    audiofile = prefix+i+suffix;
    [y,Fs1] = audioread(audiofile);
    y = y(round(clapPoint+timeInterval(1)*Fs1):round(clapPoint+timeInterval(2)*Fs1));
    if length(y) > size(a, 2)
        a_temp = zeros(numMics, length(y));
        a_temp(:, 1:size(a,2)) = a;
        a = a_temp;
    end
    a(i,1:length(y)) = y;
    sr = Fs1;
end
end
