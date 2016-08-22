classdef DataRecord < handle & matlab.mixin.Copyable
   properties (SetAccess = protected, GetAccess = public, Hidden = false)
      Data          = [];   % Raw data
      Time          = [];   % Time stamps
      SettingID     = '';   % Setting ID
      SubjectID     = '';   % Subject ID
      RecordDate    = '';   % Recoding date
      Fs            = -1;   % Sampling frequency
      FrameLoss     = [];   % Position and number of missing frames
      Events        = struct( 'ID', [], 'Time', [] );   % Any other events (e.g. sync points) 
   end
      
   methods
      function DR = DataRecord( )
         % Emtpy constructor
      end
   end
   
   methods (Static, Abstract, Access = public)
      parseFile() % Parses the input file.
   end
   
   methods
       function clearField( DR, field )
           % TODO implement checks (?)
           DR.(field) = [];
       end
       
       function setField( DR, field, value )
           % TODO implement checks (?)
           DR.(field) = value;
       end
       
       function DR_ = saveobj( DR )
           warning( 'off', 'MATLAB:structOnObject' );
           DR_ = struct( DR );
           warning( 'on', 'MATLAB:structOnObject' );
       end
       
       [allJumpIX, allJumpMag] = fixTimeStamps( DR );
   end
   
   methods (Static)
       function DR = loadobj( DR_ )
           %DR = DataRecord();
           fNames = fieldnames( DR_ );
           for k = 1:numel( fNames )
               DR.(fNames{k}) = DR_.(fNames{k});
           end
       end
   end
end