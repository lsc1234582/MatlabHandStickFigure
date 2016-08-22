function dB_ = makeDataBase( dataPath )
%% makeDataBase
% Script to generate a database for the Ethomics data collected in a range
% of experiments.

% TO DO LIST:
%   Write documentation
%   Deal with supplementary information

% List of possible file types:
%   'ActivityLog'
%   'SuitData'
%   'SuitTime'
%   'LeftHandData'
%   'RightHandData'
%   'CalibrationRight'
%   'CalibrationLeft'
%   'UNKNOWN_CALIBRATION'
%   'Video'
%   'Photo'
%   'GazeCodec'
%   'GazeCalibrationInfo'
%   'GazeTrialInfo'
%   'LeftEyeVideo'
%   'RightEyeVideo'
%   'GazeCorrectionInfo'
%   'GazeSceneVideo'
%   'GazeSceneAudio'
%   'GazeIDF'
%   'GazeData'

%% Initialise variables
dB_ = struct( 'FileName', {''}, ...     % Full file name including path
    'RecordDate', {''}, ...   % Recording date
    'SubjectID', {''}, ...    % Unique subject identifier
    'SubjectType', '', ...    % Subject health status
    'SettingID', {''}, ...    % Setting identifier
    'FileType', {''}, ...     % Content descriptor
    'isCalibrated', [], ...   % Calibration flag
    'calData', {''}, ...      % Calibration files
    'hasTime', [], ...        % Time information available flag
    'hasSuit', [], ...        % Suit data available flag
    'hasGaze', [], ...        % Gaze data available flag
    'hasRightHand', [], ...   % Right hand data available flag
    'hasLeftHand', [], ...    % Left hand data available flag
    'hasSupInfo', [], ...     % Supplementary info available flag
    'hasVideo', [], ...       % Video available flag
    'supInfo', {''}, ...      % Supplementary info file list
    'hasLog', [], ...         % Action log available flag
    'logSoftware', {''}, ...  % Logging software used
    'isComplete', [], ...     % Data fragmentation flag
    'nextFile', {''}, ...     % IF ~isComplete: next file
    'prevFile', {''}, ...     % IF ~isComplete: previous file
    'linkedFiles', [], ...    % Associated files
    'FileID', [], ...         % Unique file identifier
    'Comments', {''}, ...     % User supplied comments
    'FileCount', [], ...      % Temporary counter, not in output
    'MatlabData', {''} );     % Path to data in .mat format

dBPrototype = dB_;

lFiles = struct( 'FileName', {''}, ...  % See above for definitions
    'FileType', {''}, ...
    'isComplete', [], ...
    'FileID', [] );

dateRegExp = '\d{4}\-\d{2}\-\d{2}';
n = 1;

%%
if nargin == 0
    dataPath = 'L:\Data';
end

cd( dataPath )

if exist( 'database.mat', 'file' )
    s = input( 'Previous database file found. Do you wish to recompile it? Y/[N] ', 's' );
    if ~strcmpi( s, 'Y' )
        return
    end
end

files = dir;
dB_ = [];
disp( 'Parsing directory structure...' )
for k = 1:numel( dir )
    
    if strcmp(files(k).name,'2013-09-20-1')
        files(k)
    end
    if isempty( regexp( files(k).name, dateRegExp , 'once' ) )
        continue
    end
    cd( files(k).name );
    if exist( 'INFO.txt', 'file' )
        fileID = fopen( 'INFO.txt', 'r' );
        dataArray = textscan( fileID, '%s%s%[^\n\r]', ...
            'Delimiter', '\t', 'MultipleDelimsAsOne', true, ...
            'ReturnOnError', false );
        fclose( fileID );
        clearvars fileID
        
        %% Get recording date
        [ixS, ixE] = regexp( files(k).name, dateRegExp , 'once' );
        try
            recDate = files(k).name(ixS:ixE);
        catch
            recDate = 'ERROR';
        end
        
        %% Get subject ID
        subjID = dataArray{2}{strncmpi( 'Subject', dataArray{1}, 7 )};
        if isempty( subjID )
            subjID = 'ERROR';
        end
                
        %% Get logging software
        logID = dataArray{2}{strncmpi( 'Logger', dataArray{1}, 6 )};
        if isempty( logID )
            logID = 'ERROR';
        end
        
        %% Get health status
        subjStat = dataArray{2}{strncmpi( 'Status', dataArray{1}, 6 )};
        if isempty( subjStat )
            subjStat = 'ERROR';
        end
        
        %% Check all files in folder
        dB_ = [dB_; parseFolder( pwd, dBPrototype, subjID, recDate, ...
            logID, subjStat )];
    else
        disp( ['WARNING: Could not parse the folder ' pwd '. INFO file missing.'] )
        cd( '..' )
        continue
    end
end

dB_ = assignFileID( dB_ );

%%
disp( 'Finding related files...' )
for k = 1:length( dB_ )
    % Select all other files from the same subject and settings
    if any( strcmp( dB_(k).FileType, {'Photo', 'Video'} ) )
        continue
    end
    ok_     = true( size( dB_ ) );
    ok_(k)  = false;
    subjID  = dB_(k).SubjectID;
    setID   = dB_(k).SettingID;
    fileIX  = arrayfun( @(x) strcmp( x.SubjectID, subjID ) , dB_ ) & ...
        ( arrayfun( @(x) strcmp( x.SettingID,  setID ), dB_ ) | ...
        arrayfun( @(x) strcmp( x.SettingID,  'none' ), dB_ ) | ...
        arrayfun( @(x) strcmp( x.FileType,  'Photo' ), dB_ ) | ...
        arrayfun( @(x) strcmp( x.FileType,  'Supplementary' ), dB_ ) ) & ok_;
    %       arrayfun( @(x) strcmp( x.SettingID,  setID ), dB_ ) ) | ...
    relFiles = dB_(fileIX);
    
    if isempty( relFiles )
        dB_(k).isComplete = true;
        continue
    else
        dB_(k).linkedFiles = struct( lFiles );
    end
    
    % Check if this is the only file for that modality
    if any( arrayfun( @(x) strcmp( x.FileType, dB_(k).FileType ), relFiles ) )
        dB_(k).isComplete = false;
    else
        dB_(k).isComplete = true;
    end
    
    % Check what the other files are about
    for l = 1:length( relFiles )
        okFile = true;
        switch relFiles(l).FileType
            case 'ActivityLog'
                dB_(k).hasLog = true;
            case 'SuitData'
                dB_(k).hasSuit = true;
            case 'SuitTime'
                if strcmp( dB_(k).FileType, 'SuitData' )
                    dB_(k).hasTime = true;
                else
                    okFile = false;
                end
            case 'LeftHandData'
                dB_(k).hasLeftHand = true;
            case 'RightHandData'
                dB_(k).hasRightHand = true;
            case 'GazeData'
                dB_(k).hasGaze = true;
            case 'CalibrationRight'
                if strcmp( dB_(k).FileType, 'RightHandData' )
                    dB_(k).isCalibrated = true;
                    dB_(k).calData = relFiles(l).FileName;
                else
                    okFile = false;
                end
            case 'CalibrationLeft'
                if strcmp( dB_(k).FileType, 'LeftHandData' )
                    dB_(k).isCalibrated = false;
                    dB_(k).calData = relFiles(l).FileName;
                else
                    okFile = false;
                end
            case 'Photo'
                if strcmp( dB_(k).FileType, 'SuitData' )
                    dB_(k).calData = relFiles(l).FileName;
                else
                    okFile = false;
                end
            case 'Video'
                dB_(k).hasVideo = true;
            case { 'GazeCodec', 'GazeCalibrationInfo', 'LeftEyeVideo', ...
                    'RightEyeVideo', 'GazeCorrectionInfo', ...
                    'GazeSceneVideo', 'GazeSceneAudio', 'GazeIDF', 'ConvertedGazeIDF' }
                if strcmp( dB_(k).FileType, 'GazeData' )
                    % This is fine, attach the files
                else
                    okFile = false;
                end
            case 'Supplementary'
                dB_(k).hasSupInfo = true;
                tmpRegExp = '(?<path>\w\:\\.*SupInfo\\)';
                tmpPath = regexp( relFiles(l).FileName, tmpRegExp, 'names' );
                dB_(k).supInfo = tmpPath.path;
            otherwise
                okFile = false;
        end
        
        if okFile
            dB_(k).linkedFiles(l).FileName = relFiles(l).FileName;
            dB_(k).linkedFiles(l).FileType = relFiles(l).FileType;
            dB_(k).linkedFiles(l).isComplete = relFiles(l).isComplete;
            dB_(k).linkedFiles(l).FileID = relFiles(l).FileID;
        else
            if strcmp( relFiles(l).FileType, 'ERROR' )
                disp( ['Could not assign ' relFiles(l).FileName '. Unknown File Type.'] )
            else
                % The file does not need to be associated.
            end
        end
    end
    
    % Clean up empty entires
    ix = arrayfun( @(x)isempty( x.FileName ), dB_(k).linkedFiles );
    dB_(k).linkedFiles(ix) = [];
end

%% Resolve file dependencies
% Go over all files which are not complete and find the associated files
disp( 'Linking files...' )
for k = 1:numel( dB_ )
    if dB_(k).isComplete || ~isempty( dB_(k).prevFile ) || ...
            ~isempty( dB_(k).nextFile )
        continue
    end
    
    fileIX = arrayfun( @(x) strcmp( x.SubjectID, dB_(k).SubjectID ) , dB_ ) & ...
        arrayfun( @(x) strcmp( x.SettingID,  dB_(k).SettingID ), dB_ ) & ...
        arrayfun( @(x) strcmp( x.FileType,  dB_(k).FileType ), dB_ );
    relFiles = dB_(fileIX);
    
    fileNr = [relFiles.FileCount];
    if length( fileNr ) ~= length( relFiles )
        error( 'Uh...' )
    end
    % Discard files whose number could not be identified
    relFiles( fileNr == -1 ) = [];
    
    
    [fileNr, ix] = sort( fileNr, 'ascend' );
    relFiles = relFiles(ix);
    
    if any( diff( fileNr ) > 1 )
        disp( 'File numbering seems to be broken' )
    end
    
    for l = 1:numel( relFiles )
        ix = [dB_.FileID] == relFiles(l).FileID;
        if l ~= numel( relFiles )
            dB_(ix).nextFile = relFiles(l+1).FileName;
        end
        if l ~= 1
            dB_(ix).prevFile = relFiles(l-1).FileName;
        end
    end
end


%% Delete entries for suit time, calibration files, photos and videos --
% they are saved with their corresponding file anyway and useless on their
% own.
disp( 'Cleaning up...' )
[~, ix] = getEntries( dB_, [], @(x) any( strcmp( x.FileType, ...
    {'CalibrationRight', 'CalibrationLeft', 'SuitTime', ...
    'Photo', 'GazeCodec', 'GazeCalibrationInfo', ...
    'GazeCorrectionInfo', ...
     'Supplementary'} ) ) );

dB_(ix) = [];


disp( 'Saving database...' )
save( [dataPath '\database.mat'], 'dB_', '-v7.3' )
disp( 'Database saved!' )


end

function dBEntry = makeEntry( fileName, subjID, recDate, logID, ...
    subjStat, dBEntry, settingID )

dBEntry.hasTime         = false;
dBEntry.hasSuit         = false;
dBEntry.hasGaze         = false;
dBEntry.hasRightHand    = false;
dBEntry.hasLeftHand     = false;
dBEntry.isCalibrated    = false;
dBEntry.hasSupInfo      = false;
dBEntry.hasVideo        = false;
dBEntry.hasLog          = false;
dBEntry.FileName        = fileName;
dBEntry.SubjectID       = subjID;
dBEntry.RecordDate      = recDate;
dBEntry.logSoftware     = logID;
dBEntry.SubjectType     = subjStat;
dBEntry.isComplete      = false;
if isempty( settingID )
    dBEntry.SettingID   = getSettingID( fileName );
    dBEntry.FileCount   = getFileCount( fileName, 0 );
else % For gaze data only
    dBEntry.SettingID   = settingID;
    dBEntry.FileCount   = getFileCount( fileName, 1 );
end
dBEntry                 = setFileModality( dBEntry );

end

function settingID = getSettingID( fileName )

if ~isempty( strfind( fileName, 'Bed' ) )
    settingID = 'Bedroom';
elseif ~isempty( strfind(fileName, 'Kitchen' ) ) || ...
        ~isempty( strfind( fileName, 'Breakfast' ) )
    settingID = 'Kitchen';
elseif ~isempty( strfind( fileName, 'Office' ) )
    settingID = 'Office';
elseif ~isempty( strfind( fileName, 'Task' ) )
    settingID = 'Task';
elseif ~isempty( strfind( fileName, 'Navigation' ) )
    settingID = 'Navigation';
elseif ~isempty( strfind( fileName, '.cal' ) )
    settingID = 'none';
else
    settingID = 'ERROR';
end

end

function dBEntry = setFileModality( dBEntry )

if ~isempty( strfind( dBEntry.FileName, '\SupInfo\' ) )
    dBEntry.FileType = 'Supplementary';
elseif ~isempty( strfind( dBEntry.FileName, 'Log' ) )
    dBEntry.FileType = 'ActivityLog';
    dBEntry.hasLog = true;
    dBEntry.hasTime = true;
    dBEntry.isCalibrated = true;
elseif ~isempty( strfind( dBEntry.FileName, 'bvh' ) )
    dBEntry.FileType = 'SuitData';
    dBEntry.hasSuit = true;
    dBEntry.isCalibrated = true;
elseif ~isempty( strfind( dBEntry.FileName, 'SuitTime' ) )
    dBEntry.FileType = 'SuitTime';
    dBEntry.hasTime = true;
    dBEntry.isCalibrated = true;
elseif ~isempty( strfind( dBEntry.FileName, 'LeftHand' ) ) && ...
        isempty( strfind( dBEntry.FileName, '.cal' ) )
    dBEntry.FileType = 'LeftHandData';
    dBEntry.hasLeftHand = true;
elseif ~isempty( strfind( dBEntry.FileName, 'RightHand' ) ) && ...
        isempty( strfind( dBEntry.FileName, '.cal' ) )
    dBEntry.FileType = 'RightHandData';
    dBEntry.hasRightHand = true;
elseif ~isempty( strfind( dBEntry.FileName, '.cal' ) )
    if ~isempty( strfind( dBEntry.FileName, 'Right' ) )
        dBEntry.FileType = 'CalibrationRight';
        dBEntry.isComplete = true;
    elseif ~isempty( strfind( dBEntry.FileName, 'Left' ) )
        dBEntry.FileType = 'CalibrationLeft';
        dBEntry.isComplete = true;
    else
        dBEntry.FileType = 'UNKNOWN_CALIBRATION';
    end
    
elseif ~isempty( strfind( dBEntry.FileName, '.JPG' ) ) || ...
        ~isempty( strfind( dBEntry.FileName, '.jpg' ) )
    dBEntry.FileType = 'Photo';
    dBEntry.isComplete = true;
    dBEntry.isCalibrated = true;
elseif ~isempty( strfind( dBEntry.FileName, '.bin' ) )
    dBEntry.FileType = 'GazeCodec';
elseif ~isempty( strfind( dBEntry.FileName, '-calibration.xml' ) )
    dBEntry.FileType = 'GazeCalibrationInfo';
elseif ~isempty( strfind( dBEntry.FileName, 'eye-left.avi' ) )
    dBEntry.FileType = 'LeftEyeVideo';
elseif ~isempty( strfind( dBEntry.FileName, 'eye-right.avi' ) )
    dBEntry.FileType = 'RightEyeVideo';
elseif ~isempty( strfind( dBEntry.FileName, 'gazecorrection.xml' ) )
    dBEntry.FileType = 'GazeCorrectionInfo';
elseif ~isempty( strfind( dBEntry.FileName, 'recording-converted.' ) )
    dBEntry.FileType = 'GazeSceneVideo';
elseif ~isempty( strfind( dBEntry.FileName, 'recording-convertedGazeOverlay.' ) )
       dBEntry.FileType = 'GazeSceneGazeOverlayVideo';    
elseif ~isempty( strfind( dBEntry.FileName, '-recording.wav' ) )
    dBEntry.FileType = 'GazeSceneAudio';
elseif ~isempty( strfind( dBEntry.FileName, '-recording.idf' ) )
    dBEntry.FileType = 'GazeIDF';
elseif ~isempty( strfind( dBEntry.FileName, 'GazeDataIDF.txt' ) )
    dBEntry.FileType = 'ConvertedGazeIDF';
elseif ~isempty( strfind( dBEntry.FileName, '-participant.xml' ) )
    dBEntry.FileType = 'GazeTrialInfo';
elseif ~isempty( strfind( dBEntry.FileName, 'GazeData.txt' ) )
    dBEntry.FileType = 'GazeData';
    dBEntry.hasGaze = true;
    dBEntry.hasTime = true;
    dBEntry.isCalibrated = true;
elseif ~isempty( strfind( dBEntry.FileName, '.MP4' ) ) || ...
        ~isempty( strfind( dBEntry.FileName, '.mp4' ) ) || ...
        ~isempty( strfind( dBEntry.FileName, '.MOV' ) ) || ...
        ~isempty( strfind( dBEntry.FileName, '.mov' ) )
    dBEntry.FileType = 'Video';
    dBEntry.isComplete = true;
    dBEntry.isCalibrated = true;
else
    dBEntry.FileType = 'ERROR';
end

end

function n = getFileCount( fileName, isDir )
fileNrRegExp = '_\d\.*';
dirNrRegExp = '_\d\\';

if isDir
    [ixS, ixE] = regexp( fileName, dirNrRegExp );
else
    [ixS, ixE] = regexp( fileName, fileNrRegExp );
end

if isempty( ixS )
    n = '0';
elseif isDir
    n = fileName(ixS+1:ixE-1);
else
    n = fileName(ixS+1:ixE-1);
end

n = str2double( n );
end

function [dBEntry, n] = parseFolder( fullPath, protoEntry, subjID, ...
    recDate, logID, subjStat )
cd( fullPath )
n = 1;
locFiles = dir;
dBEntry = repmat( protoEntry, size( locFiles ) );
for l = 1:length( locFiles )
    if locFiles(l).isdir
        if any( strcmp( {'.', '..'}, locFiles(l).name ) )
            continue
        else
            tmp = parseFolder( [pwd '\' locFiles(l).name], ...
                protoEntry, subjID, recDate, logID, subjStat );
            dBEntry = [dBEntry; tmp];
        end
    else % List of files to ignore
        if any( strcmp( locFiles(l).name, {'INFO.txt', 'Thumbs.db'} ) )
            continue
        else
            % Tweak file names for image and video files
            if ~isempty( strfind( fullPath, 'Photos' ) )
                fileName = [pwd '\img_' locFiles(l).name];
            elseif ~isempty( strfind( fullPath, 'Videos' ) )
                fileName = [pwd '\vid_' locFiles(l).name];
            else
                fileName = [pwd '\' locFiles(l).name];
            end
            
            % For gaze data, the setting is saved in the folder name
            if ~isempty( strfind( fullPath, 'GazeData' ) )
                settingID = getSettingID( fullPath );
            else
                settingID = [];
            end
            
            % Deal with supplementary information
            if ~isempty( strfind( fullPath, 'SupInfo' ) )
                % TODO
            else
                % TODO
            end
            
            % Make database entry
            dBEntry(n) = makeEntry( fileName, subjID, recDate, logID, ...
                subjStat, dBEntry(n), settingID );
            
            % Increase file count
            n = n+1;
        end
    end
end
cd( '..' )

% Clear unused space
ix = arrayfun( @(x) isempty( x.FileName ), dBEntry );
dBEntry(ix) = [];
n = numel( dBEntry );
end

function dB_ = assignFileID( dB_ )
% Assigns a unique identifier to all database entries

for n = 1:numel( dB_ )
    allIDs = [dB_.FileID];
    newID = round( rand*1e16 );
    while any( allIDs == newID )
        newID = round( rand*1e16 );
    end
    dB_(n).FileID = newID;
end

end

