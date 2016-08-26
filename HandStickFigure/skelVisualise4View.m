function handle = skelVisualise4View(channels, skel, padding)

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

if nargin<3
  padding = 0;
end

channels1 = [channels(1, :) zeros(1, padding)];
vals = skel2xyz(skel, channels1);
connect = skelConnectionMatrix(skel);

indices = find(connect);
[I, J] = ind2sub(size(connect), indices);

% Get the limits of the motion.
minX = min(vals(:, 1));
maxX = max(vals(:, 1));
minY = min(vals(:, 2));
maxY = max(vals(:, 2));
minZ = min(vals(:, 3));
maxZ = max(vals(:, 3));
for i = 2:size(channels, 1)
  Y = skel2xyz(skel, channels(i, :));
  minX = min([Y(:, 1); minX]);
  minY = min([Y(:, 2); minY]);
  minZ = min([Y(:, 3); minZ]);
  maxX = max([Y(:, 1); maxX]);
  maxY = max([Y(:, 2); maxY]);
  maxZ = max([Y(:, 3); maxZ]);
end
minX = minX + (minX/abs(minX)) * 20;
maxX = maxX + (maxX/abs(maxX)) * 20;
minY = minY + (minY/abs(minY)) * 20;
maxY = maxY + (maxY/abs(maxY)) * 20;
minZ = minZ + (minZ/abs(minZ)) * 20;
maxZ = maxZ + (maxZ/abs(maxZ)) * 20;

set(gcf, 'pos', [100,100,1000,700]);
views = {[0, 0], [0, 90], [90, 0], 3};
titles = {'Left', 'Top', 'Front', 'Normal'};

for j = 1:4
    subplot(2, 2, j);
    handle(j, 1) = plot3(vals(:, 1), vals(:, 3), vals(:, 2), '.');
    view(cell2mat(views(j)));
    title(titles(j));
    axis ij % make sure the left is on the left.
    set(handle(j, 1), 'markersize', 20);
    hold on
    grid on
    for i = 1:length(indices)
      handle(j, i+1) = line([vals(I(i), 1) vals(J(i), 1)], ...
                  [vals(I(i), 3) vals(J(i), 3)], ...
                  [vals(I(i), 2) vals(J(i), 2)]);
      set(handle(j, i+1), 'linewidth', 2);
    end
    % Swap Z and Y axis so that Y axis is always displayed as "up"
    axis equal
    xlabel('x')
    ylabel('z')
    zlabel('y')

    axis on
    xlim([minX, maxX]);
    ylim([minZ, maxZ]);
    zlim([minY, maxY]);
end


