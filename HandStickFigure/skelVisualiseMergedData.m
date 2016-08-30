function poses = skelVisualiseMergedData(channels, skelStruct)

% SKELVISUALISE For drawing a skel representation of 3-D data.
%
%	Description:
%
%	HANDLE = SKELVISUALISE(CHANNELS, SKEL) draws a skeleton
%	representation in a 3-D plot.
%	 Returns:
%	  HANDLE - a vector of handles to the plotted structure.
%	 Arguments:
%	  CHANNELS - the channels to update the skeleton with.
%	  SKEL - the skeleton structure.
%	
%
%	See also
%	SKELMODIFY
 

%	Copyright (c) 2005, 2006 Neil D. Lawrence
% 	skelVisualise.m CVS version 1.4
% 	skelVisualise.m SVN version 30
% 	last update 2008-01-12T11:32:50.000000Z

lhView = getViewportContent(channels.leftHand, skelStruct.leftHand, ...
    {'Left Hand Top', 'Left Hand Front'}, {1, 4}, {[180, 90], [180, 0]});
rhView = getViewportContent(channels.rightHand, skelStruct.rightHand, ...
    {'Right Hand Top', 'Right Hand Front'}, {3, 6}, {[0, 90], [0, 0]});
suitView = getViewportContent(channels.suit, skelStruct.suit, ...
    {'Body Front', 'Body Normal'}, {2, 5}, {[0, 0], 3})

set(gcf, 'pos', [100,100,1500,700]);

count = 1;
% Pre-allocate struct array
poses(5).handles = [];

[poses, count] = drawInitialPose(lhView, count, poses);
[poses, count] = drawInitialPose(rhView, count, poses);
[poses, count] = drawInitialPose(suitView, count, poses);

