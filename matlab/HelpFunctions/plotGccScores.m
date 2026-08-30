function plotGccScores(score, gccPhatSettings)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
figure()

c = 10;%20;%10; %set to 1 not to clip any colors
score2 = score;
mm = max(max(score2))/c;
% score2(score2/mm < 0.1) = 0;

imagesc(score2,[0,mm]),colormap(gray)

setaxes(gccPhatSettings)
end