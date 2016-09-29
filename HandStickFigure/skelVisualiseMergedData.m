function poses = skelVisualiseMergedData(dataViews, gcfPos)

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

set(gcf, 'pos', gcfPos);


count = 1;

poses = [];

for i = 1:length(dataViews)
    viewInfoLength = [length(dataViews(i).titles), length(dataViews(i).locs), ...
       length(dataViews(i).orients)];
   
    if ~isequal(viewInfoLength(1), viewInfoLength(2), viewInfoLength(3)) || ...
            any(viewInfoLength == 0)
        disp('Incomplete viewport info(titles, subplot locations or subplot orientations');
    else
        view = getViewportContent(dataViews(i).channel, dataViews(i).skelStruct, ...
        dataViews(i).titles, dataViews(i).locs, dataViews(i).orients);
        [poses, count] = drawInitialPose(view, count, poses, dataViews(i).viewDim);
    end
end

