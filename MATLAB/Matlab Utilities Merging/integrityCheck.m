function info = integrityCheck( SubjectID, SettingID )
% function info = integrityCheck( SubjectID, SettingID )
% Checks the integrity of a recording
%
% Inputs:
% <SubjectID>   Subject identifier corresponding to one of the subjects in
%               the data base.
%
% <SettingID>   Setting identifier corresponding to a setting in the data
%               base.
%
% Outputs:
% <info>        Table with a row for each data type and the following
%               columns:
%                   - DataExists: Boolean. 1 if there is a file associated
%                       with that modality.
%                   - NumFiles: Double. Number of files for that modality.
%                   - Dimensions: Double. Dimensionality of the data.
%                   - NumDatPoints: Double. Number of data points.
%                   - NumBackTracking: Double. Number of times the time
%                       stamp jumps back in time. Should be 0.
%                   - NumDatGaps: Double. Number of gaps in the time
%                       stamps. A gap is defined as a jump in timestamps
%                       which is larger than 5 times the mean sampling
%                       rate.
%                   - MeanSampPeriod: Double. Mean sampling period in
%                       milliseconds.
%                   - SDSampPeriod: Double. Standard deviation of the
%                       sampling period in milliseconds.
%                   - NumSyncPoints: Double. Number of manual
%                       synchronisation points.
%                   - NumCalibPoints: Double. Number of times the subject 
%                       looks at his wrist.
%                   - RecordingDuration: Double. Recording duration in
%                       minutes, including potential gaps.
%                   - Comments: String. Comments on the information.
%
% Written by Andreas Thomik, August 2014.

% Define info structure

info = struct(  'DataExists', 0,...         % Boolean - Is the data there?
                'NumFiles', NaN, ...        % Number of files for modality
                'Dimensions', NaN, ...      % Dimensionality of the data
                'NumDatPoints', NaN, ...    % Number of data points
                'NumBackTracking', NaN, ... % Continuous time stamps?
                'NumDuplicateTime', NaN, ...% Number of duplicate time stamps
                'NumDatGaps',NaN,...        % Number of timestamp gaps greater than 5*MeanSamplingRate
                'MeanSampPeriod', NaN, ...  % Mean sampling period in milliseconds
                'SDSampPeriod', NaN, ...    % SD of sampling period in milliseconds
                'NumSyncPoints', NaN, ...   % Number of sync points
                'NumCalibPoints', NaN, ...  % Number of times the subject looks at his wrist
                'RecordingDuration',NaN,... % Recording Duration in minutes from start to end
                'Comments', {''} );         % User provided comments


% Define data modalities
mods = {'GazeData', 'SuitData', 'LeftHandData', 'RightHandData', ...
    'ActivityLog'};

% Replicate structure for each modality and transform to table
info = repmat( info, numel( mods ), 1 );

% Try loading the database
try
    load( 'L:\Data\database.mat' );
catch
    disp( 'Could not find file L:\Data\database.mat' )
    return
end

[fType, ix] = getEntries( dB_, 'FileType', @(x) strcmpi( x.SubjectID, SubjectID ), ...
    @(x) strcmpi( x.SettingID, SettingID ) );
ix = find( ix );

% Check if any files were found in the database
if isempty( fType )
    disp( 'Could not find any files in the database.' )
    disp( 'Maybe the database is not up to date.' )
    s = input( 'Would you like to recompile the database? Y/[N] ', 's' );
    if strcmpi( s, 'Y' )
        makeDataBase;
    end
    disp( 'Database regenerated, please run this function again.' )
    return
end

for k = 1:numel( fType )
    switch fType{k}
        case 'SuitData'
            tmpInfo = checkData( dB_(ix(k)), dB_ );
            info(strcmp( mods, 'SuitData' ), :) = tmpInfo;
        case 'GazeData'
            tmpInfo = checkData( dB_(ix(k)), dB_ );
            info(strcmp( mods, 'GazeData' ), :) = tmpInfo;
        case 'LeftHandData'
            tmpInfo = checkData( dB_(ix(k)), dB_ );
            info(strcmp( mods, 'LeftHandData' ), :) = tmpInfo;
        case 'RightHandData'
            tmpInfo = checkData( dB_(ix(k)), dB_ );
            info(strcmp( mods, 'RightHandData' ), :) = tmpInfo;
        case 'ActivityLog'
            tmpInfo = checkData( dB_(ix(k)), dB_ );
            info(strcmp( mods, 'ActivityLog' ), :) = tmpInfo;
        otherwise
            disp( ['Ignoring file type ' fType{k}] )
    end
end

info = struct2table( info, 'RowNames', mods );

end