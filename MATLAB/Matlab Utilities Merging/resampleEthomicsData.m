function varargout = resampleEthomicsData( varargin )
% function out = resampleEthomicsData( T1, D1, T2, D2, ..., 'Fs', x )
% Resamples the ethomics data to have coherent time-stamps.
%
% Inputs:
% <TI1, DI1, ...>   Pairs of time-stamps and corresponding data.
%                   The number of time-stamps and data points needs to be
%                   identical.
%                   T is a Nx1 vector returned by the getMilliSecondTime()
%                       function.
%                   D is a NxD matrix of data points.
%                   If either T or D is empty, that pair is ignored.
% 
% Parameters: (insert as parameter name/value pairs (e.g.: 'Fs', 100 ) )
% <Fs>  Resampling frequency for the data.
%       Default is 1 kHz.
% 
% Outputs:
% <out> Depending on the number of output variables, this is either:
% 
%           If the number of output arguments is the same as the number of
%           input matrices, out are pairs of resampled time and data
%           matrices.
%           If the number of output arguments is 1, this is a Kx2 cell
%           matrix where K is the number of input pairs. The first column
%           is the resampled time, the second the resampled data. The
%           order follows the input order.
%
% Written by Andreas Thomik, August 2013.

nIn = nargin;

% Check if the resampling frequency was specified
if any( strcmp( 'Fs', varargin ) )
    ix = find( strcmp( 'Fs', varargin ), 1, 'first' );
    Fs = varargin{ix + 1};
    varargin(ix:ix+1) = [];
    nIn = nIn - 2;
else
    % Default resampling at 1 kHz
    Fs = 1000;
end

if nargout ~= 1 && nargout ~= nargin
    error( 'The number of output arguments needs to be either 1 or as many as input matrices' )
end

if mod( nIn, 2 )
    error( 'You need to always specify a time and data pair.' )
end

time = cell( nIn / 2, 1 );
data = cell( nIn / 2, 1 );

cnt = 1;
for k = 1:2:nIn
    time{cnt} = varargin{k};
    data{cnt} = varargin{k+1};
    % Do some basic checks
    if ~isvector( time{cnt} ) && ~isempty( time{cnt} )
        error( 'The time needs to be specified as a vector.' )
    elseif length( time{cnt} ) ~= size( data{cnt}, 1 )
        error( 'Mismatch between the time and data length.' )
    end
    cnt = cnt + 1;
end

for k = 1:size( time, 1 )
    if isempty( time{k} ) || isempty( data{k} )
        % Do nothing
    else
        if any( diff( time{k} ) == 0 ) || any( isnan( time{k}(:, 1) ) )
            tmpIX = [ find( diff( time{k} ) == 0 ); ...
                find( isnan( time{k}(:, 1) ) )];
            time{k}(tmpIX) = [];
            data{k}(tmpIX, :) = [];
            disp( 'Found duplicate time stamps!' );
            disp( 'Ignoring data at those points.' );
        end
        data{k} = interp1( time{k}, data{k}, time{k}(1):1000/Fs:time{k}(end) );
        time{k} = time{k}(1):1000/Fs:time{k}(end);
        time{k} = time{k}(:);
    end
end

if nargout == nargin
    varargout = reshape( [data; time], 1, [] );
else
    varargout = { [time, data] };
end

end

