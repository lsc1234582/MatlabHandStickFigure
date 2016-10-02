function labels = getSkelTreeChannelLabels(skel)
% getSkelTreeChannelLabels(skel)
%
% Gets label strings for each joint in a skeleton struct.
%
% Returns:
%   labels: a cell array containing all label strings for each joint in the
%       skeleton.
%
% Arguments:
%   skel: skeleton struct

j = 1;
for i = 1:length(skel.tree)
   if ~isempty(skel.tree(i).channels)
       for channel = skel.tree(i).channels
           labels{j} = [skel.tree(i).name, ' ', channel{:}];
           j = j+1;
       end
   end
end

