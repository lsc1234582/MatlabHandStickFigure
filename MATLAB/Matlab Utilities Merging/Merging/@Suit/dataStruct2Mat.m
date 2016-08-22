function [X, labels] = dataStruct2Mat( S )

if isa( S, 'Suit' )
    data = S.BioMechData;
else
    data = S;
end

if isempty( data )
    X = [];
    labels = [];
    return
end

jNames = fieldnames( data );
count = 1;

for k = 1:numel( jNames )
    rNames = fieldnames( data.(jNames{k}) );
    for l = 1:numel( rNames )
        if ~isempty( strfind( rNames{l}, 'All' ) )
            continue
        end
        X{count}        = data.(jNames{k}).(rNames{l});
        labels{count}   = [jNames{k} '_' rNames{l}];
        count = count + 1;
    end
end

X = cell2mat( X );

end