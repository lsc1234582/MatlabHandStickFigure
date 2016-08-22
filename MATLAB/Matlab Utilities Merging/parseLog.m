function out = parseLog( filePath )

load( filePath )

% function out = parseLog( events )
T = Events.time;
E = Events.event;

% Check for size consistency
if any( size( T ) ~= size( E ) )
    disp( 'Error parsing log file.' )
    disp( 'The number of events and of timestamps does not match.' )
    out.map = [];
    out.actions = cell(0);
    return
end

% Remove any empty annotations and time stamps
ix = ~cellfun( @isempty, E );
T = T(ix);
E = E(ix);

% Give unique identifier to each event
[C, ~, rIX] = unique( E );
ID = 1:length( C );

for k = 1:length( C )
    if ~strcmpi( C{k}(end), 'S' )
        continue
    end
    action = C{k};
    action(end) = 'E';
    ix = strcmpi( action, C );
    ID(ix) = -ID(k);
end

uIX = unique( abs( ID ) );
eID = ID(rIX);

t = 0:0.1:roundn( T(end), -1 );
t = roundn( t, -1 ); % To compensate for numerical inaccuracies
out = nan( length( uIX ), length( t ) );

for k = 1:length( uIX )
    
    ixS = find( eID == uIX(k) );
    ixE = find( eID == -uIX(k) );
    
    if ~isempty( ixE ) && ~isempty( ixS )
        if length( ixS ) == length( ixE )
            for l = 1:length( ixS )
                tS = find( t == roundn( T(ixS(l)), -1 ) );
                tE = find( t == roundn( T(ixE(l)), -1 ) );
                out(k, tS:tE) = 1;
            end
        elseif length( ixS ) > length( ixE )
            % Find matching start and end times
            % Equivalent to finding closest start to end time
            ok_ = false( size( ixS ) );
            for l = 1:length( ixE )
                tmp = ixE(l) - ixS;
                tmp( tmp < 0 ) = Inf;   % Exclude starting points after the end
                [~, tmp] = min( tmp );
                ok_(tmp) = true;
            end
            ixS2 = ixS(ok_);
            for l = 1:length( ixS2 )
                tS = find( t == roundn( T(ixS2(l)), -1 ) );
                tE = find( t == roundn( T(ixE(l)), -1 ) );
                out(k, tS:tE) = 1;
            end
            
            ixS2 = ixS(~ok_);
            for l = 1:length( ixS2 )
                tS = find( t == roundn( T(ixS2(l)), -1 ) );
                out(k, tS) = 2;
            end
        else % if length( ixE ) > length( ixS )
            % Find matching start and end times
            ok_ = false( size( ixE ) );
            for l = 1:length( ixS )
                tmp = ixE - ixS(l);
                tmp( tmp < 0 ) = Inf;   % Exclude starting points after the end
                [~, tmp] = min( tmp );
                ok_(tmp) = true;
            end
            ixE2 = ixE(ok_);
            for l = 1:length( ixE2 )
                tS = find( t == roundn( T(ixS(l)), -1 ) );
                tE = find( t == roundn( T(ixE2(l)), -1 ) );
                out(k, tS:tE) = 1;
            end
            
            ixE2 = ixE(~ok_);
            for l = 1:length( ixE2 )
                tE = find( t == roundn( T(ixE2(l)), -1 ) );
                out(k, tE) = -2;
            end
        end
    elseif isempty( ixE )
        for l = 1:length( ixS )
            tS = find( t == roundn( T(ixS(l)), -1 ) );
            out(k, tS) = 3;
        end
    elseif isempty( ixS )
        for l = 1:length( ixE )
            tE = find( t == roundn( T(ixE(l)), -1 ) );
            out(k, tE) = -3;
        end
    end
end

actions = C(uIX);

tmp = out;
clearvars out

out.map = tmp;
out.actions = actions;

end