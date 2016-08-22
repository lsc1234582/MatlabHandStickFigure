function Di = removeJumps( D )

ix_jump = find( any( abs( diff( D ) ) > 50, 2 ) );
Tq = 1:size( D, 1 );
T = Tq;
T(ix_jump+1) = [];
D(ix_jump+1, :) = [];

Di = interp1( T, D, Tq, 'nearest' );

end