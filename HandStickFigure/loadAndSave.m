clear;
files = dir('2*');
fileName = 'NothingZeroedMergedCodeWithLoadObjTSCorrectedGazeSyncedDec.mat';
for path = files'
    file = [path.name, '/', fileName];
    cal = [path.name, '/', 'RightHand.cal'];
    outputFile = [path.name, '/', 'RightHand.avi'];
    load(file);
    playBackBVH(calibrateData(F.RightHand.Data(12000:13000, :), cal)*180/pi, ...
        'HandBase3.bvh', F.RightHand.Fs, 'outputName', outputFile);
    
end
