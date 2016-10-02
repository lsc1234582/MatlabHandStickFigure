function skelPlayAndSaveMergedData(dataViews, varargin)
% skelPlayAndSaveMergedData(dataViews, [des, frameRate, gcfPos])
% 
% Plays back or save one or data sources in customisable views.
%
% Returns:
%   none
%
% Arguments:
%   dataViews: an array of dataView structs (obtained from either
%   getHandDataView or getSuitDataView)
%   [des]: path and name of the output video file; if left blanck only
%       plays back the motion instead of saving it.
%   [frameRate]: frame rate at which the motion is played/saved; if left
%       blanck default value (120 fps) will be used.
%   [gcfPos]: a vector specifying the screen position and resolution of the
%       figure; if left blanck default value [100, 100, 1440, 900] will be
%       used.

p = inputParser;
p.addRequired('dataViews');
p.addParameter('des', '');
p.addParameter('frameRate', 120);
p.addParameter('gcfPos', [100,100,1440,900]);

clf;
p.parse(dataViews, varargin{:});

poses = skelVisualiseMergedData(dataViews, p.Results.gcfPos);

movieLength = 0;

for i = 1:length(dataViews)
   if movieLength < size(dataViews(i).channel, 1)
       movieLength = size(dataViews(i).channel, 1)
   end
end

j = 1;
% Play the motion
if ~isempty(p.Results.des)
    profile = 'MPEG-4';
    if isunix
        profile = 'Motion JPEG AVI';
    end
    v = VideoWriter(p.Results.des, profile);
    v.FrameRate = p.Results.frameRate;
    open(v);
end

j = 1;
while j ~= movieLength
  for pose = poses
      if j <= length(pose.channels)
          skelModify(pose.handles, pose.channels(j, :), pose.skel);
      end
  end
  drawnow;
  j = j+1;
  if ~isempty(p.Results.des)
      writeVideo(v, getframe(gcf));
  else
      pause(1/p.Results.frameRate)
  end
end

if ~isempty(p.Results.des)
    close(v);
end
