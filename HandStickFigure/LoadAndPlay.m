function LoadAndPlay(Y, bvh, para, frameRate, des)

[HandSkel, Ignore, Ignore] = bvhReadFile(bvh);
HandChannels = modifyChannel(Y, para);

if nargin < 5
    bvhPlayData(HandSkel, HandChannels, 1/frameRate);
else
    skelPlayAndSaveData(HandSkel, HandChannels, frameRate, des);
end