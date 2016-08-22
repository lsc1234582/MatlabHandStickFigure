classdef SceneVideo < handle
    properties (SetAccess = private, GetAccess = public)
        RawFileName=[];
        RawVidReader=[];
        
        OverlayFileName=[];
        OverlayVidReader=[];
    end
    
    methods
        % Constructor
        function V = SceneVideo(  )
            
           
        end
         
    end
    
     methods
         Sync(V);
         LoadRawVideoReader(V);
         LoadOverlayVideoReader(V);
         
         OverlayGaze(V,G,outputFileName)
         SetOverlayFileName(V,info);
         SetRawFileName(V,info)
         
     end
     
     
  
end