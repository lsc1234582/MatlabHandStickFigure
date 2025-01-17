classdef Glove < DataRecord
    properties (SetAccess = private, GetAccess = public)
        Hand = '';
    end
    
    methods
        % Constructor
        function G = Glove( dBEntry )  
            if nargin == 0
                return
            end
            
            if numel( dBEntry ) == 1 && ...
                    ( ~isempty( dBEntry.prevFile ) || ~isempty( dBEntry.nextFile ) )
                warning( 'The file seems to be a segment of a larger file but I don''t have access to the rest.' )
            end
            
            G.SettingID     = dBEntry(1).SettingID;
            G.SubjectID     = dBEntry(1).SubjectID;
            G.RecordDate    = dBEntry(1).RecordDate;
            
            % Check handedness
            switch dBEntry(1).FileType
                case 'LeftHandData'
                    G.Hand = 'Left';
                case 'RightHandData'
                    G.Hand = 'Right';
                otherwise
                    error( 'Inappropriate file type.' )
            end
            
            % Ensure files are in right order
            fileNr = [dBEntry.FileCount];
            [~, ix] = sort( fileNr, 'ascend' );
            dBEntry = dBEntry(ix);
            
            for k = 1:numel( dBEntry )
                if isempty( strcmp( dBEntry(k).FileType, 'Hand' ) )
                    error( 'Inappropriate file type.' )
                end
                
                %% Record beginning of new files
                if k > 1
                    G.Events.ID = [G.Events.ID; 'NewFile'];
                    if ~isempty( G.Time ) && ~isnan( G.Time(end) )
                        G.Events.Time = [G.Events.Time; G.Time(end)+0.5];
                    else
                        G.Events.Time = [G.Events.Time; size( G.Data, 1)+0.5];
                    end
                end
                
                tmp = Glove.parseFile( dBEntry(k).FileName, G.Hand(1) );
                G.Data = [G.Data; tmp.Data];
                G.Time = [G.Time; tmp.Time];
                G.Events.ID = [G.Events.ID; tmp.ID.ID];
                G.Events.Time = [G.Events.Time; tmp.ID.Time];
                
                % Estimate sampling frequency
                G.Fs = 1000 / nanmean( diff( G.Time ) );
            end
        end %Constructor
        
        function G_ = saveobj( G )
            warning( 'off', 'MATLAB:structOnObject' );
            G_ = struct( G );
            warning( 'on', 'MATLAB:structOnObject' );
        end
    end
    
    methods (Static, Access = public)
        function G = loadobj( G_ )
            G = Glove();
            fNames = fieldnames( G_ );
            for k = 1:numel( fNames )
                G.(fNames{k}) = G_.(fNames{k});
            end
        end
        
        out = parseFile( fileName, hand )     % Parses the input file
    end
    
    methods (Access = public)
        [data, time] = cleanData( G );
    end
end