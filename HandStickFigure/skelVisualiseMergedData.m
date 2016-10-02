function poses = skelVisualiseMergedData(dataViews, gcfPos)
% skelVisualiseMergedData(dataViews, gcfPos)
%
% Draws the first frame of all data channels in their respective viewports
% and returns an array of struct poses that caontain handles to the plot
% for future modification.
%
% Returns:
%   poses: an array of pose struct that contains handles to the plot
%
% Arguments:
%   dataViews: an array of dataview structs
%   gcfPos: a vector that specifies the screen position and resolution of
%       the figure

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

