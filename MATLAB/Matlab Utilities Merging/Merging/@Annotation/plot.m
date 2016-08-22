function plot( A )

if isvector( A.Data )
    figure
    plot( A.Time, A.Data, '.' )
else
    figure
    imagesc( A.Time, 1:numel( A.EventMap.ActionMap ), A.Data' )
    colormap bone
end

end