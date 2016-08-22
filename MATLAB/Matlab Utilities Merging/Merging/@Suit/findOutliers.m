function outliers = findOutliers( S )

if isa( S, 'Suit' )
    S = S.BioMechData;
end

% Determine path of file
locPath = mfilename( 'fullpath' );
locPath(strfind( locPath, '\findOutliers' )+1:end) = [];

load( [locPath 'OptimalJointFits.mat'] )

jNamesF = fieldnames( OptJointFits );
jNamesS = fieldnames( S );
if ~all( ismember( jNamesS, jNamesF ) )
    jNames  = intersect( jNamesF, jNamesS );
    warning( 'Order of fields may not be as expected' )
else
    jNames = jNamesS;
end

for k = 1:numel( jNames )
    rNamesF = fieldnames( OptJointFits.(jNames{k}) );
    rNamesS = fieldnames( S.(jNames{k}) );
    rNamesS = rNamesS(cellfun( @(x) isempty( strfind( x, 'All' ) ), rNamesS ));
    if ~all( ismember( rNamesS, rNamesF ) )
        rNames  = intersect( rNamesF, rNamesS );
        warning( 'Order of fields may not be as expected' )
    else
        rNames = rNamesS;
    end
    
    for l = 1:numel( rNames )
        if isempty( OptJointFits.(jNames{k}).(rNames{l}) )
            continue
        end
        X               = deSwitch( S.(jNames{k}).(rNames{l}), 'deg' );
        pdf.Function    = eval( OptJointFits.(jNames{k}).(rNames{l}).OptFun );
        pdf.Parameters  = OptJointFits.(jNames{k}).(rNames{l}).Params;
     %   outliers.(jNames{k}).(rNames{l}) = logLikTrace( X, pdf ) < log10( normpdf( 5, 0, 1 ) );
    end
    
end

end