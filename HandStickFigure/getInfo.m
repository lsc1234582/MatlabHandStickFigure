function info = getInfo(ethome)
% getInfo gets basic info (total and runnign length in minutes of each component) of
% an ethome dataset
%
% Returns: 
%   info - a struct containing all info
% Arguments:
%   ethome - ethome data set

if isempty(find(strcmp(ethome.DataLabels(1, :), 'System_Time'), 1))
    sysTime = ethome.Time;
else
    sysTime = getChannel(ethome.Data, ethome.DataLabels, 'System_Time', 1);
    
end
sysTime(isnan(sysTime)) = [];
dataFr = getFrameRate(sysTime);

info.dataTotalLength = size(ethome.Data, 1)/dataFr/60;
info.dataRunningLength = getRunningTime(ethome.Data)/dataFr/60;

info.suitTotalLength = size(ethome.Suit.Data, 1)/getFrameRate(ethome.Suit.Time)/60;
info.suitRunningLength = getRunningTime(getChannel(ethome.Data, ethome.DataLabels, 'Suit', 2))/dataFr/60;

info.lhTotalLength = size(ethome.LeftHand.Data, 1)/getFrameRate(ethome.LeftHand.Time)/60;
info.lhRunningLength = getRunningTime(getChannel(ethome.Data, ethome.DataLabels, 'LeftHand', 2))/dataFr/60;

info.rhTotalLength = size(ethome.RightHand.Data, 1)/getFrameRate(ethome.RightHand.Time)/60;
info.rhRunningLength = getRunningTime(getChannel(ethome.Data, ethome.DataLabels, 'RightHand', 2))/dataFr/60;

if ~isempty(ethome.Gaze)
    info.gazeTotalLength = size(ethome.Gaze.Data, 1)/getFrameRate(ethome.Gaze.Time)/60;
    info.gazeRunningLength = getRunningTime(getChannel(ethome.Data, ethome.DataLabels, 'Gaze', 2))/dataFr/60;
end

end