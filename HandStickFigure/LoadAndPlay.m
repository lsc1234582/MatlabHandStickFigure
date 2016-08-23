function LoadAndPlay(Y, cal, bvh, para, fl)

Y = calibrateData(Y, cal);
Y = Y*180/pi;
[HandSkel, Ignore, Ignore] = bvhReadFile(bvh);
HandChannels = modifyChannel(Y, para);

bvhPlayData(HandSkel, HandChannels, fl);