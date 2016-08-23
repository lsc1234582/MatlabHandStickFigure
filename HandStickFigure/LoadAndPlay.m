function LoadAndPlay(dat, cal, bvh, mod, fl)

%Y = load(dat);
%Y = Y.X;
Y = dat(:, 2:23);
Y = calibrateData(Y, cal);
Y = Y*180/pi;
[HandSkel, HandChannels, HandFs] = bvhReadFile(bvh);
HandChannels = mod(Y);

bvhPlayData(HandSkel, HandChannels, fl);