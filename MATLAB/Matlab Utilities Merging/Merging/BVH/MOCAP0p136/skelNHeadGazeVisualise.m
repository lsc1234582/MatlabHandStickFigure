function handle = skelNHeadGazeVisualise(channels, skel,headRot, padding,handle)
handle=[];
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


channels = [channels zeros(1, padding)];

vals = skel2xyz(skel, channels);
connect = skelConnectionMatrix(skel);
%gazeXYZ(3,:)=-gazeXYZ(3,:);

% vals(27,:)=vals(25,:)+((gazeXYZ')/10)*headRot;
% gazeXYZ;
vals(27,:)=vals(25,:)+(([0,0,20]))*headRot;

connect(27,25)=1;

indices = find(connect);
[I, J] = ind2sub(size(connect), indices);
handle(1) = plot3(vals(:, 1), vals(:, 3), vals(:, 2), '.');
axis ij % make sure the left is on the left.
set(handle(1), 'markersize', 20);
hold on
grid on


% 
for i = 1:length(indices)
  handle(i+1) = line([vals(I(i), 1) vals(J(i), 1)], ...
              [vals(I(i), 3) vals(J(i), 3)], ...
              [vals(I(i), 2) vals(J(i), 2)],'color','r');
  set(handle(i+1), 'linewidth', 2);
end

handle(i+2)=plot3(vals(27, 1), vals(27, 3), vals(27, 2),'x'); hold on

handle(i+3)=plot3(vals(23, 1), vals(23, 3), vals(23, 2),'rx'); hold on
handle(i+4)=plot3(vals(18, 1), vals(18, 3), vals(18, 2),'gx'); hold on


axis equal
   xlim([-100 100])
        zlim([0 200])
        ylim([-100 100])

az = -90;
el = 45;
view(az, el);



xlabel('x')
ylabel('z')
zlabel('y')
%axis on



