function LoadAndPlay2(Y, cal, bvh, mod, fl)

Y = calibrateData(Y, cal);
Y = Y*180/pi;
[HandSkel, HandChannels, HandFs] = bvhReadFile(bvh);
HandChannels = mod(Y);

bvhPlayData(HandSkel, HandChannels, fl);