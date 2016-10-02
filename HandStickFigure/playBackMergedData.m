function playBackMergedData(ethome, lhBvh, rhBvh, lhCal, rhCal, varargin)
% playBackMergedData(ethome, lhBvh, rhBvh, lhCal, rhCal, [des, 
% lhFingerAbdWeights, lhChannelAdj, rhFingerAbdWeights, rhChannelAdj, range])
%
% Plays back or save suit and hand data in a merged view(Top and front views 
% for both hands; front and normal views for suit)
% 
% Returns: 
%   none
%
% Arguments:
%   ethome: Ethome object
%   lhBvh/rhBvh: path to the bvh file for left/right hand
%   lhCal/rhCal: path to the calibration file for left/right hand
%   [des]: path and name of the output video file; if left blanck only
%       play back motion instead of saving it.
%   [lhFingerAbdWeight/rhFingerAbdWeight]: a 3x2 matrix containing linear
%       weights for the extent of left/hand finger abduction sensors; if 
%       left blanck default value will be used.
%   [range]: a vector that marks the range of the motion to be played back
%   if left blanck default value (empty) will be used.
%
% Example:
%   playBackMergedData(F, 'LeftHandBase.bvh', 'RightHandBase.bvh', 
%   '201309251/LeftHand.cal', '201309251/RightHand.cal', 'range', 500:2000)
%   playBackMergedData(F, 'LeftHandBase.bvh', 'RightHandBase.bvh', 
%   '201309251/LeftHand.cal', '201309251/RightHand.cal', 'range', :, 'des',
%   'output.mp4')

p = inputParser;
p.addRequired('ethome');
p.addRequired('lhBvh');
p.addRequired('rhBvh');
p.addRequired('lhCal');
p.addRequired('rhCal');
p.addParameter('des', '');
p.addParameter('lhFingerAbdWeights', [], @(x)isequal(size(x), [3,2]));
p.addParameter('rhFingerAbdWeights', [], @(x)isequal(size(x), [3,2]));
p.addParameter('range', []);
p.parse(ethome, lhBvh, rhBvh, lhCal, rhCal, varargin{:});
ethome = p.Results.ethome;

dataViews(1) = getSuitDataView(ethome.Data(p.Results.range, ...
    strcmp(ethome.DataLabels(2, :), 'Suit')), ethome.Suit.Skel, ...
    'titles', {'Body Front', 'Body Normal'}, 'locs', {2, 5}, ...
    'orients', {[180, 0], 3}, 'viewDim', [2, 3]);

dataViews(2) = getHandDataView(ethome.Data(p.Results.range, ...
    strcmp(ethome.DataLabels(2, :), 'LeftHand')), lhBvh, lhCal, ...
    'titles', {'LeftHand Top', 'LeftHand Front'}, 'locs', {1, 4}, ...
    'orients', {[180, 90], [180, 0]}, 'viewDim', [2, 3]);

dataViews(3) = getHandDataView(ethome.Data(p.Results.range, ...
    strcmp(ethome.DataLabels(2, :), 'RightHand')), rhBvh, rhCal, ...
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

if isempty(p.Results.des)
    skelPlayAndSaveMergedData(dataViews, 'frameRate', frameRate);
else
    skelPlayAndSaveMergedData(dataViews, 'frameRate', frameRate, ...
        'des', p.Results.des);
end