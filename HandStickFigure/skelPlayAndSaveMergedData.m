function skelPlayAndSaveMergedData(skelStruct, channels, frameRate, des)

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

if nargin < 3
  frameRate = 120;
end
clf

poses = skelVisualiseMergedData(channels, skelStruct);

movieLength = size(channels.rightHand, 1);
j = 1;
% Play the motion
%a = tic;
profile = 'MPEG-4';
if isunix
    profile = 'Motion JPEG AVI';
end
v = VideoWriter(des, profile);
v.FrameRate = frameRate;
open(v);
a = tic;
while j ~=  movieLength
  %b = toc(a);
  %if b > frameLength
  % Update all viewports
  for pose = poses
      skelModify(pose.handles, pose.channels(j, :), pose.skel);
  end
  drawnow;
  j = j + 1;
  writeVideo(v, getframe(gcf));
  %a = tic;
  %end
  %pause(frameLength);
  
  %frames(j) = getframe(gcf);
end
b = toc(a)
close(v);
