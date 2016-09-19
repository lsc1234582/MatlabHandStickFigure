clear;
subjectBase = 'AW_';
settings = {'Kitchen', 'Bedroom'};
fileName = 'NothingZeroedMergedCodeWithLoadObjTSCorrectedGazeSyncedDec.mat';

count = 1;
for i = 1:7
   subjectID = strcat(subjectBase, sprintf('%02d', i));
   for settingID = settings
      path = [subjectID, '/', cell2mat(settingID), '/'];
      for ethomeFile = dir(path)'
          ethomeFile.name
          if strcmp(ethomeFile.name, '.') || strcmp(ethomeFile.name, '..') ...
              || strcmp(ethomeFile.name, 'MergedVideo')
              continue
          end
          load([path, ethomeFile.name]);
          infos(count) = getInfo(F, ethomeFile.name);
          count = count + 1;
      end
   end
end

writetable(struct2table(infos), 'EthomeBasicInfoFixedFixed.csv');