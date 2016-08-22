function Sync( E, Fs, mode )
%% function Sync( E, Fs, mode )
% Synchronises the data available in the Ethome structure.
%
% Inputs:
% <E>       Ethome to be synchronised.
%
% Optional inputs:
% <Fs>      Synchronisation sampling frequency.
%           Default is 100Hz.
%
% <mode>    TODO
%
% Written by Andreas Thomik, May 2015.

%% Check inputs
if nargin < 2 || isempty( Fs )
    Fs = 100;
end

if nargin < 3 || isempty( mode )
    mode = 1;
end

if mode == 1
    comSync( E, Fs );
elseif mode == 2
    uniSyncWill( E, Fs );
elseif mode == 3
    sync2Gaze( E );
elseif mode == 4
    s = input( 'This may take enormous amounts of memory, proceed? [N]/Y ', 's' );
    if strcmpi( s, 'Y' )
        uniSync( E, Fs, false );
    else
        disp( 'Setting mode to ''2''.' )
        mode = 2;
        uniSync( E, Fs, true );
    end
end

end

function uniSync( E, Fs, roundTime )
%% function uniSync( E, Fs, roundTime )
% Legacy synchronisation function. Redefines a new, common time vector for
% all modalities and interpolates to that
%
% If roundTime is true then the time vector is rounded to the nearest
% millisecond.

%% Set up variables
time = cell( 4, 1 );
mods = {'Gaze', 'RightHand', 'LeftHand', 'Suit'};
mIX = false( numel( mods ), 1 );

%% Get time information for each modality, if available
for k = 1:numel( mods )
    if ~isempty( E.(mods{k}) ) && ~isempty( E.(mods{k}).Time )
        if roundTime
            time{k} = round( E.(mods{k}).Time );
        else
            time{k} = E.(mods{k}).Time;
        end
        mIX(k) = true;
    else
        time{k} = NaN;
    end
end

%% Find start and end time
tStart = cellfun( @(x) x(1), time );
tEnd = cellfun( @(x) x(end), time );

[~, ixS] = min( tStart );
[~, ixE] = max( tEnd );

tStart  = tStart(ixS);
tEnd    = tEnd(ixE);

%% Generate new time vector from combination of new and old
T   = (tStart:round( 1000/Fs ):tEnd)';
oT  = cell2mat( time );
T   = unique( [oT; T] );
T(isnan( T )) = [];

%% Define new time vector
E.Time = T;

%% Compute size of new matrix and allocate memory
N = 0;
dataSize = zeros( numel( mods ), 1 );
for k = 1:numel( mods )
    if mIX(k)
        dataSize(k) = size( E.(mods{k}).Data, 2 );
        N = N + dataSize(k);
    end
end
E.Data  = nan( numel( E.Time ), N );
oData   = nan( numel( E.Time ), N );

for k = 1:numel( mods )
    if ~mIX(k)
        continue
    end
    ix_d        = (sum( dataSize(1:k-1) ) + 1):sum( dataSize(1:k) );
    [~, ix_t]   = ismember( time{k}, E.Time );
    ix_ok       = ix_t > 0;
    oData(ix_t(ix_ok), ix_d) = E.(mods{k}).Data(ix_ok, :);
end

%%
for k = 1:numel( mods )
    if ~mIX(k)
        continue
    end
    data    = E.(mods{k}).Data;
    t       = time{k};
    
    %% Find NaNs in data - remove those points
    ix_nan = any( isnan( data ), 2 ) | isnan( t );
    data(ix_nan, :) = [];
    t(ix_nan)       = [];
    
    %% Check for and remove duplicate time stamps
    dT = diff( t );
    if any( dT == 0 )
        warning( ['Found duplicate time stamps in ' mods{k} '. Ignoring that data.'] )
        t(dT == 0)          = [];
        data(dT == 0, :)    = [];
    end
    
    %% Avoid extrapolating by only interpolating data where there was something originally
    ixS = find( E.Time - t(1) >= 0, 1, 'first' );
    ixE = find( E.Time - t(end) <= 0, 1, 'last' );
    
    %% Interpolate data
    if ~strcmp( mods{k}, 'Suit' )
        iData = interp1( t, data, E.Time(ixS:ixE), 'pchip' );
    else
        data = data / 180 * pi; % Convert to radians for quaternion computation
        iData = zeros( numel( ixS:ixE ), size( data, 2 ) );
        for l = 1:3:66
            if ~any( roundn( data(:, l:l+2), -3 ) )
                continue
            elseif l == 1
                iData(:, l:l+2) = interp1( t, data(:, l:l+2), E.Time(ixS:ixE), 'pchip' );
            else
                iData(:, l:l+2) = angleInterp( t, data(:, l:l+2), E.Time(ixS:ixE), 'zxy' );
            end
        end
        iData = iData * 180 / pi; % Convert back to angles
    end
    
    if k == 1
        E.Data(ixS:ixE, 1:dataSize(k)) = iData;
    else
        dIX = (sum( dataSize(1:k-1) ) + 1):sum( dataSize(1:k) );
        E.Data(ixS:ixE, dIX) = iData;
    end
end

% Set new sampling time
E.Fs = 'Variable';

% Update data labels
E.makeDataLabels( mods(mIX) );

end


function uniSyncWill( E, Fs ) %syncs body to Fs then interleaves Gaze raw frames.
%% function comSync( E, Fs )
% Synchronisation to a common time stamp by interpolating across the original data.

%% Set up variables
time = cell( 4, 1 );
mods = {'Gaze', 'RightHand', 'LeftHand', 'Suit'};
mIX = false( numel( mods ), 1 );


% %% Get time information for each modality, if available
% for k = 1:numel( mods )
%     if ~isempty( E.(mods{k}) ) && ~isempty( E.(mods{k}).Time )
%         time{k} = E.(mods{k}).Time;
%         mIX(k) = true;
%     else
%         time{k} = NaN;
%     end
% end


%% Find sync points
if ~isempty(E.LeftHand.Events.Time)
    % if sum((diff(E.LeftHand.Events.Time(strcmp(E.LeftHand.Events.ID,'S')))>2))==0 % checks if IDs or actual time % updated to 2 as seemed to now have gaps of 2?!?
    try
        syncIds=strcmp(E.LeftHand.Events.ID,'S')
        
        syncIDGlove=E.LeftHand.Events.Time(syncIds(1));
        syncSysTimeGlove=E.LeftHand.Time(syncIDGlove);
        syncIDGaze=find(E.Gaze.Data(:,28)==1);
        syncSysTimeGaze=(E.Gaze.Time(syncIDGaze(1)-1)+E.Gaze.Time(syncIDGaze(1)))/2;
        timeGloveAhead=syncSysTimeGlove-syncSysTimeGaze;
        
    catch
        timeGloveAhead=0;
    end
    syncGazeTime=E.Gaze.Time+timeGloveAhead;
    % else
    %   error('In timestamp not index format')
    %end
    
end


%% Get time information for each modality, if available
if ~isempty( E.Gaze ) && ~isempty( E.Gaze.Time )
    try
        time{1} =syncGazeTime;% E.Gaze.Time;
    catch
        time{1} =E.Gaze.Time;
    end
    
    mIX(1) = true;
else
    time{1} = NaN;
end
if ~isempty( E.RightHand ) && ~isempty( E.RightHand.Time )
    time{2} = E.RightHand.Time;
    mIX(2) = true;
else
    time{2} = NaN;
end
if ~isempty( E.LeftHand ) && ~isempty( E.LeftHand.Time )
    time{3} = E.LeftHand.Time;
    mIX(3) = true;
else
    time{3} = NaN;
end
if ~isempty( E.Suit ) && ~isempty( E.Suit.Time )
    time{4} = E.Suit.Time;
    mIX(4) = true;
else
    time{4} = NaN;
end



%% Find start and end time
tStart = cellfun( @(x) x(1), time );
tEnd = cellfun( @(x) x(end), time );

[~, ixS] = min( tStart );
[~, ixE] = max( tEnd );

tStart  = tStart(ixS);
tEnd    = tEnd(ixE);

%% Define new time vector
E.Time = sort([(tStart:round( 1000/Fs ):tEnd)';time{1}],'ascend');
unsortedIndex(1:length((tStart:round( 1000/Fs ):tEnd)'))=1;
unsortedIndex(length((tStart:round( 1000/Fs ):tEnd)')+1:length((tStart:round( 1000/Fs ):tEnd)')+length(time{1}))=2;

[E.Time I]=sort([(tStart:round( 1000/Fs ):tEnd)';time{1}],'ascend');
sortedIndex=unsortedIndex(I');


%% Compute size of new matrix and allocate memory
N = 0;
dataSize = zeros( 4, 1 );
for k = 1:4
    if mIX(k)
        dataSize(k) = size( E.(mods{k}).Data, 2 );
        N = N + dataSize(k);
    end
end
E.Data = nan( numel( E.Time ), N );

%%
for k = 1:numel( mods )
    if ~mIX(k)
        continue
    end
    data = E.(mods{k}).Data;
    time = E.(mods{k}).Time;
    
    %% If they are not the same length, reduce to the shortest one
    minL = min( size( data, 1 ), size( time, 1 ) );
    data = data(1:minL, :);
    time = time(1:minL, :);
    
    %% If it is glove data, make sure it is smooth
    %     if ~isempty( strfind( mods{k}, 'Hand' ) )
    %         dD          = diff( data );
    %         dD(abs( dD ) == 0) = [];
    %         if mod( mode( abs( dD ) ), 1 ) == 0 % Not smoothed
    %             if any( isnan( data(:) ) )
    %                 warning( 'NaNs in un-smoothed data. Smoothing may take a very long time...' )
    %             end
    %             data = multiSmooth( multiSmooth( multiSmooth( data, 11 ), 11 ), 11 );
    %         end
    %     end
    
    %% Find NaNs in data - remove those points
    ix_nan = any( isnan( data ), 2 ) | isnan( time );
    data(ix_nan, :) = [];
    time(ix_nan)    = [];
    
    %% Check for, and remove,  duplicate time stamps
    dT = diff( time );
    if any( dT == 0 )
        warning( ['Found duplicate time stamps in ' mods{k} '. Ignoring that data.'] )
        time(dT == 0) = [];
        data(dT == 0, :) = [];
    end
    
    %%
    ixS = find( E.Time - time(1) >= 0, 1, 'first' );
    ixE = find( E.Time - time(end) <= 0, 1, 'last' );
    if ~strcmp( mods{k}, 'Suit' )
        if k==1 % Gaze
            %time= syncGazeTime;
            
            try
                syncIDGlove=E.LeftHand.Events.Time(1);
                syncSysTimeGlove=E.LeftHand.Time(syncIDGlove);
                syncIDGaze=find(E.Gaze.Data(:,28)==1);
                syncSysTimeGaze=(E.Gaze.Time(syncIDGaze(1)-1)+E.Gaze.Time(syncIDGaze(1)))/2;
                timeGloveAhead=syncSysTimeGlove-syncSysTimeGaze;
                
            catch % no sync info
                
                timeGloveAhead=0; % relies on NTP synch. This can be 10s of milliseconds out. may need to be adjusted by hand
                
            end
            
            syncGazeTime=time+timeGloveAhead;
            time=syncGazeTime;
            sysTime=interp1( time, data(:,1), E.Time(ixS:ixE), 'pchip' ); %sys time,eye frame, scene frame
            frNum= interp1( time, data(:,2:3), E.Time(ixS:ixE), 'nearest' ); %sys time,eye frame, scene frame
            noFrameNumIndex=find(data(:,3)>1e9);
            
            frNumDataRate=interp1( time(sum(isnan(data),2)==0), [data(noFrameNumIndex,3); (1:(sum((sum(isnan(data),2)==0))-numel(noFrameNumIndex)))'] , E.Time(ixS:ixE), 'nearest' ); %sys time,eye frame, scene frame
            
            
            
            rDat1 = InterpZeroCorrected( time, data(:,4:9), E.Time(ixS:ixE), 'pchip' ); % data
            rPupDat1=interp1( time, data(:,10:13), E.Time(ixS:ixE), 'nearest' );
            lDat1 = InterpZeroCorrected( time, data(:,14:21), E.Time(ixS:ixE), 'pchip' ); % data
            lPupDat1=interp1( time, data(:,22:25), E.Time(ixS:ixE), 'nearest' );
            bothDat1=InterpZeroCorrected( time, data(:,26:27), E.Time(ixS:ixE), 'pchip' ); % data
            
            evData= interp1( time, data(:,28), E.Time(ixS:ixE), 'nearest' ); % sync pnts
            
            IDFPupData=interp1( time, data(:,29:34), E.Time(ixS:ixE), 'pchip' ); %idf  data
            
            IDFDat=InterpZeroCorrected( time, data(:,35:52), E.Time(ixS:ixE), 'pchip' ); % data
            
            idfEvData=interp1( time, data(:,53:54), E.Time(ixS:ixE), 'nearest' ); % frame num, event info
            iData=[sysTime, frNum,rDat1,rPupDat1,lDat1,lPupDat1,bothDat1,evData,IDFPupData,IDFDat,idfEvData];
            
            gaps=find(diff(syncGazeTime)>500);
            if numel(gaps)>0
                
                for igap=1:numel(gaps)
                    startGapTime=syncGazeTime(gaps(igap));
                    [mStart,tIdStart]=min(abs(startGapTime-E.Time(ixS:ixE)))
                    endGapTime=syncGazeTime(gaps(igap)+1);
                    [mEnd,tIdEnd]=min(abs(endGapTime-E.Time(ixS:ixE)))
                    if (mStart<10)&(mEnd<10)
                        iData(tIdStart:tIdEnd,:)=nan;
                    else
                        error('something went wrong cutting out hole in interpolated data')
                    end
                end
                
            end
        else
            iData = interp1( time, data, E.Time(ixS:ixE), 'pchip' );
        end
    else
        data = data / 180 * pi; % Convert to radians for quaternion computation
        iData = zeros( numel( ixS:ixE ), size( data, 2 ) );
        for l = 1:3:66
            if ~any( roundn( data(:, l:l+2), -3 ) )
                continue
            elseif l == 1
                iData(:, l:l+2) = interp1( time, data(:, l:l+2), E.Time(ixS:ixE), 'pchip' );
            else
                %                 iData(:, l:l+2) = angleInterp( time, data(:, l:l+2), E.Time(ixS:ixE), 'zxy' );
                iData(:, l:l+2) = interpBioMech( time, data(:, l:l+2), E.Time(ixS:ixE), l );
            end
        end
        iData = iData * 180 / pi; % Convert back to angles
    end
    
    
    if k == 1
        E.Data(ixS:ixE, 1:dataSize(k)) = iData;
        E.FrNumDataRate(ixS:ixE)=frNumDataRate;
        
    else
        dIX = (sum( dataSize(1:k-1) ) + 1):sum( dataSize(1:k) );
        E.Data(ixS:ixE, dIX) = iData;
    end
end


E.DataInterpIndex=sortedIndex';

% Set new sampling time
E.Fs = Fs;

% Update data labels
E.makeDataLabels( mods(mIX) );

end







function sync2Gaze( E) %syncs body to Fs then interleaves Gaze raw frames.
%% function comSync( E, Fs )
% Synchronisation to a common time stamp by interpolating across the original data.

%% Set up variables
time = cell( 4, 1 );
mods = {'Gaze', 'RightHand', 'LeftHand', 'Suit'};
mIX = false( numel( mods ), 1 );


% %% Get time information for each modality, if available
% for k = 1:numel( mods )
%     if ~isempty( E.(mods{k}) ) && ~isempty( E.(mods{k}).Time )
%         time{k} = E.(mods{k}).Time;
%         mIX(k) = true;
%     else
%         time{k} = NaN;
%     end
% end


%% Find sync points
if ~isempty(E.LeftHand.Events.Time)
    % if sum((diff(E.LeftHand.Events.Time(strcmp(E.LeftHand.Events.ID,'S')))>2))==0 % checks if IDs or actual time % updated to 2 as seemed to now have gaps of 2?!?
    try
        syncIds=strcmp(E.LeftHand.Events.ID,'S')
        
        syncIDGlove=E.LeftHand.Events.Time(syncIds(1));
        syncSysTimeGlove=E.LeftHand.Time(syncIDGlove);
        syncIDGaze=find(E.Gaze.Data(:,28)==1);
        syncSysTimeGaze=(E.Gaze.Time(syncIDGaze(1)-1)+E.Gaze.Time(syncIDGaze(1)))/2;
        timeGloveAhead=syncSysTimeGlove-syncSysTimeGaze;
        
    catch
        timeGloveAhead=0;
    end
    syncGazeTime=E.Gaze.Time+timeGloveAhead;
    % else
    %   error('In timestamp not index format')
    %end
    
end


%% Get time information for each modality, if available
if ~isempty( E.Gaze ) && ~isempty( E.Gaze.Time )
    try
        time{1} =syncGazeTime(~isnan(syncGazeTime));% E.Gaze.Time;
    catch
        time{1} =E.Gaze.Time;
    end
    
    mIX(1) = true;
else
    time{1} = NaN;
end
if ~isempty( E.RightHand ) && ~isempty( E.RightHand.Time )
    time{2} = E.RightHand.Time(~isnan( E.RightHand.Time));
    mIX(2) = true;
else
    time{2} = NaN;
end
if ~isempty( E.LeftHand ) && ~isempty( E.LeftHand.Time )
    time{3} = E.LeftHand.Time(~isnan( E.LeftHand.Time));
    mIX(3) = true;
else
    time{3} = NaN;
end
if ~isempty( E.Suit ) && ~isempty( E.Suit.Time )
    time{4} = E.Suit.Time(~isnan( E.Suit.Time));
    mIX(4) = true;
else
    time{4} = NaN;
end



%% Find start and end time
tStart = cellfun( @(x) x(1), time );
tEnd = cellfun( @(x) x(end), time );

[~, ixS] = min( tStart );
[~, ixE] = max( tEnd );

tStart  = tStart(ixS);
tEnd    = tEnd(ixE);

%% Define new time vector
E.Time=[ (tStart:33:time{1}(1))' ; time{1}(2:end-1);  (time{1}(end):33:tEnd)' ]; % creates vector with gaze timestamp and 30Hz one either side to t
gaps=find(diff(E.Time)>500);
if numel(gaps)>0
    
    for igap=1:numel(gaps)
        gaps=find(diff(E.Time)>500);
        startGapTime=E.Time(gaps(1));
        [mStart,tIdStart]=min(abs(startGapTime-E.Time))
        endGapTime=E.Time(gaps(1)+1);
   
        E.Time=[E.Time(1:tIdStart,:);...
            E.Time(tIdStart)+cumsum(33*ones(numel(startGapTime:33:endGapTime),1));...
            E.Time(tIdStart+1:end,:)];
        
    end
    
end




%% Compute size of new matrix and allocate memory
N = 0;
dataSize = zeros( 4, 1 );
for k = 1:4
    if mIX(k)
        dataSize(k) = size( E.(mods{k}).Data, 2 );
        N = N + dataSize(k);
    end
end
E.Data = nan( numel( E.Time ), N );

%%
for k = 1:numel( mods )
    if ~mIX(k)
        continue
    end
    data = E.(mods{k}).Data;
    time = E.(mods{k}).Time;
    
    %% If they are not the same length, reduce to the shortest one
    minL = min( size( data, 1 ), size( time, 1 ) );
    data = data(1:minL, :);
    time = time(1:minL, :);
    
    %% If it is glove data, make sure it is smooth
    %     if ~isempty( strfind( mods{k}, 'Hand' ) )
    %         dD          = diff( data );
    %         dD(abs( dD ) == 0) = [];
    %         if mod( mode( abs( dD ) ), 1 ) == 0 % Not smoothed
    %             if any( isnan( data(:) ) )
    %                 warning( 'NaNs in un-smoothed data. Smoothing may take a very long time...' )
    %             end
    %             data = multiSmooth( multiSmooth( multiSmooth( data, 11 ), 11 ), 11 );
    %         end
    %     end
    
    %% Find NaNs in data - remove those points
    ix_nan = any( isnan( data ), 2 ) | isnan( time );
    data(ix_nan, :) = [];
    time(ix_nan)    = [];
    
    %% Check for, and remove,  duplicate time stamps
    dT = diff( time );
    if any( dT == 0 )
        warning( ['Found duplicate time stamps in ' mods{k} '. Ignoring that data.'] )
        time(dT == 0) = [];
        data(dT == 0, :) = [];
    end
    
    %%
    ixS = find( E.Time - time(1) >= 0, 1, 'first' );
    ixE = find( E.Time - time(end) <= 0, 1, 'last' );
    if ~strcmp( mods{k}, 'Suit' )
        if k==1 % Gaze
            %time= syncGazeTime;
            
            try
                syncIDGlove=E.LeftHand.Events.Time(1);
                syncSysTimeGlove=E.LeftHand.Time(syncIDGlove);
                syncIDGaze=find(E.Gaze.Data(:,28)==1);
                syncSysTimeGaze=(E.Gaze.Time(syncIDGaze(1)-1)+E.Gaze.Time(syncIDGaze(1)))/2;
                timeGloveAhead=syncSysTimeGlove-syncSysTimeGaze;
                
            catch % no sync info
                
                timeGloveAhead=0; % relies on NTP synch. This can be 10s of milliseconds out. may need to be adjusted by hand
                
            end
            
            syncGazeTime=time+timeGloveAhead;
            time=syncGazeTime;
            sysTime=interp1( time, data(:,1), E.Time(ixS:ixE), 'pchip' ); %sys time,eye frame, scene frame
            frNum= interp1( time, data(:,2:3), E.Time(ixS:ixE), 'nearest' ); %sys time,eye frame, scene frame
            noFrameNumIndex=find(data(:,3)>1e9);
            
            frNumDataRate=interp1( time(sum(isnan(data),2)==0), [data(noFrameNumIndex,3); (1:(sum((sum(isnan(data),2)==0))-numel(noFrameNumIndex)))'] , E.Time(ixS:ixE), 'nearest' ); %sys time,eye frame, scene frame
            
            
            
            rDat1 = InterpZeroCorrected( time, data(:,4:9), E.Time(ixS:ixE), 'pchip' ); % data
            rPupDat1=interp1( time, data(:,10:13), E.Time(ixS:ixE), 'nearest' );
            lDat1 = InterpZeroCorrected( time, data(:,14:21), E.Time(ixS:ixE), 'pchip' ); % data
            lPupDat1=interp1( time, data(:,22:25), E.Time(ixS:ixE), 'nearest' );
            bothDat1=InterpZeroCorrected( time, data(:,26:27), E.Time(ixS:ixE), 'pchip' ); % data
            
            evData= interp1( time, data(:,28), E.Time(ixS:ixE), 'nearest' ); % sync pnts
            
            IDFPupData=interp1( time, data(:,29:34), E.Time(ixS:ixE), 'pchip' ); %idf  data
            
            IDFDat=InterpZeroCorrected( time, data(:,35:52), E.Time(ixS:ixE), 'pchip' ); % data
            
            idfEvData=interp1( time, data(:,53:54), E.Time(ixS:ixE), 'nearest' ); % frame num, event info
            iData=[sysTime, frNum,rDat1,rPupDat1,lDat1,lPupDat1,bothDat1,evData,IDFPupData,IDFDat,idfEvData];
            gaps=find(diff(syncGazeTime)>500);
            if numel(gaps)>0
                for igap=1:numel(gaps)
                    startGapTime=syncGazeTime(gaps(igap));
                    [mStart,tIdStart]=min(abs(startGapTime-E.Time(ixS:ixE)))
                    endGapTime=syncGazeTime(gaps(igap)+1);
                    [mEnd,tIdEnd]=min(abs(endGapTime-E.Time(ixS:ixE)))
                    if (mStart<10)&(mEnd<10)
                        iData(tIdStart:tIdEnd,:)=nan;
                    else
                        error('something went wrong cutting out hole in interpolated data')
                    end
                end   
            end
    
        else
            iData = interp1( time, data, E.Time(ixS:ixE), 'pchip' );
        end
    else
        data = data / 180 * pi; % Convert to radians for quaternion computation
        iData = zeros( numel( ixS:ixE ), size( data, 2 ) );
        for l = 1:3:66
            if ~any( roundn( data(:, l:l+2), -3 ) )
                continue
            elseif l == 1
                iData(:, l:l+2) = interp1( time, data(:, l:l+2), E.Time(ixS:ixE), 'pchip' );
            else
                %                 iData(:, l:l+2) = angleInterp( time, data(:, l:l+2), E.Time(ixS:ixE), 'zxy' );
                iData(:, l:l+2) = interpBioMech( time, data(:, l:l+2), E.Time(ixS:ixE), l );
            end
        end
        iData = iData * 180 / pi; % Convert back to angles
    end
    
    
    if k == 1
        E.Data(ixS:ixE, 1:dataSize(k)) = iData;
        E.FrNumDataRate(ixS:ixE)=frNumDataRate;
        
    else
        dIX = (sum( dataSize(1:k-1) ) + 1):sum( dataSize(1:k) );
        E.Data(ixS:ixE, dIX) = iData;
    end
end



% Update data labels
E.makeDataLabels( mods(mIX) );

end




function comSync( E, Fs )
%% function comSync( E, Fs )
% Synchronisation to a common time stamp by interpolating across the original data.

%% Set up variables
time = cell( 4, 1 );
mods = {'Gaze', 'RightHand', 'LeftHand', 'Suit'};
mIX = false( numel( mods ), 1 );


% %% Get time information for each modality, if available
% for k = 1:numel( mods )
%     if ~isempty( E.(mods{k}) ) && ~isempty( E.(mods{k}).Time )
%         time{k} = E.(mods{k}).Time;
%         mIX(k) = true;
%     else
%         time{k} = NaN;
%     end
% end


%% Find sync points
if ~isempty(E.LeftHand.Events.Time)
    % if sum((diff(E.LeftHand.Events.Time(strcmp(E.LeftHand.Events.ID,'S')))>2))==0 % checks if IDs or actual time % updated to 2 as seemed to now have gaps of 2?!?
    try
        syncIds=strcmp(E.LeftHand.Events.ID,'S')
        
        syncIDGlove=E.LeftHand.Events.Time(syncIds(1));
        syncSysTimeGlove=E.LeftHand.Time(syncIDGlove);
        syncIDGaze=find(E.Gaze.Data(:,28)==1);
        syncSysTimeGaze=(E.Gaze.Time(syncIDGaze(1)-1)+E.Gaze.Time(syncIDGaze(1)))/2;
        timeGloveAhead=syncSysTimeGlove-syncSysTimeGaze;
        
    catch
        timeGloveAhead=0;
    end
    syncGazeTime=E.Gaze.Time+timeGloveAhead;
    % else
    %   error('In timestamp not index format')
    %end
    
end


%% Get time information for each modality, if available
if ~isempty( E.Gaze ) && ~isempty( E.Gaze.Time )
    try
        time{1} =syncGazeTime;% E.Gaze.Time;
    catch
        time{1} =E.Gaze.Time;
    end
    
    mIX(1) = true;
else
    time{1} = NaN;
end
if ~isempty( E.RightHand ) && ~isempty( E.RightHand.Time )
    time{2} = E.RightHand.Time;
    mIX(2) = true;
else
    time{2} = NaN;
end
if ~isempty( E.LeftHand ) && ~isempty( E.LeftHand.Time )
    time{3} = E.LeftHand.Time;
    mIX(3) = true;
else
    time{3} = NaN;
end
if ~isempty( E.Suit ) && ~isempty( E.Suit.Time )
    time{4} = E.Suit.Time;
    mIX(4) = true;
else
    time{4} = NaN;
end



%% Find start and end time
tStart = cellfun( @(x) x(1), time );
tEnd = cellfun( @(x) x(end), time );

if isnan(tStart)| isnan(tEnd)
    error('nan start or end time issue')
end

[~, ixS] = min( tStart );
[~, ixE] = max( tEnd );

tStart  = tStart(ixS);
tEnd    = tEnd(ixE);

%% Define new time vector
E.Time = (tStart:round( 1000/Fs ):tEnd)';

%% Compute size of new matrix and allocate memory
N = 0;
dataSize = zeros( 4, 1 );
for k = 1:4
    if mIX(k)
        dataSize(k) = size( E.(mods{k}).Data, 2 );
        N = N + dataSize(k);
    end
end
E.Data = nan( numel( E.Time ), N );

%%
for k = 1:numel( mods )
    if ~mIX(k)
        continue
    end
    data = E.(mods{k}).Data;
    time = E.(mods{k}).Time;
    
    %% If they are not the same length, reduce to the shortest one
    minL = min( size( data, 1 ), size( time, 1 ) );
    data = data(1:minL, :);
    time = time(1:minL, :);
    
    %% If it is glove data, make sure it is smooth
    %     if ~isempty( strfind( mods{k}, 'Hand' ) )
    %         dD          = diff( data );
    %         dD(abs( dD ) == 0) = [];
    %         if mod( mode( abs( dD ) ), 1 ) == 0 % Not smoothed
    %             if any( isnan( data(:) ) )
    %                 warning( 'NaNs in un-smoothed data. Smoothing may take a very long time...' )
    %             end
    %             data = multiSmooth( multiSmooth( multiSmooth( data, 11 ), 11 ), 11 );
    %         end
    %     end
    
    %% Find NaNs in data - remove those points
    ix_nan = any( isnan( data ), 2 ) | isnan( time );
    data(ix_nan, :) = [];
    time(ix_nan)    = [];
    
    %% Check for, and remove,  duplicate time stamps
    dT = diff( time );
    if any( dT == 0 )
        warning( ['Found duplicate time stamps in ' mods{k} '. Ignoring that data.'] )
        time(dT == 0) = [];
        data(dT == 0, :) = [];
    end
    
    %%
    ixS = find( E.Time - time(1) >= 0, 1, 'first' );
    ixE = find( E.Time - time(end) <= 0, 1, 'last' );
    if ~strcmp( mods{k}, 'Suit' )
        if k==1 % Gaze
            %time= syncGazeTime;
            
            try
                syncIDGlove=E.LeftHand.Events.Time(1);
                syncSysTimeGlove=E.LeftHand.Time(syncIDGlove);
                syncIDGaze=find(E.Gaze.Data(:,28)==1);
                syncSysTimeGaze=(E.Gaze.Time(syncIDGaze(1)-1)+E.Gaze.Time(syncIDGaze(1)))/2;
                timeGloveAhead=syncSysTimeGlove-syncSysTimeGaze;
                
            catch % no sync info
                
                timeGloveAhead=0; % relies on NTP synch. This can be 10s of milliseconds out. may need to be adjusted by hand
                
            end
            
            syncGazeTime=time+timeGloveAhead;
            time=syncGazeTime;
            sysTime=interp1( time, data(:,1), E.Time(ixS:ixE), 'pchip' ); %sys time,eye frame, scene frame
            frNum= interp1( time, data(:,2:3), E.Time(ixS:ixE), 'nearest' ); %sys time,eye frame, scene frame
            noFrameNumIndex=find(data(:,3)>1e9);
            
            frNumDataRate=interp1( time(sum(isnan(data),2)==0), [data(noFrameNumIndex,3); (1:(sum((sum(isnan(data),2)==0))-numel(noFrameNumIndex)))'] , E.Time(ixS:ixE), 'nearest' ); %sys time,eye frame, scene frame
            
            
            
            rDat1 = InterpZeroCorrected( time, data(:,4:9), E.Time(ixS:ixE), 'pchip' ); % data
            rPupDat1=interp1( time, data(:,10:13), E.Time(ixS:ixE), 'nearest' );
            lDat1 = InterpZeroCorrected( time, data(:,14:21), E.Time(ixS:ixE), 'pchip' ); % data
            lPupDat1=interp1( time, data(:,22:25), E.Time(ixS:ixE), 'nearest' );
            bothDat1=InterpZeroCorrected( time, data(:,26:27), E.Time(ixS:ixE), 'pchip' ); % data
            
            evData= interp1( time, data(:,28), E.Time(ixS:ixE), 'nearest' ); % sync pnts
            
            IDFPupData=interp1( time, data(:,29:34), E.Time(ixS:ixE), 'pchip' ); %idf  data
            
            IDFDat=InterpZeroCorrected( time, data(:,35:52), E.Time(ixS:ixE), 'pchip' ); % data
            
            idfEvData=interp1( time, data(:,53:54), E.Time(ixS:ixE), 'nearest' ); % frame num, event info
            iData=[sysTime, frNum,rDat1,rPupDat1,lDat1,lPupDat1,bothDat1,evData,IDFPupData,IDFDat,idfEvData];
            
            gaps=find(diff(syncGazeTime)>500);
            if numel(gaps)>0
                for igap=1:numel(gaps)
                    startGapTime=syncGazeTime(gaps(igap));
                    [mStart,tIdStart]=min(abs(startGapTime-E.Time(ixS:ixE)))
                    endGapTime=syncGazeTime(gaps(igap)+1);
                    [mEnd,tIdEnd]=min(abs(endGapTime-E.Time(ixS:ixE)))
                    if (mStart<10)&(mEnd<10)
                        iData(tIdStart:tIdEnd,:)=nan;
                    else
                        error('something went wrong cutting out hole in interpolated data')
                    end
                end   
            end
            
            
        else
            iData = interp1( time, data, E.Time(ixS:ixE), 'pchip' );
        end
    else
        data = data / 180 * pi; % Convert to radians for quaternion computation
        iData = zeros( numel( ixS:ixE ), size( data, 2 ) );
        for l = 1:3:66
            if ~any( roundn( data(:, l:l+2), -3 ) )
                continue
            elseif l == 1
                iData(:, l:l+2) = interp1( time, data(:, l:l+2), E.Time(ixS:ixE), 'pchip' );
            else
                %                 iData(:, l:l+2) = angleInterp( time, data(:, l:l+2), E.Time(ixS:ixE), 'zxy' );
                iData(:, l:l+2) = interpBioMech( time, data(:, l:l+2), E.Time(ixS:ixE), l );
            end
        end
        iData = iData * 180 / pi; % Convert back to angles
    end
    
    if k == 1
        E.Data(ixS:ixE, 1:dataSize(k)) = iData;
        E.FrNumDataRate(ixS:ixE)=frNumDataRate;
        
    else
        dIX = (sum( dataSize(1:k-1) ) + 1):sum( dataSize(1:k) );
        E.Data(ixS:ixE, dIX) = iData;
    end
end

% Set new sampling time
E.Fs = Fs;

% Update data labels
E.makeDataLabels( mods(mIX) );

end