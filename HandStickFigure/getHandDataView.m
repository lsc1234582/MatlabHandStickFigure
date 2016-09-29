function dataView = getHandDataView(channelData, skel, cal, varargin)
p = inputParser;
p.addRequired('channelData');
p.addRequired('skel');
p.addRequired('cal');
p.addParameter('lhFingerAbdWeights', [], @(x)isequal(size(x), [3,2]));
p.addParameter('lhChannelAdj', []);
p.addParameter('rhFingerAbdWeights', [], @(x)isequal(size(x), [3,2]));
p.addParameter('rhChannelAdj', []);
p.addParameter('titles', {'Hand normal'});
p.addParameter('locs', {1});
p.addParameter('orients', {3});
p.addParameter('viewDim', [1, 1]);
p.parse(channelData, skel, cal, varargin{:});

dataView.channel = channelData;
dataView.channel(isnan(dataView.channel)) = 0;
dataView.channel = rad2deg(calibrateData(dataView.channel, cal));
dataView.channel = modifyHandChannel(dataView.channel, ...
    p.Results.lhFingerAbdWeights, p.Results.lhChannelAdj);
[dataView.skelStruct, ignore, ignore] = bvhReadFile(skel);
dataView.titles = p.Results.titles;
dataView.locs = p.Results.locs;
dataView.orients = p.Results.orients;
dataView.viewDim = p.Results.viewDim;
end