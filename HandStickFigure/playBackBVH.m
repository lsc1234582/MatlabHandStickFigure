function playBackBVH(channels, bvh, frameRate, varargin)
p = inputParser;
p.addRequired('channels');
p.addRequired('bvh');
p.addRequired('frameRate');
p.addParameter('outputName', '');
p.addParameter('fingerAbdWeights', [], @(x)isequal(size(x), [3,2]));
p.addParameter('channelAdj', []);

p.parse(channels, bvh, frameRate, varargin{:});

[handSkel, ignore_, ignore_] = bvhReadFile(p.Results.bvh);

handChannels = modifyChannel(p.Results.channels, ...
    p.Results.fingerAbdWeights, p.Results.channelAdj);

if isempty(p.Results.outputName)
    bvhPlayData(handSkel, handChannels, 1/p.Results.frameRate);
else
    skelPlayAndSaveData(handSkel, handChannels, p.Results.frameRate, ...
        p.Results.outputName);
end