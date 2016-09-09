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
channels.suit = ethome.Data(p.Results.range, find(strcmp(ethome.DataLabels(2, :), 'Suit')));
channels.suit(isnan(channels.suit)) = 0;
% Fix hip position(x,z)
channels.suit(:, 1) = 0;
channels.suit(:, 3) = 0;
channels.leftHand = ethome.Data(p.Results.range, find(strcmp(ethome.DataLabels(2, :), 'LeftHand')));
channels.leftHand(isnan(channels.suit)) = 0;
channels.rightHand = ethome.Data(p.Results.range, find(strcmp(ethome.DataLabels(2, :), 'RightHand')));
channels.rightHand(isnan(channels.suit)) = 0;


skelStruct.suit = ethome.Suit.Skel;
[lhSkel, ignore, ignore] = bvhReadFile(lhSkel);
[rhSkel, ignore, ignore] = bvhReadFile(rhSkel);
skelStruct.leftHand = lhSkel;
skelStruct.rightHand = rhSkel;

channels.leftHand = calibrateData(channels.leftHand, lhCal) * 180 / pi;
channels.rightHand = calibrateData(channels.rightHand, rhCal) * 180 / pi;

channels.leftHand = modifyChannel2(channels.leftHand, ...
    p.Results.lhFingerAbdWeights, p.Results.lhChannelAdj);

channels.rightHand = modifyChannel2(channels.rightHand, ...
    p.Results.rhFingerAbdWeights, p.Results.rhChannelAdj);

% Get Frame rate
frameGaps = ethome.Time(2:end) - ethome.Time(1:end-1);
meanFrameGap = mean(frameGaps);
frameGapErrorSum = sum(frameGaps - meanFrameGap);
disp(['Frame Gap Error Sum: ', num2str(frameGapErrorSum)]);
frameRate = 1000/meanFrameGap

if isempty(p.Results.outputName)
    bvhPlayData(handSkel, handChannels, 1/p.Results.frameRate);
else
    skelPlayAndSaveMergedData(skelStruct, channels, frameRate, ...
        p.Results.outputName);
end