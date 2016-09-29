function dataView = getSuitDataView(channelData, skel, varargin)
p = inputParser;
p.addRequired('channelData');
p.addRequired('skel');
p.addParameter('titles', {'Body normal'});
p.addParameter('locs', {1});
p.addParameter('orients', {3});
p.addParameter('viewDim', [1, 1]);
p.parse(channelData, skel, varargin{:});

dataView.channel = channelData;
dataView.channel(isnan(dataView.channel)) = 0;
% Fix hip position(x,z)
dataView.channel(:, 1) = 0;
dataView.channel(:, 3) = 0;
dataView.skelStruct = skel;
dataView.titles = p.Results.titles;
dataView.locs = p.Results.locs;
dataView.orients = p.Results.orients;
dataView.viewDim = p.Results.viewDim;

end