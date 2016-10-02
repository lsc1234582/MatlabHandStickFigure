function dataView = getHandDataView(channelData, bvh, cal, varargin)
% getHandDataView(channelData, bvh, [titles, locs, orients, viewDim])
%
% Constructs and returns the dataView struct for Hand data from specifications; also
% transforms the data channel as needed (calibrate hand data; convert to
% joint-angle data etc.)
%
% Returns:
%   dataView: a struct that contains transformed data channel and viewport
%       info.
%
% Arguments:
%   channelData: hand data channel to be transformed
%   bvh: the path to the bvh file from which the hand skeleton is
%       extracted.
%   cal: the path to the cal file that is used for the calibration of the
%       hand.
%   [titles]: a cell array containing titles for each view; default is
%       {'Hand normal'}.
%   [locs]: a cell array containing subplot locations for each view;
%       default is {1}.
%   [orients]: a cell array containing orientations in [Azimuth, Elevation]
%       format; default is {3} (normal viewpoint)
%   [viewDim]: a vector that specifies the dimension of the subplots;
%       default is [1, 1]

p = inputParser;
p.addRequired('channelData');
p.addRequired('bvh');
p.addRequired('cal');
p.addParameter('fingerAbdWeights', [], @(x)isequal(size(x), [3,2]));
p.addParameter('titles', {'Hand normal'});
p.addParameter('locs', {1});
p.addParameter('orients', {3});
p.addParameter('viewDim', [1, 1]);
p.parse(channelData, bvh, cal, varargin{:});

dataView.channel = channelData;
dataView.channel(isnan(dataView.channel)) = 0;
dataView.channel = rad2deg(calibrateData(dataView.channel, cal));
dataView.channel = modifyHandChannel(dataView.channel, ...
    p.Results.fingerAbdWeights);
[dataView.skelStruct, ignore, ignore] = bvhReadFile(bvh);
dataView.titles = p.Results.titles;
dataView.locs = p.Results.locs;
dataView.orients = p.Results.orients;
dataView.viewDim = p.Results.viewDim;
end