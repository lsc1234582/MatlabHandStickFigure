function dataLabels = makeDataLabels( Modality )
% function dataLabels = makeDataLabels( Modality )
% Creates a cell vector of labels for a given recording modality.
%
% Inputs:
% <Modality>	String or cell array of strings. Allowable inputs are:
%                   - 'Suit'
%                   - 'LeftGlove'
%                   - 'RightGlove'
%                   - 'EyeTracker'
%                   - 'All' (equivalent to {'EyeTracker', 'LeftGlove',
%                       'RightGlove', 'Suit'} )
%
% Outputs:
% <dataLabels>  2xN xell array of labels for the chosen recording modality
%               or modalities. Depending on Modality, N is:
%                   - Suit:         66
%                   - LeftGlove:    18
%                   - RightGlove:   22
%                   - EyeTracker:   29
%                   - All:          135
%               The second row of dataLabels indicates the recording
%               modality the label is associated with.
%               If Modality is a cell array, N is the sum of all
%               modalities chosen, in the order of the input.
%
% Written by Andreas Thomik, November 2014

if iscell( Modality )
    if numel( Modality ) > 1
        dataLabels = [];
        for k = 1:numel( Modality )
            dataLabels = [dataLabels, makeDataLabels( Modality{k} )];
        end
        return
    else
        Modality = Modality{1};
    end
end

switch Modality
    case 'Suit'
        dataLabels          = cell( 2, 66 );
        dataLabels(2, :)    = {'Suit'};
        dataLabels{1, 1}    = 'HipsPos_Pos_X';
        dataLabels{1, 2}    = 'HipsPos_Pos_Y'; % This is upwards
        dataLabels{1, 3}    = 'HipsPos_Pos_Z';
        dataLabels{1, 4}    = 'Hips_Rot_Z';
        dataLabels{1, 5}    = 'Hips_Rot_X';
        dataLabels{1, 6}	= 'Hips_Rot_Y';
        dataLabels{1, 7}	= 'LeftUpLeg_Rot_Z';
        dataLabels{1, 8}	= 'LeftUpLeg_Rot_X';
        dataLabels{1, 9}	= 'LeftUpLeg_Rot_Y';
        dataLabels{1, 10}	= 'LeftLeg_Rot_Z';
        dataLabels{1, 11}	= 'LeftLeg_Rot_X';
        dataLabels{1, 12}	= 'LeftLeg_Rot_Y';
        dataLabels{1, 13}	= 'LeftFoot_Rot_Z';
        dataLabels{1, 14}	= 'LeftFoot_Rot_X';
        dataLabels{1, 15}	= 'LeftFoot_Rot_Y';
        dataLabels{1, 16}	= 'LeftFootHeel_Rot_Z';
        dataLabels{1, 17}	= 'LeftFootHeel_Rot_X';
        dataLabels{1, 18}	= 'LeftFootHeel_Rot_Y';
        dataLabels{1, 19}	= 'RightUpLeg_Rot_Z';
        dataLabels{1, 20}	= 'RightUpLeg_Rot_X';
        dataLabels{1, 21}	= 'RightUpLeg_Rot_Y';
        dataLabels{1, 22}	= 'RightLeg_Rot_Z';
        dataLabels{1, 23}	= 'RightLeg_Rot_X';
        dataLabels{1, 24}	= 'RightLeg_Rot_Y';
        dataLabels{1, 25}	= 'RightFoot_Rot_Z';
        dataLabels{1, 26}	= 'RightFoot_Rot_X';
        dataLabels{1, 27}	= 'RightFoot_Rot_Y';
        dataLabels{1, 28}	= 'RightFootHeel_Rot_Z';
        dataLabels{1, 29}	= 'RightFootHeel_Rot_X';
        dataLabels{1, 30}	= 'RightFootHeel_Rot_Y';
        dataLabels{1, 31}	= 'Spine_Rot_Z';
        dataLabels{1, 32}	= 'Spine_Rot_X';
        dataLabels{1, 33}	= 'Spine_Rot_Y';
        dataLabels{1, 34}	= 'Spine1_Rot_Z';
        dataLabels{1, 35}	= 'Spine1_Rot_X';
        dataLabels{1, 36}	= 'Spine1_Rot_Y';
        dataLabels{1, 37}	= 'LeftShoulder_Rot_Z';
        dataLabels{1, 38}	= 'LeftShoulder_Rot_X';
        dataLabels{1, 39}	= 'LeftShoulder_Rot_Y';
        dataLabels{1, 40}	= 'LeftArm_Rot_Z';
        dataLabels{1, 41}	= 'LeftArm_Rot_X';
        dataLabels{1, 42}	= 'LeftArm_Rot_Y';
        dataLabels{1, 43}	= 'LeftForeArm_Rot_Z';
        dataLabels{1, 44}	= 'LeftForeArm_Rot_X';
        dataLabels{1, 45}	= 'LeftForeArm_Rot_Y';
        dataLabels{1, 46}	= 'LeftHand_Rot_Z';
        dataLabels{1, 47}	= 'LeftHand_Rot_X';
        dataLabels{1, 48}	= 'LeftHand_Rot_Y';
        dataLabels{1, 49}	= 'RightShoulder_Rot_Z';
        dataLabels{1, 50}	= 'RightShoulder_Rot_X';
        dataLabels{1, 51}	= 'RightShoulder_Rot_Y';
        dataLabels{1, 52}	= 'RightArm_Rot_Z';
        dataLabels{1, 53}	= 'RightArm_Rot_X';
        dataLabels{1, 54}	= 'RightArm_Rot_Y';
        dataLabels{1, 55}	= 'RightForeArm_Rot_Z';
        dataLabels{1, 56}	= 'RightForeArm_Rot_X';
        dataLabels{1, 57}	= 'RightForeArm_Rot_Y';
        dataLabels{1, 58}	= 'RightHand_Rot_Z';
        dataLabels{1, 59}	= 'RightHand_Rot_X';
        dataLabels{1, 60}	= 'RightHand_Rot_Y';
        dataLabels{1, 61}	= 'Neck_Rot_Z';
        dataLabels{1, 62}	= 'Neck_Rot_X';
        dataLabels{1, 63}	= 'Neck_Rot_Y';
        dataLabels{1, 64}	= 'Head_Rot_Z';
        dataLabels{1, 65}	= 'Head_Rot_X';
        dataLabels{1, 66}	= 'Head_Rot_Y';
    case 'RightGlove'
        dataLabels          = cell( 2, 22 );
        dataLabels(2, :)    = {'RightGlove'};
        dataLabels{1, 1}    = 'Thumb_CMC';
        dataLabels{1, 2}    = 'Thumb_MCP';
        dataLabels{1, 3}    = 'Thumb_IJ';
        dataLabels{1, 4}    = 'Thumb_Index_ABD';
        dataLabels{1, 5}    = 'Index_MCP';
        dataLabels{1, 6}    = 'Index_PIP';
        dataLabels{1, 7}    = 'Index_DIP';
        dataLabels{1, 8}    = 'Middle_MCP';
        dataLabels{1, 9}    = 'Middle_PIP';
        dataLabels{1, 10}   = 'Middle_DIP';
        dataLabels{1, 11}   = 'Middle_Index_ABD';
        dataLabels{1, 12}   =  'Ring_MCP';
        dataLabels{1, 13}   = 'Ring_PIP';
        dataLabels{1, 14}   = 'Ring_DIP';
        dataLabels{1, 15}   = 'Ring_Middle_ABD';
        dataLabels{1, 16}   = 'Pinky_MCP';
        dataLabels{1, 17}   = 'Pinky_PIP';
        dataLabels{1, 18}   = 'Pinky_DIP';
        dataLabels{1, 19}   = 'Pinky_Ring_ABD';
        dataLabels{1, 20}   = 'Palm_Arch';
        dataLabels{1, 21}   = 'Wrist_FLEX';
        dataLabels{1, 22}   = 'Wrist_ABD';
    case 'LeftGlove'
        dataLabels          = cell( 2, 18 );
        dataLabels(2, :)    = {'LeftGlove'};
        dataLabels{1, 1}    = 'Thumb_CMC';
        dataLabels{1, 2}    = 'Thumb_MCP';
        dataLabels{1, 3}    = 'Thumb_IJ';
        dataLabels{1, 4}    = 'Thumb_Index_ABD';
        dataLabels{1, 5}    = 'Index_MCP';
        dataLabels{1, 6}    = 'Index_PIP';
        dataLabels{1, 7}    = 'Middle_MCP';
        dataLabels{1, 8}    = 'Middle_PIP';
        dataLabels{1, 9}    = 'Middle_Index_ABD';
        dataLabels{1, 10}   = 'Ring_MCP';
        dataLabels{1, 11}   = 'Ring_PIP';
        dataLabels{1, 12}   = 'Ring_Middle_ABD';
        dataLabels{1, 13}   = 'Pinky_MCP';
        dataLabels{1, 14}   = 'Pinky_PIP';
        dataLabels{1, 15}   = 'Pinky_Ring_ABD';
        dataLabels{1, 16}   = 'Palm_Arch';
        dataLabels{1, 17}   = 'Wrist_FLEX';
        dataLabels{1, 18}   = 'Wrist_ABD';
    case 'EyeTracker'
        dataLabels          = cell( 2, 29 );
        dataLabels(2, :)    = {'EyeTracker'};
        dataLabels{1, 1}    = 'System_Time';
        dataLabels{1, 2}    = 'Server_Time';
        dataLabels{1, 3}    = 'Eye_Frame_Number';
        dataLabels{1, 4}    = 'Scene Frame Number';
        dataLabels{1, 5}    = 'GazeBasePoint_L_X';
        dataLabels{1, 6}    = 'GazeBasePoint_L_Y';
        dataLabels{1, 7}    = 'GazeBasePoint_L_Z';
        dataLabels{1, 8}    = 'GazeDirection_L_X';
        dataLabels{1, 9}    = 'GazeDirection_L_Y';
        dataLabels{1, 10}   = 'GazeDirection_L_Z';
        dataLabels{1, 11}   = 'PupilDiameter_L_X';
        dataLabels{1, 12}   = 'PupilDiameter_L_Y';
        dataLabels{1, 13}   = 'PupilRadius_L';
        dataLabels{1, 14}   = 'PupilConfidence_L';
        dataLabels{1, 15}   = 'PointOfRegard_L_X';
        dataLabels{1, 16}   = 'PointOfRegard_L_Y';
        dataLabels{1, 17}   = 'GazeBasePoint_R_X';
        dataLabels{1, 18}   = 'GazeBasePoint_R_Y';
        dataLabels{1, 19}   = 'GazeBasePoint_R_Z';
        dataLabels{1, 20}   = 'GazeDirection_R_X';
        dataLabels{1, 21}   = 'GazeDirection_R_Y';
        dataLabels{1, 22}   = 'GazeDirection_R_Z';
        dataLabels{1, 23}   = 'PupilDiameter_R_X';
        dataLabels{1, 24}   = 'PupilDiameter_R_Y';
        dataLabels{1, 25}   = 'PupilRadius_R';
        dataLabels{1, 26}   = 'PupilConfidence_R';
        dataLabels{1, 27}   = 'PointOfRegard_R_X';
        dataLabels{1, 28}   = 'PointOfRegard_R_Y';
        dataLabels{1, 29}   = 'Sync_OR_Calib_Checkpoint'; % 1 or 2
    case 'All'
        dataLabels = makeDataLabels( {'EyeTracker', 'RightGlove', ...
           'LeftGlove', 'Suit' } );
    otherwise
        error( 'Modality needs to be one of the following: Suit, RightGlove, LeftGlove, EyeTracker or All.' )
end

end