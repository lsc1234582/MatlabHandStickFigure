function map2DALIv2( A )

if size( A.EventMap.ActionMap, 1 ) ~= 53
    if size( A.EventMap.ActionMap, 1 ) == 76
        % Already using new version
        return
    else
        error( 'Incompatible recording, cannot convert to DALI v2.' )
    end
end

locPath = mfilename( 'fullpath' );
locPath(strfind( locPath, '\map2DALIv2' )+1:end) = [];

oldMap = A.EventMap.ActionMap;

% Edit some names
if strcmp( oldMap{28, 2}, 'PassObjectRequested' )
    oldMap{28, 2} = 'PassObject';
end

if strcmp( oldMap{36, 2}, 'ReorientObject' )
    oldMap{36, 2} = 'OrientObject';
end

[~, ~, ~, newMap] = Annotation.parseAnnotationXLS( [locPath 'AnnotationList.xlsx'] );
newMap = fliplr( newMap );

[ok_, ix] = ismember( oldMap(:, 2), newMap(:, 2) );

if all( ok_ )
    tmpData = zeros( size( A.Data, 1 ), size( newMap, 1 ) );
    tmpData(:, ix) = A.Data;
    A.Data = tmpData;
    A.EventMap.ActionMap = newMap;
end

end