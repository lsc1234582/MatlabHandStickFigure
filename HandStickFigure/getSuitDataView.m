function dataView = getSuitDataView(channelData, bvh, varargin)
% getSuitDataView(channelData, bvh, [titles, locs, orients, viewDim])
%
% Constructs and returns the dataView struct for Suit data from specifications; also
% transforms the data channel as needed (fix hip position, remove NAN
% entires etc.)
%
% Returns:
%   dataView: a struct that contains transformed data channel and viewport
%       info.
%
% Arguments:
%   channelData: suit data channel to be transformed
%   bvh: the path to the bvh file from which the suit skeleton is
%       extracted.
%   [titles]: a cell array containing titles for each view; default is
%       {'Body normal'}.
%   [locs]: a cell array containing subplot locations for each view;
%       default is {1}.
%   [orients]: a cell array containing orientations in [Azimuth, Elevation]
%       format; default is {3} (normal viewpoint)
%   [viewDim]: a vector that specifies the dimension of the subplots;
%       default is [1, 1]

p = inputParser;
p.addRequired('channelData');
p.addRequired('bvh');
p.addParameter('titles', {'Body normal'});
p.addParameter('locs', {1});
p.addParameter('orients', {3});
p.addParameter('viewDim', [1, 1]);
p.parse(channelData, bvh, varargin{:});

dataView.channel = channelData;
dataView.channel(isnan(dataView.channel)) = 0;
% Fix hip position(x,z)
dataView.channel(:, 1) = 0;
dataView.channel(:, 3) = 0;
dataView.skelStruct = bvh;
dataView.titles = p.Results.titles;
dataView.locs = p.Results.locs;
dataView.orients = p.Results.orients;
dataView.viewDim = p.Results.viewDim;

end