function [ varargout ] = getMilliSecondTime( varargin )
% function [ O1, O2, ... ] = getMilliSecondTime( I1, I2, ... )
% Takes arrays of time stamps in the hh:mm:ss.sss format and returns the
% time-difference between the earliest time and the time stamp in
% milliseconds
%
% Inputs:
% <I1, I2, ...> Nx4 matrices of time stamps in the following format:
%                   [ hours, minutes, seconds, milliseconds ]
% 
% Outputs:
% <O1, O2, ...> Nx1 vectors of time-difference in milliseconds.
%               Note 1: if there are multiple input matrices, the
%               time-difference is computed with the earliest time across
%               all inputs.
%               Note 2: you need to define as many output variables as
%               there are input variables, therfore:
%                   A = getMilliSecondTime( X, Y )
%               will return an error.
%               Correct usage would be:
%                   [A, B] = getMilliSecondTime( X, Y )
% 
% NOTE: Empty input matrices will be ignored.
%
% Written by Andreas Thomik, August 2013.

%% Get number of inputs & outputs
nIn = nargin;
nOut = nargout;

if nOut ~= nIn
    error( 'You need to specify as many output variables as input variables.' );
end

%% Define maximal realistic time vector
tMax = [23 59 59 999];

%% Check that all inputs are ok
for k = 1:nIn
    if any( any( bsxfun( @gt, varargin{k}, tMax ) ) )
        error( 'Invalid time stamp' );
    end
end

%% Transform time
varargout = cell( nOut, 1 );
ok_ = true( nIn, 1 );

% Get earliest recording time if more than one recording is specified
if nargin >= 1
    t0 = [0 0 0 0]; % Set initial time to midnight.
    % Get first time stamp for all
    for k = 1:nIn
        if isempty( varargin{k} )
            ok_(k) = false;
        else
        end
    end
else
    if ~isempty( varargin{1} )
        t0 = [0 0 0 0]; % Set initial time to midnight.
    else
        error( 'No data was provided' );
    end
end

for k = 1:nIn
    if ok_(k)
        tRel = bsxfun( @minus, varargin{k}, t0 );
        tRel = bsxfun( @times, tRel, [3.6e6, 6e4, 1e3, 1] );
        tRel = sum( tRel, 2 );
        varargout{k} = tRel;
    else
        varargout{k} = [];
    end
end

end