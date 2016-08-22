classdef Annotation < DataRecord
    properties (SetAccess = private, GetAccess = public)
        AnnotationMethod    = '';
        EventMap            = [];
        Task                = [];
        Setting             = [];
    end
    
    methods
        % Constructor
        function A = Annotation( dBEntry )  
            if nargin == 0
                return
            end
            
            if numel( dBEntry ) == 1 && ...
                    ( ~isempty( dBEntry.prevFile ) || ~isempty( dBEntry.nextFile ) )
                warning( 'The file seems to be a segment of a larger file but I don''t have access to the rest.' )
            end
            
            A.SettingID     = dBEntry(1).SettingID;
            A.SubjectID     = dBEntry(1).SubjectID;
            A.RecordDate    = dBEntry(1).RecordDate;
            A.AnnotationMethod = dBEntry(1).logSoftware;
                      
            % Ensure files are in right order
            fileNr = [dBEntry.FileCount];
            [~, ix] = sort( fileNr, 'ascend' );
            dBEntry = dBEntry(ix);
            
            if strcmp( A.AnnotationMethod, 'DALI' ) || strcmp( A.AnnotationMethod, 'LogING' )
                for k = 1:numel( dBEntry )
                    if isempty( strcmp( dBEntry(k).FileType, 'ActivityLog' ) )
                        error( 'Inappropriate file type.' )
                    end
                    
                    tmp = Annotation.parseFile( dBEntry(k).FileName, A.AnnotationMethod, A.RecordDate );
                    
                    A.Data = cat( 1, A.Data, tmp.Action );
                    A.Task = cat( 1, A.Task, tmp.Task );
                    A.Setting = cat( 1, A.Setting, tmp.Setting );
                    if strcmp( A.AnnotationMethod, 'DALI' ) || k == 1 || isempty( A.Time )
                        A.Time = cat( 1, A.Time, tmp.Time );
                    else
                        A.Time = cat( 1, A.Time, A.Time(end) + 1 + tmp.Time );
                    end
                    
                    if k == 1 || isempty( A.EventMap )
                        A.EventMap = tmp.Map;
                    end
                    
                    % Estimate sampling frequency
                    A.Fs = 1000 / nanmean( diff( A.Time ) );
                end
%             elseif strcmp( A.AnnotationMethod, 'LogING' )
%                 fType = arrayfun( @(x) x.FileType, dBEntry );
%                 if ~all( strcmp( fType, 'LogING' ) )
%                     error( 'Inappropriate file type.' )
%                 end
%                 tmp = parseFile( dBEntry, A.AnnotationMethod );
%                 A.Data = tmp.ID;
%                 A.Time = tmp.Time;
%                 A.EventMap = tmp.Map;
            end
        end %Constructor
        
        
            
        function A_ = saveobj( A )
            warning( 'off', 'MATLAB:structOnObject' );
            A_ = struct( A );
            warning( 'on', 'MATLAB:structOnObject' );
     end
        
    end
    

     
    methods (Static, Access = public)
        out = parseFile( fileName, type, ver )     % Parses the input file
        
        function A = loadobj( A_ )
            A = Annotation();
            fNames = fieldnames( A_ );
            for k = 1:numel( fNames )
                A.(fNames{k}) = A_.(fNames{k});
            end
        end
    end
    
    methods (Static, Access = public, Hidden )
        [sL, tL, aL, map] = parseAnnotationXLS( file );
    end
    
    methods (Static)
        equivActions = LogING2DALI( A );
        equivActions = DALI2LogING( A );
    end
    
    methods (Access = public)
        toVector( A );
        toMatrix( A );
        plot( A );
        map2DALIv2( A );
    end
end