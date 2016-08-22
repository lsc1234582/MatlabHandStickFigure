function Xi = angleInterp( t, X, ti, order )

if any( diff( ti ) ) <= 0 || any( diff( t ) ) <= 0
    error( 'Time vectors must be strictly monotonously increasing' );
end

if ti(1) < t(1) || ti(end) > t(end)
    error( 'Extrapolation is not supported' )
end

% Transform angles into quaternions
Q = angle2quat( X(:, 1), X(:, 2), X(:, 3), order );
[r1, r2, r3] = quat2angle( Q, order );
R = deSwitch( [r1 r2 r3], 'rad' );
Q = angle2quat( R(:, 1), R(:, 2), R(:, 3), order );
Qi = zeros( numel( ti ), 4 );

% For each element in ti, find nearest two points in t
ix = zeros( numel( ti ), 2 );
for k = 1:numel( ti )
    ix(k, 1) = find( t - ti(k) <= 0, 1, 'last' );
    if t(ix(k, 1)) - ti(k) == 0     % Check for exact match
        continue
    else
        ix(k, 2) = ix(k, 1) + 1;    % Must be the next data point
    end
end

% Calculate fraction
tIX = ix(:, 2) ~= 0;
tFrac = ( ti(tIX) - t(ix(tIX, 1)) ) ./ ( t(ix(tIX, 2)) - t(ix(tIX, 1)) );

% Replace exact matches
Qi(~tIX, :) = Q(ix(~tIX, 1), :);

% Remove indices for exact matches
ix(~tIX, :) = [];

% Find nearest quaternions for the rest
Q1 = Q(ix(:, 1), :);
Q2 = Q(ix(:, 2), :);

%% Interpolate the quaternions
tmp = quatmultiply( quatinv( Q1 ), Q2 );

% Compute axis (n) and angle (theta)
n = sqrt( sum( tmp(:, 2:end) .^ 2, 2 ) );
theta = acos( tmp(:, 1) );
n = bsxfun( @rdivide, tmp(:, 2:end), n );

% Compute spherical linear interpolation
Qi(tIX, 1) = cos( tFrac .* theta );
Qi(tIX, 2:end) = bsxfun( @times, n, sin( tFrac .* theta ) );
Qi(tIX, :) = quatmultiply( Q1, Qi(tIX, :) );

[r1, r2, r3] = quat2angle( Qi, order );
Xi = [r1 r2 r3];


end