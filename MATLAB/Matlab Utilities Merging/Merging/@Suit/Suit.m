classdef Suit < DataRecord
    % TODO: sort out clearField to implement checks and remove access by
    % DataRecord class.
    
    properties( SetAccess = {?Suit, ?DataRecord}, GetAccess = public )
        BioMechData = [];
        xyzData     = [];
    end
    
    properties (Access = public)
        Skel = [];
    end
    
    methods
        % Constructor
        function S = Suit( info, flag )
            if nargin == 0 || isempty( info )
                return
            end
            
            if nargin < 2
                flag = [];
            end
            
            if isstruct( info ) && isfield( info, 'FileName' )
                dBEntry = info;
            elseif isstruct( info ) && isfield( info, 'Data' )
                % TODO implement checks on data
                warning( 'off', 'MATLAB:structOnObject' );
                suitFields = fieldnames( struct( S ) );
                infoFields = fieldnames( info );
                
                if ~all( ismember( infoFields, suitFields ) )
                    error( 'Input contains incompatible fields' )
                end
                
                for k = 1:numel( infoFields )
                    S.(infoFields{k}) = info.(infoFields{k});
                end
                
                warning( 'on', 'MATLAB:structOnObject' );
                return
            elseif isa( info, 'Suit' )
                S = copy( info );
                return
            elseif ischar( info ) % Assume it is a path to something
                %% Check if the folder exists
                if ~exist( info, 'dir' )
                    error( ['Cannot find ' info] )
                end
                
                %% Find BVH files & error if there are none
                sFiles = dir( [info '\*.bvh'] );
                if numel( sFiles ) == 0
                    error( 'No Suit file found in folder' );
                end
                
                %% If multiple files are found, ask user which one they want
                if numel( sFiles ) > 1
                    fNames = arrayfun( @(x) x.name, sFiles, 'UniformOutput', false );
                    disp( [num2cell( 1:numel( fNames) )' fNames] )
                    s = input( 'Which file would you like to load? (Input number) ' );
                    if any( s < 1 ) && max( s ) > numel( fNames )
                        error( 'Invalid selection' )
                    end
                else
                    s = 1;
                end
                
                %% Create fake dbEntry
                dBEntry = struct();
                
                for k = 1:numel( s )
                    dBEntry(k).FileName    = [info '\' sFiles(s(k)).name];
                    dBEntry(k).FileType    = 'SuitData';
                    dBEntry(k).SubjectID   = 'UNKNOWN';
                    dBEntry(k).SettingID   = 'UNKNOWN';
                    dBEntry(k).RecordDate  = datestr( sFiles(s(k)).datenum, 'yyyy-mm-dd' );
                    dBEntry(k).FileCount   = k;
                    dBEntry(k).MatlabData  = [];
                    if numel( s ) == 1 || k == 1
                        dBEntry(k).prevFile    = [];
                        dBEntry(k).nextFile    = [];
                    elseif k > 1
                        dBEntry(k-1).nextFile  = dBEntry(k).FileName;
                        dBEntry(k).prevFile    = dBEntry(k-1).FileName;
                    end
                    
                    %% Check if there is a time file
                    tFiles = dir( [info '\' sFiles(s(k)).name(1:3) '*SuitTime*.txt'] );
                    if numel( tFiles ) == 0
                        dBEntry(k).hasTime = false;
                    elseif numel( s ) > 1 && (numel( tFiles ) ~= numel( s ))
                        error( 'The number of time files does not correspond to the number of Suit files.' )
                    else
                        if numel( tFiles ) > 1;
                            [~, ix_file] = min( abs( [tFiles.datenum] - sFiles(s(k)).datenum ) );
                            tFiles = tFiles(ix_file);
                        end
                        dBEntry(k).hasTime = true;
                        dBEntry(k).linkedFiles.FileName = [info '\' tFiles.name];
                        dBEntry(k).linkedFiles.FileType = 'SuitTime';
                    end
                end
            else
                error( 'Cannot construct Suit from inputs.' )
            end
            
            if exist( dBEntry(1).MatlabData, 'file' ) && ( isempty( flag ) || ~strcmpi( flag, '-F' ) )
                S = load( dBEntry(1).MatlabData );
                S = S.S;
                return
            end
            
            if numel( dBEntry ) == 1 && ...
                    ( ~isempty( dBEntry.prevFile ) || ~isempty( dBEntry.nextFile ) )
                warning( 'The file seems to be a segment of a larger file but I don''t have access to the rest.' )
            end
            
            S.SettingID = dBEntry(1).SettingID;
            S.SubjectID = dBEntry(1).SubjectID;
            S.RecordDate = dBEntry(1).RecordDate;
            
            % Ensure files are in right order
            fileNr = [dBEntry.FileCount];
            [~, ix] = sort( fileNr, 'ascend' );
            dBEntry = dBEntry(ix);
            
            for k = 1:numel( dBEntry )
                if ~strcmp( dBEntry(k).FileType, 'SuitData' )
                    error( 'Inappropriate file type.' )
                end
                
                data = Suit.parseFile( dBEntry(k).FileName );
                S.Data = [S.Data; data];
                
                if dBEntry(k).hasTime
                    fName = getEntries( dBEntry(k).linkedFiles, 'FileName', @(x) strcmp( x.FileType, 'SuitTime' ) );
                    if numel( dBEntry ) > 1
                        ix = cellfun( @(x) ~isempty( strfind( x, ['_' num2str( k ) '.txt'] ) ), fName );
                        fName = fName(ix);
                    end
                    [time, ID] = Suit.parseTime( fName{1} );
                    
                    if size( time, 1 ) ~= size( data, 1 )
                        warning( 'The number of data points and time stamps is not the same! Ignoring time stamps.' )
%                         time = nan( size( time ) );
                        time = [time; nan( size( data, 1 ) - size( time, 1 ), 1 )];
                        S.Time = [S.Time; time];
                    else
                        if k > 1 && isempty( S.Time )
                            warning( 'It looks like previous data files did not have time stamps' )
                            S.Time = nan( size( S.Data, 1 ), 1 );
                            S.Time = [S.Time; time];
                        else
                            S.Time = [S.Time; time];
                        end
                        S.Events.ID = [S.Events.ID; ID.ID];
                        S.Events.Time = [S.Events.Time; ID.Time];
                    end
                end
                
                % Estimate sampling frequency
                S.Fs = 1000 / nanmean( diff( S.Time ) );
            end
            
            % Transform into biomechanical data
            S.BioMechData = BVH2BioMech( S );
            
            % Load standard skeleton
            locPath = mfilename( 'fullpath' );
            locPath(strfind( locPath, '\Suit' )+1:end) = [];
            tmp = load( [locPath 'standardSkeleton.mat'] );
            S.Skel = tmp.skel;
        end %Constructor
        
        function S_ = saveobj( S )
            warning( 'off', 'MATLAB:structOnObject' );
            S_ = struct( S );
            warning( 'on', 'MATLAB:structOnObject' );
        end
    end
    
    methods (Static, Access = public )
        function S = loadobj( S_ )
            S = Suit();
            fNames = fieldnames( S_ );
            for k = 1:numel( fNames )
                S.(fNames{k}) = S_.(fNames{k});
            end
        end
        
        [X, labels] = dataStruct2Mat( S );      % Transforms a data structure into a matrix
        outliers    = findOutliers( S );        % Identifies outliers in the data
        data        = parseFile( fileName );    % Parses the input file
        [time, ID]  = parseTime( fileName );     % Parses time stamps
    end
    
    methods (Access = public)
        Body = BVH2BioMech( S );
        xyzData = Data2XYZ( S );
    end
end