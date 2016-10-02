function info = getInfo(ethome, resourceName)
% getInfo(ethome, resourceName)
%
% Gets basic info (total and runnign length in minutes of each body part) of
% an ethome dataset
%
% Returns: 
%   info - a struct containing all info
%
% Arguments:
%   ethome - ethome data set
%   resourceName - the name of the .mat file from which this dataset is obtained

if isempty(find(strcmp(ethome.DataLabels(1, :), 'System_Time'), 1))
    sysTime = ethome.Time;
else
    sysTime = getChannel(ethome.Data, ethome.DataLabels, 'System_Time', 1);
end
sysTime(isnan(sysTime)) = [];
dataFr = getFrameRate(sysTime);

info.SubjectID = ethome.SubjectID;
info.SettingID = ethome.SettingID;
info.RecordDate = ethome.RecordDate;
info.ResourceName = resourceName;

info.dataTotalLength = size(ethome.Data, 1)/dataFr/60;
info.dataRunningLength = getRunningTime(ethome.Data)/dataFr/60;

info.suitTotalLength = size(ethome.Suit.Data, 1)/ethome.Suit.Fs/60;
info.suitRunningLength = getRunningTime(getChannel(ethome.Data, ethome.DataLabels, 'Suit', 2))/dataFr/60;

info.lhTotalLength = size(ethome.LeftHand.Data, 1)/ethome.LeftHand.Fs/60;
info.lhRunningLength = getRunningTime(getChannel(ethome.Data, ethome.DataLabels, 'LeftHand', 2))/dataFr/60;

info.rhTotalLength = size(ethome.RightHand.Data, 1)/ethome.RightHand.Fs/60;
info.rhRunningLength = getRunningTime(getChannel(ethome.Data, ethome.DataLabels, 'RightHand', 2))/dataFr/60;


if ~isempty(ethome.Gaze)
    info.gazeTotalLength = size(ethome.Gaze.Data, 1)/ethome.Gaze.Fs/60;
    info.gazeRunningLength = getRunningTime(getChannel(ethome.Data, ethome.DataLabels, 'Gaze', 2))/dataFr/60;
else
    info.gazeTotalLength = 0;
    info.gazeRunningLength = 0;
end

end