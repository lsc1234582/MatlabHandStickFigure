function LoadAndSaveData(Y, cal, bvh, mod, des, Fr)

Y = calibrateData(Y, cal);
[HandSkel, HandChannels, HandFs] = bvhReadFile(bvh);
HandChannels = mod(Y);

skelPlayAndSaveData(HandSkel, HandChannels, Fr, des);