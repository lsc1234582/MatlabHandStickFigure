function LoadAndSaveData(Y, cal, bvh, mod, des, Fr)

Y = calibrateData(Y, cal);
Y = Y*180/pi;
[HandSkel, HandChannels, HandFs] = bvhReadFile(bvh);
HandChannels = mod(Y);

skelPlayAndSaveData(HandSkel, HandChannels, Fr, des);