function out = deSwitch( data, varargin)
% out = deSwitch(data, units, tresh)
% Inputs:
% <data>    NxD  data matrix where N is the sequence length and D the
%           dimensionality of the data. Each dimension is treated
%           separately.
% 
% Optional inputs:
% <units>   'deg' or 'rad', depending on whether the angles are in angles
%           or radians.
%           Default is 'rad'.
%
% <tresh>   Depending on units, fraction of 180 degrees or pi to be set as
%           threshold.
%           The default is set to 90%.
% 
% Outputs:
% <out>     NxD matrix containing the data where any jumps larger than
%           tresh have been removed.
% 
% Written by Andreas Thomik, July 2012.

% Parse inputs
p = inputParser;

p.addRequired( 'data' );
p.addOptional( 'units', 'rad', @(x) any( strcmpi( x, {'rad', 'deg'} ) ) );
p.addOptional( 'tresh', .9, @(x) isscalar( x ) && x >= 0 && x <= 1 );

p.parse( data, varargin{:} )

args = p.Results;
X = args.data;
tresh = args.tresh;
units = args.units;

clearvars p args

% Remove switches. The code runs over the data and removes any switches
% larger than 'tresh'.
[~, D] = size(X);
out = X;
switch units
    case 'deg'
        tresh = tresh * 180;
        add = 180;
    case 'rad'
        tresh = tresh * pi;
        add = pi;
end

for k = 1:D
    while ~isempty( find( abs( diff( out(:, k) ) ) > tresh, 1) )
        % Find the location of the switch
        t = find( abs( diff( out(:, k) ) ) > tresh, 1, 'first' );
        % Compute its magnitude
        off = sign( out(t+1,k) - out(t,k) );
        % Add the offset to all the data after the switch and repeat...
        switch units
            case 'deg'
                out(t+1:end,k) = out(t+1:end,k) - off * 180;
            case 'rad'
                out(t+1:end,k) = out(t+1:end,k) - off * pi;
        end
    end
end

end