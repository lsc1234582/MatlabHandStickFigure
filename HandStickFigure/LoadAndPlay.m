function LoadAndPlay(dat)

%Y = load(dat);
%Y = Y.X;
Y = dat(:, 2:23);
Y = calibrateData(Y, '/home/sicong/Documents/MATLAB/HandCalibrationsonly/HandCalibrationsonly/201309211/RightHand.cal');
[HandSkel, HandChannels, HandFs] = bvhReadFile('HandBase3.bvh');
HandChannels = modifyChannel(Y);

bvhPlayData(HandSkel, HandChannels, 0.01);