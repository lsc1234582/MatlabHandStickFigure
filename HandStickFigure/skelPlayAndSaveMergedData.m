function skelPlayAndSaveMergedData(dataViews, varargin)

% SKELPLAYDATA Play skel motion capture data.
%
%	Description:
%
%	SKELPLAYDATA(SKEL, CHANNELS, FRAMELENGTH) plays channels from a
%	motion capture skeleton and channels.
%	 Arguments:
%	  SKEL - the skeleton for the motion.
%	  CHANNELS - the channels for the motion.
%	  FRAMELENGTH - the framelength for the motion.
%	
%
%	See also
%	BVHPLAYDATA, ACCLAIMPLAYDATA


%	modified by SiCong Li
% 	skelPlayData.m CVS version 1.2
% 	skelPlayData.m SVN version 42
% 	last update 2008-08-12T20:23:47.000000Z

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
