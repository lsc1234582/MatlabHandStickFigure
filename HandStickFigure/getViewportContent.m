function viewport = getViewportContent(channels, skel, titles, ...
    locs, orients)
% getViewportContent(channels, skel, titles, locs, orients)
%
% Gets the viewport info(limits of each axis, titles, subplot locations e.t.c
% and its contents (channels and skeleton)
%
% Returns:
%   viewport: a viewport struct that contains all info
%
% Arguments:
%   channels: the data channel to be displayed in this viewport
%   skel: the skeleton for the data channel
%   titles: a cell array containing titles for each view
%   locs: a cell array containing subplot locations for each view
%   orients: a cell array containing the orientations in [Azimuth, Elevation]
%       format.

channels1 = channels(1, :);
viewport.vals = skel2xyz(skel, channels1);
viewport.connect = skelConnectionMatrix(skel);

viewport.indices = find(viewport.connect);
[viewport.I, viewport.J] = ind2sub(size(viewport.connect), viewport.indices);
viewport.side = getSkelSide(skel, viewport.I, viewport.J);

% Get the limits of the motion.
viewport.minX = min(viewport.vals(:, 1));
viewport.maxX = max(viewport.vals(:, 1));
viewport.minY = min(viewport.vals(:, 2));
viewport.maxY = max(viewport.vals(:, 2));
viewport.minZ = min(viewport.vals(:, 3));
viewport.maxZ = max(viewport.vals(:, 3));
for i = 2:size(channels, 1)
  Y = skel2xyz(skel, channels(i, :));
  viewport.minX = min([Y(:, 1); viewport.minX]);
  viewport.minY = min([Y(:, 2); viewport.minY]);
  viewport.minZ = min([Y(:, 3); viewport.minZ]);
  viewport.maxX = max([Y(:, 1); viewport.maxX]);
  viewport.maxY = max([Y(:, 2); viewport.maxY]);
  viewport.maxZ = max([Y(:, 3); viewport.maxZ]);
end
viewport.minX = viewport.minX - 20;
viewport.maxX = viewport.maxX + 20;
% Hardcoded min Y
if any(cell2mat(strfind(lower(titles), 'body')))
    viewport.minY = -20;
else
    viewport.minY = viewport.minY - 20;
end
viewport.maxY = viewport.maxY + 20;
viewport.minZ = viewport.minZ - 20;
viewport.maxZ = viewport.maxZ + 20;

viewport.titles = titles;
viewport.locations = locs;
viewport.orientations = orients;
viewport.skel = skel;
viewport.channels = channels;