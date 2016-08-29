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

p.parse(ethome, lhSkel, rhSkel, lhCal, rhCal, varargin{:});
ethome = p.Results.ethome;
channels.suit = ethome.Data(40000:41000, find(strcmp(ethome.DataLabels(2, :), 'Suit')));
channels.suit(isnan(channels.suit)) = 0;
channels.leftHand = ethome.Data(40000:41000, find(strcmp(ethome.DataLabels(2, :), 'LeftHand')));
channels.leftHand(isnan(channels.suit)) = 0;
channels.rightHand = ethome.Data(40000:41000, find(strcmp(ethome.DataLabels(2, :), 'RightHand')));
channels.rightHand(isnan(channels.suit)) = 0;

skelStruct.suit = ethome.Suit.Skel;
skelStruct.leftHand = lhSkel;
skelStruct.rightHand = rhSkel;

channels.leftHand = calibrateData(channels.leftHand, lhCal) * 180 / pi;
channels.rightHand = calibrateData(channels.rightHand, rhCal) * 180 / pi;

channels.leftHand = modifyLHChannel(channels.leftHand, ...
    p.Results.lhFingerAbdWeights, p.Results.lhChannelAdj);

channels.rightHand = modifyChannel2(channels.rightHand, ...
    p.Results.rhFingerAbdWeights, p.Results.rhChannelAdj);

if isempty(p.Results.outputName)
    bvhPlayData(handSkel, handChannels, 1/p.Results.frameRate);
else
    skelPlayAndSaveMergedData(skelStruct, channels, 50, ...
        p.Results.outputName);
end