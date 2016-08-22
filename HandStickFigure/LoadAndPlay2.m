function LoadAndPlay2(Y, cal, bvh, mod, framerate)

Y = calibrateData(Y, cal);
[HandSkel, HandChannels, HandFs] = bvhReadFile(bvh);
HandChannels = mod(Y);

bvhPlayData(HandSkel, HandChannels, 1/framerate);