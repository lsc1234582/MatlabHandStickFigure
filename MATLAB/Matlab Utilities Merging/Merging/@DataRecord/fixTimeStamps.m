function [allJumpIX, allJumpMag] = fixTimeStamps( DR )

%% Set window size depending on modality
if isa( DR, 'Suit' )
    win = 21;
    Fs  = 60;
elseif isa( DR, 'Glove' )
    if strcmp( DR.Hand, 'Right' )
        win = 31;
        Fs  = 90;
    elseif strcmp( DR.Hand, 'Left' )
        win = 47;
        Fs  = 139;
    end
else
    disp( 'Not yet implemented.' )
    return
end    

%% Get initial time
T0 = DR.Time(1);

%% Set some variables
meanFs = Fs;

idealT  = (0:(numel( DR.Time ) - 1)) * 1000 / meanFs;
realT   = DR.Time - T0;
deltaT  = medfilt1( (idealT' - realT) / 1000 * meanFs, win );
ddT     = diff( deltaT );

prevJump = 0;
allJumpMag = zeros( 100, 1 );
allJumpIX = zeros( 100, 1 );
count = 1;
ix_min = 0;

%%
% while any( abs( round( deltaT ) ) >= 1 )
while any( ddT <= -0.05 ) && ~isempty( prevJump ) && prevJump + 1 < numel( ddT )
    %% Identify location and magnitude of jump
%     ix_jump     = find( abs( round( deltaT(prevJump+1:end) ) ) >= 1, 1, 'first' ) + prevJump;
    ix_jump     = find( ddT(prevJump+1:end) <= -0.05, 1, 'first' ) + prevJump;
    if ~isempty( ix_jump )
        if ix_jump+win <= numel( ddT ) && any( ddT(ix_jump+1:ix_jump+win) ) < ddT(ix_jump)
            [~, ix_max] = min( ddT(ix_jump+1:ix_jump+win) );
            ix_jump = ix_jump + ix_max + 1;
        else
            ix_jump = ix_jump + 1;
        end
    end
    
    %% Check we didn't miss anything on the way
    if any( round( deltaT(prevJump+1:ix_jump-1) ) <= -1 )
        ix_jump = find( round( deltaT(prevJump+1:ix_jump) ) <= -1, 1, 'first' ) + prevJump;
        if ix_jump + win >= numel( deltaT )
            break
        end
        % Correct for variability in sampling rate
        avgWin = min( 10*win+1, ix_jump-1 );
        ix_new = find( round( deltaT(prevJump+1:ix_jump) - median( deltaT(ix_jump-avgWin:ix_jump-1) ) ) <= -1, 1, 'first' );
        if isempty( ix_new )
            prevJump = prevJump + ...
                0.75*find( round( deltaT(prevJump+1:end) - median( deltaT(ix_jump-avgWin:ix_jump-1) ) ) <= -1, 1, 'first' );
            prevJump = floor( prevJump );
            continue
        else
            ix_jump = ix_new + prevJump;
        end
        
        if any( deltaT(ix_jump+1:ix_jump+win) < deltaT(ix_jump) )
            [~, ix_min] = min( deltaT(ix_jump+1:ix_jump+win) );
            ix_jump = ix_jump + round( ix_min / 2 );
        end
    end
    
    if isempty( ix_jump )
        break
    end
    
    %% Plot (mainly for debugging)
    if ~exist( 'isPlot', 'var' ) || isPlot < count
        plot( deltaT )
        plot( ix_jump, deltaT(ix_jump), 'ok', 'MarkerFaceColor', 'k' )
        drawnow
        isPlot = count;
    end
    
    %% Now update sampling rate estimate
    if count == 1% && ix_jump < numel( ddT ) / 2
        if ix_jump < 3*win
            newFs       = meanFs + 0.9 * 1000 * mean( diff( deltaT(1:ix_jump-1) ) ) / mean( diff( realT(1:ix_jump-1) ) );
        else
            newFs       = meanFs + 0.9 * 1000 * mean( diff( deltaT(1:ix_jump-3*win) ) ) / mean( diff( realT(1:ix_jump-3*win) ) );
        end
    else%if ix_jump < numel( ddT ) / 2
        newFs       = meanFs + 0.9 * 1000 * mean( diff( deltaT(1:allJumpIX(count-1)) ) ) / mean( diff( realT(1:allJumpIX(count-1)) ) );
    end       
    
    idealT_new  = (0:(numel( DR.Time ) - 1)) * 1000 / newFs;

    %% Add all confirmed jumps
    for k = 1:count-1
        idealT_new(allJumpIX(k):end) = idealT_new(allJumpIX(k):end) - allJumpMag(k) * 1000 / newFs;
    end
    deltaT_new  = medfilt1( (idealT_new' - realT) / 1000 * newFs, win );
    ddT         = diff( deltaT_new );
    
    %% Check whether the new sampling rate makes sense
    if mean( ddT(1:round( numel( ddT ) / 10 )) ) > 0.3 / numel( ddT )
        newFs = meanFs;
        idealT_new  = (0:(numel( DR.Time ) - 1)) * 1000 / newFs;
        
        for k = 1:count-1
            idealT_new(allJumpIX(k):end) = idealT_new(allJumpIX(k):end) - allJumpMag(k) * 1000 / newFs;
        end
        deltaT_new  = medfilt1( (idealT_new' - realT) / 1000 * newFs, win );
        ddT         = diff( deltaT_new );
    end
    
    %% If the sampling frequency estimate is not stable, continue
    if abs( newFs - meanFs ) > 0.01
%         prevJump = ix_jump;
        deltaT = deltaT_new;
        idealT = idealT_new;
        meanFs = newFs;
        continue
    end
    
    %% If everything is OK so far, refine ix_jump by looking at the raw data
    avgWin = min( 10*win+1, ix_jump-1 );
    deltaT_fine     = medfilt1( (idealT_new' - realT), 3 ) / 1000 * newFs;
    deltaT_fine     = deltaT_fine - median( deltaT_fine(ix_jump-avgWin:ix_jump-1) );
    ix_lb           = max( ix_jump-win, prevJump+1 );
%     ixNew_jump      = find( round( deltaT_fine(ix_lb:ix_jump+win) ) <= -1, 1, 'first' );
    if ix_jump+win <= size( deltaT_fine, 1 )
        [~, ixNew_jump]      = min( diff( deltaT_fine(ix_lb:ix_jump+win) ) );
    else
        [~, ixNew_jump]      = min( diff( deltaT_fine(ix_lb:end) ) );
    end
    if isempty( ixNew_jump )
        prevJump = ix_jump;
        deltaT = deltaT_new;
        idealT = idealT_new;
        meanFs = newFs;
        continue
    end
    ix_jump         = ix_lb + ixNew_jump;
    
    if ~diff( realT(ix_jump-1:ix_jump) ) %% It's zero, empirically we missed it by 1
        ix_jump = ix_jump + 1;
    end
    
    %% Estimate frame loss
    frameJump   = round( deltaT_fine(ix_jump + floor( ix_min / 2 )) );
    ix_min = 0;
    
    if any( round( deltaT_new(ix_jump+1:end) ) == 0 ) % Just some really bad noise
        ix_ok       = find( round( deltaT_new(ix_jump+1:end) ) == 0, 1, 'last' ) - 1;
        prevJump    = ix_jump + round( 0.75 * ix_ok );
        idealT = idealT_new;
        deltaT = deltaT_new;
        meanFs = newFs;
        continue
    elseif frameJump == 0
        prevJump = ix_jump;
        deltaT = deltaT_new;
        idealT = idealT_new;
        meanFs = newFs;
        continue
    end
    
    %% Especially if we only miss one frame, the estimate of Fs might be off, let's recompute it with the data up to now
    if 0 && abs( frameJump ) <= 1
        newFs       = meanFs + 0.2 * 1000 * mean( diff( deltaT(1:ix_jump-win) ) ) / mean( diff( realT(1:ix_jump-win) ) )
        idealT_new  = (0:(numel( DR.Time ) - 1)) * 1000 / newFs;
        %% Add all confirmed jumps
        for k = 1:count-1
            idealT_new(allJumpIX(k):end) = idealT_new(allJumpIX(k):end) - allJumpMag(k) * 1000 / newFs;
        end
        deltaT_new  = medfilt1( (idealT_new' - realT) / 1000 * newFs, win );
        plot( deltaT_new )
        plot( ix_jump, deltaT_new(ix_jump), 'ok', 'MarkerFaceColor', 'k' )
        drawnow
        %% Check whether it would still fail under the new assumptions
        if round( deltaT_new(ix_jump) ) <= -1
            frameJump   = round( deltaT(ix_jump + win) );
        else
            if any( round( deltaT_new(ix_jump+1:end) ) == 0 ) % Just some really bad noise
                ix_ok       = find( round( deltaT_new(ix_jump+1:end) ) == 0, 1, 'last' );
                prevJump    = ix_jump + ix_ok;
                deltaT = deltaT_new;
                meanFs = newFs;
                continue
            else
                % If not, skip and try again
                deltaT = deltaT_new;
                idealT = idealT_new;
                meanFs = newFs;
                continue
            end
        end
    elseif frameJump > 1
        disp( 'Some extra data maybe?' )
        error()
    end
    
    %% If everything is OK, save and correct as possible
    allJumpIX(count) = ix_jump;
    allJumpMag(count) = frameJump;
    count = count + 1;
    
    %% If the loss rate is too high, give up
    if count > 2 && allJumpIX(count-1) - allJumpIX(count-2) < 1*win
        break
    end
    
    %% Correct time for jump
    meanFs = newFs;
    idealT = idealT_new;
    idealT(ix_jump:end) = idealT(ix_jump:end) - frameJump * 1000 / meanFs;
    deltaT  = medfilt1( idealT' - realT, win ) / 1000 * meanFs;
    
    %% Save jump time for next iteration
    prevJump    = ix_jump;
end

%% Reduce the vector of jumps
if count > 1
    allJumpIX = allJumpIX(1:count-1);
    allJumpMag = allJumpMag(1:count-1);
end

%% It's mostly safe to stop the data at the penultimate jump - edit accordingly
if 0 && numel( allJumpMag ) > 1
    DR.setField( 'Data', DR.Data(1:allJumpIX(end-1), :) );
    DR.setField( 'Time', idealT(1:allJumpIX(end-1))' + T0 );
else
    DR.setField( 'Data', DR.Data );
    DR.setField( 'Time', idealT' + T0 );
end

DR.setField( 'Fs', meanFs );

%% Update internal values in case of suit data
if isa( DR, 'Suit' )
    DR.BVH2BioMech();
end

end