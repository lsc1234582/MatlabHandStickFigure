classdef Ethome < handle
    properties (SetAccess = protected, GetAccess = public)
        Data        = [];
        Time        = [];
        DataLabels  = [];
        Suit        = [];
        RightHand   = [];
        LeftHand    = [];
        Gaze        = [];
        Annotation  = [];
        AnnotationMarkers=[];
        xyzData     = [];
        SettingID   = '';
        SubjectID   = '';
        RecordDate  = '';
        Fs          = [];
        FrNumDataRate=[];
        SceneVideo       = [];
        DataInterpIndex=[];
    end
    
    properties (Dependent)
        Outliers    = [];
    end
    
    methods
        function E = Ethome( dBEntry )
            if nargin == 0
                return
            end
            
            % Set invariants
            E.SubjectID = dBEntry(1).SubjectID;
            E.SettingID = dBEntry(1).SettingID;
            E.RecordDate = dBEntry(1).RecordDate;
            
            % Check that all the data is OK
            if ~all( arrayfun( @(x) strcmp( x.SubjectID, E.SubjectID ), dBEntry ) )
                error( 'Ethome:multipleSubjects', ...
                    'The database entries contain more than one subject.' );
            end
            
            if ~all( arrayfun( @(x) strcmp( x.SettingID, E.SettingID ), dBEntry ) )
                error( 'Ethome:multipleSubjects', ...
                    'The database entries contain multiple settings.' );
            end
            
            mods = arrayfun( @(x) x.FileType, dBEntry, 'UniformOutput', false );
            uMods = unique( mods );
            
            
            
            for k = 1:numel( uMods )
                ix = strcmp( mods, uMods{k} );
                switch uMods{k}
                    case 'LeftHandData'
                        E.LeftHand = Glove( dBEntry(ix) );
                    case 'RightHandData'
                        E.RightHand = Glove( dBEntry(ix) );
                    case 'SuitData'
                        E.Suit = Suit( dBEntry(ix), '-F' ); % Call to class constructor Suit, not property
                    case 'SuitTime'
                        % Do nothing, treated by Suit;
                    case 'GazeData'
                        E.Gaze = Gaze( dBEntry(ix) );
                    case 'ConvertedGazeIDF'
                        IDFGaze = SMIRawParserErrHand({dBEntry(ix).FileName});
                    case 'ActivityLog'
                        E.Annotation = Annotation( dBEntry(ix) ); %disengaged as [~, ~, sL] = xlsread( file,'scenarioList' ); hangs for ome reason                     disp('not parsing annotations excel issues');
                        
                 case 'GazeSceneVideo'
                        if isempty(E.SceneVideo)
                         E.SceneVideo=SceneVideo;
                         E.SceneVideo.SetRawFileName(dBEntry(ix));
                        else
                         E.SceneVideo.SetRawFileName(dBEntry(ix));
                        end
                    case 'GazeSceneGazeOverlayVideo'
                        if isempty(E.SceneVideo)
                         E.SceneVideo=SceneVideo;
                         E.SceneVideo.SetOverlayFileName(dBEntry(ix));
                        else
                         E.SceneVideo.SetOverlayFileName(dBEntry(ix));
                        end
                    otherwise
                        warning( 'Ethome:NotImplemented', ...
                            [uMods{k} ' has not been implemented yet. Skipping...'] )
                end;
            end
            
            if (~isempty(IDFGaze))
                if (~isempty(E.Gaze))
                    E.Gaze.AddIDFData(IDFGaze);
                else
                    E.Gaze=Gaze;
                    E.Gaze.AddIDFData(IDFGaze);
                end
                E.Gaze.SyncIDF;
                
            end
            
            
        end
        
        
        function set.Outliers( E, val )
            return
        end
        
        function out = get.Outliers( E )
            if ~isempty( E.Data ) && ~isempty( E.Suit )
             %   out = E.Suit.findOutliers( E.Suit );
             out=[];
            else
                out = [];
            end
        end
        
        function E_ = saveobj( E )
            warning( 'off', 'MATLAB:structOnObject' );
            E_ = struct( E );
            warning( 'on', 'MATLAB:structOnObject' );
        end
    end
    
    
    methods (Static)
        function E = loadobj( E_ )
            E = Ethome();
            fNames = fieldnames( E_ );
            for k = 1:numel( fNames )
                E.(fNames{k}) = E_.(fNames{k});
            end
        end
    end
    
     
    methods
        addData( E, dBEntry );
        Sync( E, Fs, mode );
        SyncAnnotations(E);
        %SyncAnnotations(E)
        fuseHeadNGaze(E);
        out = Data2XYZ( E )
        ix = dataIndex( E, name );
        dataLabels = makeDataLabels( E, modalities );
        
    end
    
         methods  
           function setField( E, field, value )
           % TODO implement checks (?)
           E.(field) = value;
       end
    end
end