classdef Gaze < DataRecord
    properties( SetAccess = {?Gaze, ?DataRecord}, GetAccess = public )
        BioMechData = [];
        xyzData     = [];
        EyeFrameNum=[];
        SceneFrameNum=[];
        IDFData=[];
        systemTime=[];
        serverTime=[];
    end
    
    
    methods
        % Constructor
        function G = Gaze( info )
            if nargin == 0
                return
            end
            
            
             
            if isstruct( info ) && isfield( info, 'FileName' )
                dBEntry = info;
            elseif isstruct( info ) && isfield( info, 'Data' )
                % TODO implement checks on data
                warning( 'off', 'MATLAB:structOnObject' );
                gazeFields = fieldnames( struct(G ) );
                infoFields = fieldnames( info );
                
                if ~all( ismember( infoFields, gazeFields ) )
                    error( 'Input contains incompatible fields' )
                end
                
                for k = 1:numel( infoFields )
                    G.(infoFields{k}) = info.(infoFields{k});
                end
                
                warning( 'on', 'MATLAB:structOnObject' );
                return
            elseif isa( info, 'Gaze' )
                G = copy( info );
                return
            else
                error( 'Cannot construct Suit from inputs.' )
            end
            
            if numel( dBEntry ) == 1 && ...
                    ( ~isempty( dBEntry.prevFile ) || ~isempty( dBEntry.nextFile ) )
                warning( 'The file seems to be a segment of a larger file but I don''t have access to the rest.' )
            end
            
            G.SettingID = dBEntry(1).SettingID;
            G.SubjectID = dBEntry(1).SubjectID;
            G.RecordDate = dBEntry(1).RecordDate;
            
            % Ensure files are in right order
            fileNr = [dBEntry.FileCount];
            [~, ix] = sort( fileNr, 'ascend' );
            dBEntry = dBEntry(ix);
            
            for k = 1:numel( dBEntry )
                if strcmp( dBEntry(k).FileType, 'GazeData' )
                
                
                out = Gaze.parseFile( dBEntry(k).FileName );
                G.Data = [G.Data; out.data];
                G.Time=[G.Time; out.time]; % timestamp is servertime shifted inline with system time in millisecs,
                G.systemTime=out.systemTime;
                G.serverTime=out.serverTime;
                
                G.Events.ID = [G.Events.ID; out.markers.ID]; % sync ID=1 calib ID=2
                G.Events.Time = [G.Events.Time; out.markers.time];    
                else                    
                error( 'Inappropriate file type.' )
                end
            end
            
            
            % Estimate sampling frequency
            G.Fs = 1000 / nanmean( diff( G.Time ) );
            
            
            % Transform into biomechanical data
            % G.BioMechData = ;
            
       
        end %Constructor
    end
    
    
    methods (Access = public)
        xyzData = Data2XYZ( G );
        
    end
    
    
     methods (Access = public)
        AddIDFData(G,IDF);
        
     end
    methods (Access = public)
        SyncIDF(G)
    end
    
    methods (Static, Access = public)
        data = parseFile( fileName );         % Parses the input file
    end
end