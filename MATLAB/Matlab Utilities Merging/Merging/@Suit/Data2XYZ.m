function out = Data2XYZ( S )
% function out = Data2XYZ( S )
% Computes endpoint coordinates for limbs

if ~isempty( S.xyzData )
    out = S.xyzData;
    return
end

skel = S.Skel;
channels = S.Data;
%channels(:, [1 3 4:6]) = 0;
N = size( channels, 1 );

xyzStruct = struct( 'rotation', [], 'xyz', [] );
xyzStruct = repmat( xyzStruct, numel( skel.tree ), 1 );

for i = 1:length(skel.tree)
    if i==24
        i
    end
    if ~isempty( skel.tree(i).posInd )
        xpos = channels(:, skel.tree(i).posInd(1));
        ypos = channels(:, skel.tree(i).posInd(2));
        zpos = channels(:, skel.tree(i).posInd(3));
    else
        xpos = 0;
        ypos = 0;
        zpos = 0;
    end
    
    if isempty( skel.tree(i).rotInd )
        xangle = zeros( N, 1 );
        yangle = zeros( N, 1 );
        zangle = zeros( N, 1 );
    else
        xangle = channels(:, skel.tree(i).rotInd(1)) / 180 * pi;
        yangle = channels(:, skel.tree(i).rotInd(2)) / 180 * pi ;
        zangle = channels(:, skel.tree(i).rotInd(3)) / 180 * pi ;
    end
    
    if ~isempty( skel.tree(i).order )
        thisRotation = angle2dcm( zangle, xangle, yangle, skel.tree(i).order );
    else
        thisRotation = angle2dcm( zangle, xangle, yangle, 'ZXY' );
    end
    thisPosition = [xpos ypos zpos];
    
    if ~skel.tree(i).parent
        xyzStruct(i).rotation = thisRotation;
        xyzStruct(i).xyz = bsxfun( @plus, thisPosition, skel.tree(i).offset );
    else
        pR = num2cell( xyzStruct(skel.tree(i).parent).rotation, [1 2] );
        tR = num2cell( thisRotation, [1 2] );
        
        tmp = cellfun( @(x) bsxfun( @plus, thisPosition, skel.tree(i).offset ) * x, pR, 'UniformOutput', false );
        tmp = squeeze( cell2mat( tmp ) )';
        xyzStruct(i).xyz = bsxfun( @plus, tmp, xyzStruct(skel.tree(i).parent).xyz );
        
        tmp = squeeze( cellfun( @(x, y) (x * y)', tR, pR, 'UniformOutput', false ) );
        tmp = reshape( cell2mat( tmp )', 3, 3, [] );
        xyzStruct(i).rotation = tmp;
        
    end
    
end

names = arrayfun( @(x) x.name, skel.tree, 'UniformOutput', false );
ix = strcmp( names, 'Site' );
names(ix) = [];
xyzStruct(ix) = [];
%xyzStruct = rmfield( xyzStruct, 'rotation' );

out = struct();
for l = 1:numel( names )
    out.(names{l}).xyz      = xyzStruct(l).xyz;
    out.(names{l}).rotation = xyzStruct(l).rotation;
end

S.xyzData = out;
