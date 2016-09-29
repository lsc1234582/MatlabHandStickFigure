function playBackMergedData(ethome, lhSkel, rhSkel, lhCal, rhCal, varargin)
p = inputParser;
p.addRequired('ethome');
p.addRequired('lhSkel');
p.addRequired('rhSkel');
p.addRequired('lhCal');
p.addRequired('rhCal');
p.addParameter('outputName', '');
p.addParameter('lhFingerAbdWeights', [], @(x)isequal(size(x), [3,2]));
p.addParameter('lhChannelAdj', []);
p.addParameter('rhFingerAbdWeights', [], @(x)isequal(size(x), [3,2]));
p.addParameter('rhChannelAdj', []);
p.addParameter('range', []);
p.parse(ethome, lhSkel, rhSkel, lhCal, rhCal, varargin{:});
ethome = p.Results.ethome;

dataViews(1) = getSuitDataView(ethome.Data(p.Results.range, ...
    strcmp(ethome.DataLabels(2, :), 'Suit')), ethome.Suit.Skel, ...
    'titles', {'Body Front', 'Body Normal'}, 'locs', {2, 5}, ...
    'orients', {[180, 0], 3}, 'viewDim', [2, 3]);

dataViews(2) = getHandDataView(ethome.Data(p.Results.range, ...
    strcmp(ethome.DataLabels(2, :), 'LeftHand')), lhSkel, lhCal, ...
    'titles', {'LeftHand Top', 'LeftHand Front'}, 'locs', {1, 4}, ...
    'orients', {[180, 90], [180, 0]}, 'viewDim', [2, 3]);

dataViews(3) = getHandDataView(ethome.Data(p.Results.range, ...
    strcmp(ethome.DataLabels(2, :), 'RightHand')), rhSkel, rhCal, ...
    'titles', {'RightHand Top', 'RightHand Front'}, 'locs', {3, 6}, ...
    'orients', {[0, 90], [180, 0]}, 'viewDim', [2, 3]);

% If time is in ethome.Data
if isempty(find(strcmp(ethome.DataLabels(1, :), 'System_Time'), 1))
    systemTime = ethome.Time;
else
    systemTime = ethome.Data(p.Results.range, strcmp(ethome.DataLabels(1, :), 'System_Time'));
end
systemTime(isnan(systemTime)) = [];

% Get Frame rate
frameGaps = systemTime(2:end) - systemTime(1:end-1);
meanFrameGap = mean(frameGaps);
frameGapErrorSum = sum(frameGaps - meanFrameGap);
disp(['Frame Gap Error Sum: ', num2str(frameGapErrorSum)]);
frameRate = 1000/meanFrameGap

if isempty(p.Results.outputName)
    skelPlayAndSaveMergedData(dataViews, 'frameRate', frameRate);
else
    skelPlayAndSaveMergedData(dataViews, 'frameRate', frameRate, ...
        'des', p.Results.outputName);
end