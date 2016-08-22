function toMatrix( A )

if size( A.Data, 2 ) > 1
    % Already a matrix
    return
end

N = size( A.EventMap.ActionMap, 1 );

A.Data = bsxfun( @eq, repmat( A.Data, 1, N ), 1:N );

end