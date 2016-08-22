function skelPlayAndSaveData(skelStruct, channels, framerate, des)

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
  framerate = 120;
end
clf

handle = skelVisualise(channels(1, :), skelStruct);


% Get the limits of the motion.
xlim = get(gca, 'xlim');
minY1 = xlim(1);
maxY1 = xlim(2);
ylim = get(gca, 'ylim');
minY3 = ylim(1);
maxY3 = ylim(2);
zlim = get(gca, 'zlim');
minY2 = zlim(1);
maxY2 = zlim(2);
for i = 1:size(channels, 1)
  Y = skel2xyz(skelStruct, channels(i, :));
  minY1 = min([Y(:, 1); minY1]);
  minY2 = min([Y(:, 2); minY2]);
  minY3 = min([Y(:, 3); minY3]);
  maxY1 = max([Y(:, 1); maxY1]);
  maxY2 = max([Y(:, 2); maxY2]);
  maxY3 = max([Y(:, 3); maxY3]);
end
xlim = [minY1 maxY1];
ylim = [minY3 maxY3];
zlim = [minY2 maxY2];
set(gca, 'xlim', xlim, ...
         'ylim', ylim, ...
         'zlim', zlim);

movieLength = size(channels, 1);
j = 1;
% Play the motion
%a = tic;
v = VideoWriter(des);
v.FrameRate = framerate;
open(v);
while j ~=  movieLength
  %b = toc(a);
  %if b > frameLength
  skelModify(handle, channels(j, :), skelStruct);
  drawnow
  j = j + 1;
  writeVideo(v, getframe(gcf));
  %a = tic;
  %end
  %pause(frameLength);
  
  %frames(j) = getframe(gcf);
  
end
close(v);
