function labels = getSkelTreeChannelLabels(skel)
j = 1;
for i = 1:length(skel.tree)
   if ~isempty(skel.tree(i).channels)
       for channel = skel.tree(i).channels
           labels{j} = [skel.tree(i).name, ' ', channel{:}];
           j = j+1;
       end
   end
end

