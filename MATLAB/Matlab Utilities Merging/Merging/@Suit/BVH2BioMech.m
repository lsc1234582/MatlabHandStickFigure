function Body = BVH2BioMech( S )
% function Body = BVH2BioMech( S )
% Transforms BVH data collected by the suit into biomechanically relevant
% values.
%
% Inputs:
% <S>       Suit object.
%
% Outputs:
% <Body>    Structure with biomechanical angles for all joints covered by
%           the suit.
%
% Written by Andreas Thomik, November 2014

C = S.Data;

D = size( C, 2 );

r2a = 180 / pi;
a2r = pi / 180;

for k = 1:3:D
    if k <=4 && D == 66
        continue
    end
    Z = C(:, k:k+2) * a2r;
    R = angle2dcm( Z(:, 1), Z(:, 2), Z(:, 3), 'ZXY' );

    if k == 61 % Neck
        [ry, rx, rz] = dcm2angle( R, 'YXZ' );
        tmp.Flexion     = rx * r2a;
        tmp.Abduction   = rz * r2a;
        tmp.Torsion     = ry * r2a;
        tmp.All         = [tmp.Flexion tmp.Abduction tmp.Torsion];
        tmp.AllLabels   = {'Flexion', 'Abduction', 'Torsion'};
        
        Body.Neck = tmp;
    elseif any( [31 34] == k ) % spine
        [rx, rz, ry] = dcm2angle( R, 'XZY' );
        tmp.Flexion     = rx * r2a;
        tmp.Abduction   = rz * r2a;
        tmp.Torsion     = ry * r2a;
        tmp.All         = [tmp.Flexion tmp.Abduction tmp.Torsion];
        tmp.AllLabels   = {'Flexion', 'Abduction', 'Torsion'};
        
        if k == 31
            Body.MidSpine = tmp;
        else
            Body.UpSpine = tmp;
        end
    elseif any( [7 19] == k ) % hip
        [rx, rz, ry] = dcm2angle( R, 'XZY' );
        tmp.Flexion     = rx * r2a;
        tmp.AllLabels   = {'Flexion', 'Abduction', 'Internal Rotation'};
        
        if k == 7
            tmp.Abduction   = -rz * r2a;
            tmp.InternalRot = -ry * r2a;
            tmp.All         = [tmp.Flexion tmp.Abduction tmp.InternalRot];
            Body.LeftHip = tmp;
        else
            tmp.Abduction   = rz * r2a;
            tmp.InternalRot = ry * r2a;
            tmp.All         = [tmp.Flexion tmp.Abduction tmp.InternalRot];
            Body.RightHip = tmp;
        end
    elseif any( [10 22] == k ) % knees
        [rx, rz, ry] = dcm2angle( R, 'XZY' );
        tmp.Flexion     = rx * r2a;
        tmp.AllLabels   = {'Flexion', 'Abduction', 'Axial Rotation'};
        
        if k == 10
            tmp.Abduction   = -rz * r2a;
            tmp.AxialRot    = -ry * r2a;
            tmp.All         = [tmp.Flexion tmp.Abduction tmp.AxialRot];
            Body.LeftKnee = tmp;
        else
            tmp.Abduction   = rz * r2a;
            tmp.AxialRot    = ry * r2a;
            tmp.All         = [tmp.Flexion tmp.Abduction tmp.AxialRot];
            Body.RightKnee = tmp;
        end
    elseif any( [13 25] == k ) % ankles
        [rx, rz, ry] = dcm2angle( R, 'XZY' );
        tmp.Flexion     = rx * r2a;
        tmp.AllLabels   = {'Flexion', 'Inversion', 'Internal Rotation'};
        
        if k == 13
            tmp.Inversion   = -rz * r2a;
            tmp.InternalRot = -ry * r2a;
            tmp.All         = [tmp.Flexion tmp.Inversion tmp.InternalRot];
            Body.LeftAnkle = tmp;
        else
            tmp.Inversion   = rz * r2a;
            tmp.InternalRot = ry * r2a;
            tmp.All         = [tmp.Flexion tmp.Inversion tmp.InternalRot];
            Body.RightAnkle = tmp;
        end
    elseif any( [37 49] == k ) % clavicle
        [ry, rz, rx] = dcm2angle( R, 'YZX' );
        tmp.AxialRot    = rx * r2a;
        tmp.AllLabels   = {'Protraction', 'Elevation', 'Axial Rotation'};
        
        if k == 37
            tmp.Protraction = -ry * r2a;
            tmp.Elevation   = -rz * r2a;
            tmp.All         = [tmp.Protraction tmp.Elevation tmp.AxialRot];
            Body.LeftClavicle = tmp;
        else
            tmp.Protraction = ry * r2a;
            tmp.Elevation   = rz * r2a;
            tmp.All         = [tmp.Protraction tmp.Elevation tmp.AxialRot];
            Body.RightClavicle = tmp;
        end
    elseif any( [40 52] == k ) % shoulders
        [ry1, rz, ry2] = dcm2angle( R, 'YZY' );
%         tmp.Direction = deSwitch( ry1 * r2a, 180 );
        tmp.Direction = ry1 * r2a;
        ix = tmp.Direction > 0;
        tmp.Direction(ix) = tmp.Direction(ix) - 180;
        ix = ix | tmp.Direction == 0;
        tmp.Direction(~ix) = tmp.Direction(~ix) + 180;
        tmp.Direction = deSwitch( tmp.Direction, 'deg' );
        tmp.Elevation = -rz * r2a;
        tmp.AxialRot  = deSwitch( (ry1 + ry2 ) * r2a, 'deg' );
        
        if k == 40 % Change sign for left side
            tmp.Direction   = -(tmp.Direction + 180);
            tmp.AxialRot    = -tmp.AxialRot;
        end
        
        tmp.All       = [tmp.Direction tmp.Elevation tmp.AxialRot];
        tmp.AllLabels = {'Direction', 'Elevation', 'Axial Rotation'};
        
        if k == 40
            Body.LeftShoulder = tmp;
        else
            Body.RightShoulder = tmp;
        end
    elseif any( [43 55] == k ) % elbows
        [rx, rz, ry] = dcm2angle( R, 'XZY' );
        tmp.Flexion      = -rx * r2a; % Negative to comply with convention
        tmp.AllLabels = {'Flexion', 'Pronation', 'Abduction (should be 0)'};
        
        if k == 43
            tmp.Pronation    = -ry * r2a;
            tmp.Abduction    = -rz * r2a;
            tmp.All       = [tmp.Flexion tmp.Pronation tmp.Abduction];
            Body.LeftElbow = tmp;
        else
            tmp.Pronation    = ry * r2a;
            tmp.Abduction    = rz * r2a;
            tmp.All       = [tmp.Flexion tmp.Pronation tmp.Abduction];
            Body.RightElbow = tmp;
        end
    elseif any( [46 58] == k ) % wrists
        % NOT WORKING PROPERLY - NEED TO DEFINE ORDER
        [rz, rx, ry] = dcm2angle( R, 'ZXY' );
        tmp.Abduction    = rx * r2a;
        tmp.AllLabels = {'Flexion', 'Abduction', 'Pronation (should be 0)'};
        
        if k == 46
            tmp.Flexion      = -rz * r2a;
            tmp.Pronation    = -ry * r2a;
            tmp.All       = [tmp.Flexion tmp.Abduction tmp.Pronation];
            Body.LeftWrist = tmp;
        else
            tmp.Flexion      = rz * r2a;
            tmp.Pronation    = ry * r2a;
            tmp.All       = [tmp.Flexion tmp.Abduction tmp.Pronation];
            Body.RightWrist = tmp;
        end
    else
        [ry, rz, rx] = dcm2angle( R, 'YZX' );
    end

    clearvars tmp rx ry1 ry2 rz
end

S.BioMechData = Body;

end