function Xi = interpBioMech( t, X, ti, k )

Q = angle2quat( X(:, 1), X(:, 2), X(:, 3), 'ZXY' );
Z = zeros( size( X ) );

if k == 61
    order = 'YXZ';
elseif any( [7 10 13 31 19 22 25 34 43 55] == k )
    order = 'XZY';
elseif any( [37 49] == k ) % clavicle
    order = 'YZX';
elseif any( [40 52] == k ) % shoulders
    order = 'YZY';
elseif any( [46 58] == k ) % wrists
    order = 'ZXY';
else
    order = 'YZX';
end

[Z(:, 1), Z(:, 2), Z(:, 3)] = quat2angle( Q, order );

Xi = angleInterp( t, deSwitch( Z ), ti, order );

%% Invert the process
Q = angle2quat( Xi(:, 1), Xi(:, 2), Xi(:, 3), order );
[Xi(:, 1), Xi(:, 2), Xi(:, 3)] = quat2angle( Q, 'ZXY' );

end