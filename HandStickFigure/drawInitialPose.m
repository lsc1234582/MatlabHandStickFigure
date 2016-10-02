function [poses, count] = drawInitialPose(viewport, count, poses, viewDim)
% drawInitialPose(viewport, count, poses, viewDim)
%
% Draws the first frame of the data channel in view
%
% Returns:
%   poses: an array of pose structs that contain handles to the plot
%   count: a number that points to the next pose in the poses array.
%
% Arguments:
%   viewport: viewport struct that specifies the viewport info(limits titles etc.)
%       and its contents (data channels, skeleton etc.)
%   count: a number that points to the current pose in the poses array.
%   poses: an array of pose structs that contain handles to the plot
%   viewDim: a vector that specifies the dimensions of the subplots.

for j = 1:length(viewport.titles)
    subplot(viewDim(1), viewDim(2), viewport.locations{j});
    poses(count).handles(1) = plot3(viewport.vals(:, 1), viewport.vals(:, 3),...
        viewport.vals(:, 2), '.');
    poses(count).skel = viewport.skel;
    poses(count).channels = viewport.channels;
    view(viewport.orientations{j});
    title(viewport.titles{j}, 'FontSize', 20);
    axis ij
    set(poses(count).handles(1), 'markersize', 20);
    hold on
    grid on
    for i = 1:length(viewport.indices)
       poses(count).handles(i+1) = line([viewport.vals(viewport.I(i), 1), ...
           viewport.vals(viewport.J(i), 1)], ...
           [viewport.vals(viewport.I(i), 3) viewport.vals(viewport.J(i), 3)], ...
           [viewport.vals(viewport.I(i), 2) viewport.vals(viewport.J(i), 2)]);
      set(poses(count).handles(i+1), 'linewidth', 2);
      if strcmp(viewport.side(i), 'Left')
          set(poses(count).handles(i+1), 'color', 'blue');
      else
          if strcmp(viewport.side(i), 'Right')
              set(poses(count).handles(i+1), 'color', 'red');
          else
              set(poses(count).handles(i+1), 'color', 'green');
          end
      end
    end
    axis equal
    xlabel('x')
    ylabel('z')
    zlabel('y')

    axis on
    xlim([viewport.minX, viewport.maxX]);
    ylim([viewport.minZ, viewport.maxZ]);
    zlim([viewport.minY, viewport.maxY]);
    count = count + 1;
    
end