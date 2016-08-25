function LoadAndPlay(Y, bvh, frameRate, para, des)

[HandSkel, Ignore, Ignore] = bvhReadFile(bvh);

if nargin < 4
    HandChannels = modifyChannel(Y);
else
    HandChannels = modifyChannel(Y, para);
end

if nargin < 5
    bvhPlayData(HandSkel, HandChannels, 1/frameRate);
else
    skelPlayAndSaveData(HandSkel, HandChannels, frameRate, des);
end