function [data, time] = cleanData( G )
%% function data = cleanData( G )
% Attempts to remove dubious time points from data from the left hand glove
% in particular

%% Compute time estimate
meanFs = 139;
T0      = G.Time(1);
idealT  = (0:(numel( G.Time ) - 1)) * 1000 / meanFs;
realT   = G.Time - T0;
deltaT  = (idealT' - realT) / 1000 * meanFs;

%% Plot time estimate and ask user if anything should be corrected
fh = figure;
hold on
plot( deltaT )

s = input( 'Is the sampling rate constant? Y/[N] ', 's' );

if strcmpi( s, 'Y' )
    % Do nothing
else
    G.Time  = graphicSamplingRateCorrection( fh, deltaT, realT ) + T0;
    G.Fs    = 'Variable';
end

%% This is what an error looks like
errSpike    = [0 0.5 0.5 0];

%% Compute absolute first order difference (should show peaks in velocity)
absDiff     = sum( abs( diff( G.Data ) ), 2 ) ./ diff( G.Time );

%% Compute smoothed version of data
meanData    = fastsmooth( medfilt1( absDiff, 5 ), 21, 2, 1 );

%% Velocity - median filtered velocity should leave only spikes
res = xcorr( absDiff - medfilt1( absDiff, 5 ), errSpike );
res = res(numel( absDiff ):end); % Remove zeroes added by xcorr

%% Subtract local average
[~, locs] = findpeaks( res - meanData, 'MinPeakHeight', 0.5 );

%% Interpolate data as necessary
D = G.Data;
T = (1:size( D, 1 ))';
Tq = T;
T(locs+2) = [];
D(locs+2, :) = [];
D = interp1( T, D, Tq, 'Linear' );
T = Tq;

%% Smooth output (to remove A/D noise)
if any( isnan( D(:) ) )
    warning( 'Detected NaNs in data, smoothing could take forever...' );
end
D = multiSmooth( multiSmooth( multiSmooth( D, 11 ), 11 ), 11 ); % Gaussian filtering

%% Identify file breaks (if any)
ix_fb = find( strcmp( G.Events.ID, 'NewFile' ) );

%% Look for deviations from the average sampling rate
if strcmpi( s, 'Y' )
    T = G.Time;
    win     = 47;
    med_dT  = zeros( numel( ix_fb ) + 1, 1 );
    N       = zeros( numel( ix_fb ) + 1, 1 );
    
    if isempty( ix_fb )
        dT      = diff( T );
        dT_s    = smooth( diff( T ), win );
        med_dT  = median( dT_s );
        N       = numel( T );
    else
        dT = [];
        dT_s = [];
        for k = 1:numel( ix_fb )
            if k == 1
                ix_t = find( T < G.Events.Time(ix_fb(k)), 1, 'last' );
                dT = [dT; diff( T(1:ix_t) ); diff( T(ix_t:ix_t+1) )];
                dT_s = [dT_s; smooth( diff( T(1:ix_t) ), win ); diff( T(ix_t:ix_t+1) )];
                med_dT(k)   = median( smooth( diff( T(1:ix_t) ), win ) );
                N(k)        = ix_t;
            else
                ix_p = find( T > G.Events.Time(ix_fb(k-1)), 1, 'first' );
                ix_t = find( T < G.Events.Time(ix_fb(k)), 1, 'last' );
                dT = [dT; diff( T(ix_p:ix_t) )];
                dT_s = [dT_s; smooth( diff( T(ix_p:ix_t) ), win ); diff( T(ix_t:ix_t+1) )];
                med_dT(k) = median( smooth( diff( T(ix_p:ix_t) ), win ) );
                N(k)        = ix_t - ix_p + 1;
            end
        end
        dT = [dT; diff( T(ix_t+1:end) )];
        dT_s = [dT_s; smooth( diff( T(ix_t+1:end) ), win )];
        med_dT(k+1) = median( smooth( diff( T(ix_t+1:end) ), win ) );
        N(k+1)        = numel( T ) - ix_t + 1;
    end
    
    med_dT = sum( med_dT .* N ) / sum( N );
    
    %% Get locations of bad data
    ix_bad = logical( [medfilt1( double( abs( dT_s - med_dT ) > 0.5 ), 5 ); 0] );
    
    %% Re-estimate the sampling time
    med_dT = mean( dT_s(~ix_bad(1:end-1)) );
    
    %% Make new time array
    T_new = med_dT * (1:numel( T ))' + T(1);
    
    ix_down = find( diff( ix_bad ) == -1 );
    
    for k = 1:numel( ix_down )
        T_new(ix_down(k):end) = T_new(ix_down(k):end) + T(ix_down(k)) - T_new(ix_down(k));
    end
    
    T = T_new;
    
    %% Replace bad data with NaNs
    D(ix_bad, :)    = NaN;
    T(ix_bad)       = NaN;
end

%% Place back into G
G.Data = D;
G.Time = T;

%% Output if required
if nargout >= 1
    data = D;
elseif nargout == 2
    time = T;
end

end


function T = graphicSamplingRateCorrection( fh, T, rT )
%% Graphically find changes in sampling rate
flag = 1;
X = zeros( 100, 2 );
count = 1;

while flag
    if waitforbuttonpress
        if fh.CurrentCharacter == 32
            [X(count, 1), X(count, 2)] = ginput( 1 );
            X(count, 1) = round( X(count, 1) );
            X(count, 2) = T( X(count, 1) );
            plot( X(count, 1), X(count, 2), 'ok' )
            count = count + 1;
        elseif fh.CurrentCharacter == 27
            flag = 0;
            continue
        else
            continue
        end
    else
        continue
    end
end

%% Add first and last point if they were not selected
if ~any( X(:, 1) == 1 )
    X(count, 1) = 1;
    X(count, 2) = T(1);
    count = count + 1;
end

if ~any( X(:, 1) == size( T, 1 ) )
    X(count, 1) = size( T, 1 );
    X(count, 2) = T(end);
    count = count + 1;
end

%% Sort result
X = X(1:count-1, :);
X = sortrows( X, 1 );
[~, ix_u] = unique( X(:, 1) );
X = X(ix_u, :);

%% Eliminate missing frames - assuming diff( X(:, 1) ) == 1
ix_jump = find( diff( X(:, 1) ) == 1 );
nFrames = round( T(X(ix_jump+1, 1)) - T(X(ix_jump, 1)) );
for k = 1:numel( nFrames )
    T(X(ix_jump(k)+1, 1):end) = T(X(ix_jump(k)+1, 1):end) - nFrames(k);
end
T_jump = X(ix_jump+1);

%% Remove those indices from X
X(ix_jump+1, :) = [];

%% Set fitting parameters
ft = fittype( {'x'} );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Robust = 'Bisquare';

%% Fit sampling rate to each segment
deltaFs = zeros( size( X, 1 ) - 1, 1 );
for k = 1:size( X, 1 ) - 1
    if X(k+1, 1) - X(k, 1) == 1
        continue
    end
    Xf = rT(X(k, 1):X(k+1, 1)) - rT(X(k, 1));
    Yf = T(X(k, 1):X(k+1, 1)) - T(X(k, 1));
    fitresult = fit( Xf, Yf, ft, opts );
    deltaFs(k) = 1000 * fitresult.a;
end

%% Creat new ideal time vector
idealT_new = zeros( size( rT ) );
for k = 1:numel( deltaFs )
    if k > 1 && k < numel( deltaFs )
        idealT_new(X(k, 1):X(k+1, 1)-1) = (1:(X(k+1, 1)-X(k, 1))) * 1000 / (139 + deltaFs(k)) + ...
            idealT_new(X(k, 1)-1);
    elseif k == 1;
        idealT_new(X(k, 1):X(k+1, 1)) = (0:(X(k+1, 1)-X(k, 1))) * 1000 / (139 + deltaFs(k));
    else
        idealT_new(X(k, 1):X(k+1, 1)) = (1:(X(k+1, 1)-X(k, 1)+1)) * 1000 / (139 + deltaFs(k)) + ...
            idealT_new(X(k, 1)-1);
    end
end
idealT_new = [0; cumsum( smooth( diff( idealT_new ), 3 ) )];

%% Add jumps
for k = 1:numel( T_jump )
    %% Find corresponding sampling frequency
    locFs = 139 + deltaFs(find( X(:, 1) < T_jump(k), 1, 'last' ));
    %% Add jump to data
    idealT_new(T_jump(k):end) = idealT_new(T_jump(k):end) - nFrames(k) * 1000 / locFs;
end
deltaT_new = idealT_new - rT;

%% Plot again with updated sampling rate
figure
hold on
plot( deltaT_new / 1000 * (139 + mean( deltaFs )) )
plot( X(:, 1), deltaT_new(X(:, 1)), 'ok' )

T = idealT_new;
end