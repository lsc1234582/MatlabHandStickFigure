function toVector( A )

if size( A.Data, 2 ) == 1
    % Already a vector
    return
end

N = size( A.EventMap.ActionMap, 1 );

if strcmp( A.AnnotationMethod, 'LogING' )
    warning( 'This may lead to data loss. Proceed? [Y]/N' );
    s = input( ' ', 's' );
    if ~strcmpi( s, 'Y' )
        return
    end
    tmp = bsxfun( @times, A.Data, 1:N );
    A.Data = nan( size( tmp, 1 ), 1 );
    for k = 1:size( tmp, 1 )
        ix = isfinite( tmp(k, :) );
        if sum( ix ) > 1
            if k == 1 || isnan( A.Data(k-1) )
                A.Data(k) = tmp(k, find( ix, 1, 'first' ));
            elseif any( find( ix ) == A.Data(k-1) )
                A.Data(k) = A.Data(k-1);
            else
                A.Data(k) = tmp(k, find( ix, 1, 'first' ));
            end
        elseif sum( ix ) == 1
            A.Data(k) = tmp(k, ix);
        end
    end
else
    tmp = bsxfun( @times, A.Data, 1:N );
    A.Data = nansum( tmp, 2 );
end

end