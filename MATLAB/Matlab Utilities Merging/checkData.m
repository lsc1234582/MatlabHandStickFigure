function info = checkData( dBEntry, dB_ )

info = struct(  'DataExists', 0,...         % Boolean - Is the data there?
                'NumFiles', NaN, ...        % Number of files for modality
                'Dimensions', NaN, ...      % Dimensionality of the data
                'NumDatPoints', NaN, ...    % Number of data points
                'NumBackTracking', NaN, ... % Continuous time stamps?
                'NumDuplicateTime', NaN, ...% Number of duplicate time stamps
                'NumDatGaps',NaN,...        % Number of timestamp gaps greater than 5*MeanSampPeriod
                'MeanSampPeriod', NaN, ...  % Mean sampling period in milliseconds
                'SDSampPeriod', NaN, ...    % SD of sampling period in milliseconds
                'NumSyncPoints', NaN, ...   % Number of sync points
                'NumCalibPoints', NaN, ...  % Number of times the subject looks at his wrist
                'RecordingDuration',NaN,... % Recording Duration in minutes from start to end
                'Comments', {''} );         % User provided comments

% There is data
info.DataExists = 1;

% Check number of files
info.NumFiles = dBEntry.FileCount;

% Load data
data = [];
time = [];
id   = {};
nTimeFiles  = 0;
timeBreakIX = [];

FileType = dBEntry.FileType;

dBEntry = GetFirstInChain( dBEntry, dB_ );

for k = 1:info.NumFiles
    switch dBEntry.FileType
        case 'SuitData'
            [tmpD, ~] = parseEthomics( dBEntry.FileName, 'suitData' );
            data = [data; tmpD];
            
            if dBEntry.hasTime % Check for timestamp availability
                tData = getEntries( dBEntry.linkedFiles, 'FileName', @(x) strcmp( x.FileType, 'SuitTime' ) );
                [~, tmpT] = parseEthomics( tData{1}, 'suitTime' );
                time = [time; tmpT];
                nTimeFiles = nTimeFiles + 1;
            else
                time = [time; nan( size( tmpD, 1 ), 1 )];
            end
            
            if size( time, 1 ) < size( data, 1 ) % We are lacking some time stamps
                dT = size( data, 1 ) - size( time, 1 );
                time = [time; nan( dT, 1 )];
            else
                disp( 'Not sure what to do with this...' )
                % TODO
            end
                
            id = [id; num2cell( nan( size( tmpD, 1 ), 1 ) )];
        case {'RightHandData', 'LeftHandData'}
            if strcmpi( dBEntry.FileType, 'RightHandData' )
                [tmpD, tmpT, ID] = parseEthomics( dBEntry.FileName, 'rightHand', false );
            elseif strcmpi( dBEntry.FileType, 'LeftHandData' )
                [tmpD, tmpT, ID] = parseEthomics( dBEntry.FileName, 'leftHand', false );
            end
            data = [data; tmpD];
            if ~isempty( tmpT )
                time = [time; tmpT];
                nTimeFiles = nTimeFiles + 1;
            else
                time = [time; nan( size( tmpD, 1 ), 4 )];
            end
            
            if ~isempty( ID )
                id = [id; ID];
            else
                id = [id; num2cell( nan( size( tmpD, 1 ), 1 ) )];
            end
        case 'GazeData'
            tmpGazeData = parseGazeTXT( dBEntry.FileName );
            if ~isempty( tmpGazeData )
                data = [data; tmpGazeData];
                systemTime = getMilliSecondTime( tmpGazeData(:, 1:4) ); % puts into nanosecs like server time
                serverTime = tmpGazeData(:, 5) / 1e6;
                tmpT = serverTime - serverTime(1) + systemTime(1);
                time = [time ;tmpT];
            end
        case 'ActivityLog'
            if strcmp( dBEntry.logSoftware, 'DALI' )
                tmp = annotationParse( dBEntry.FileName, dBEntry.RecordDate );
                % Sort out time stamps
                tmpT = tmp.Time;
                tmpT(:, 1) = tmpT(:, 1) - 1; % Align on C/C++ time stamps
                tmpT = getMilliSecondTime( tmpT );
                time = [time ;tmpT];
                % Sort out annotations
                data = [data; tmp.ID];
                id = [id; num2cell( nan( size( tmp.ID ) ) )];
            elseif strcmp( dBEntry.logSoftware, 'logING' )
               % TODO
            else
               disp( 'Unknown logging software, cannot help you here, sorry!' )
            end
            nTimeFiles = nTimeFiles + 1;
            info.Comments = 'Values regarding the sampling rate are just an indication the frequency of annotations.';
        otherwise
            
    end
    timeBreakIX = [timeBreakIX size( time, 1 )];
    dBEntry = getEntries( dB_, [], @(x) strcmp( x.FileName, dBEntry.nextFile ) );
end

if ~strcmp( FileType, 'GazeData' )
    % If we don't have any time stamps, most of this is irrelevant
    if nTimeFiles == 0
        info.NumBackTracking    = NaN;
        info.NumDuplicateTime   = NaN;
        info.MeanSampPeriod     = NaN;
        info.SDSampPeriod       = NaN;
        info.NumSyncPoints      = NaN;
        info.NumCalibPoints     = NaN;
        info.Comments           = 'No time stamps available';
        return
    elseif nTimeFiles < info.NumFiles
        info.Comments           = ['Time stamps available for only ' num2str( nTimeFiles ) ' out of ' num2str( info.NumFiles ) ' files.'];
    end
    
    % Remove timestamps with different IDs
    ix = cellfun( @isnan, id ) | strcmpi( id, 'D' );
    data = data(ix, :);
    time = time(ix, :);
    % If there are time stamps
    T = time;
    
    if any( isnan( T ) ) && strcmp( FileType, 'RightHandData' )
        ix = find( isnan( T ) );
        id(ix) = {'S'};
        data(ix, :) = [];
        T(ix) = [];
    end
    
    ix = strcmpi( id, 'S' );
    info.NumSyncPoints      = sum( ix );

    info.NumCalibPoints     = 0;
else
    T = time;
    info.NumSyncPoints      = sum( data(:, 32) == 1 );
    info.NumCalibPoints     = sum( diff( ( data(:,32) == 2 ) ) > 0 );
    info.Comments           = 'There are actually two timestamps associated with this data set: system time (to sync with other sensor modalities) and server time (local gazeTracker server). Here I have assesed on server time.';
end

info.Dimensions     = size( data, 2 );
info.NumDatPoints   = size( data, 1 );

dT = diff( T );

% Check that the time stamps don't jump back
if all( dT >= 0 )
    info.NumBackTracking = 0;
else
    info.NumBackTracking = sum( dT < 0 );
end

% Check for duplicate time stamps
if any( dT == 0 )
    info.NumDuplicateTime = sum( dT == 0 );
else
    info.NumDuplicateTime = 0;
end

% Remove jumps between files prior to calculating mean and std
if info.NumFiles > 1
    dT(timeBreakIX(1:end-1)+1) = [];
end
info.MeanSampPeriod     = mean( dT );
info.SDSampPeriod       = std( dT );

% Find number of gaps in data
dT = diff( T );
info.NumDatGaps         = sum( dT > 5*info.MeanSampPeriod );
info.RecordingDuration  = ( range( T ) ) / 6e4; % Milliseconds to minutes



if length( T ) == info.NumDatPoints
    return
elseif length( T ) > info.NumDatPoints
    info.Comments = 'More time stamps than data points available';
elseif length( T ) < info.NumDatPoints
    info.Comments = 'More data points than time stamps available';
end

end
