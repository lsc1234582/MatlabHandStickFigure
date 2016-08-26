clear;
roots = {'AW_01', 'AW_03', 'AW_05'};
subs = {'Kitchen', 'Bedroom'};
fileName = 'NothingZeroedMergedCodeWithLoadObjTSCorrectedGazeSyncedDec.mat';
for root = roots
   for sub = subs
      path = [cell2mat(root), '/', cell2mat(sub), '/'];
      file = [path, fileName];
      outputFile = [path, 'RightHand'];
      load(file);
      cal = strrep(F.RecordDate, '-', '');
      cal = ['HandCalibrationsonly/', cal, '1/RightHand.cal']
      playBackBVH(calibrateData(F.RightHand.Data, cal)*180/pi, ...
        'HandBase3.bvh', F.RightHand.Fs, 'outputName', outputFile);
   end
end