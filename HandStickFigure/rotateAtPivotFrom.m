function rotateAtPivotFrom(Vs, Vs_copy, rot, pivot)
%{
    Rotate vertices Vs with rot (degrees) at position pivot

    rot = [XAxis, YAxis, ZAxis] (in degree)
%}

Vc = Vs_copy-ones(size(Vs_copy,1),1)*pivot; %Centering coordinates
E = rot*pi./180;
%Direction Cosines (rotation matrix) construction
Rx=[1        0        0;...
    0        cos(E(1))  -sin(E(1));...
    0        sin(E(1))  cos(E(1))]; %X-Axis rotation
Ry=[cos(E(2))  0        sin(E(2));...
    0        1        0;...
    -sin(E(2)) 0        cos(E(2))]; %Y-axis rotation
Rz=[cos(E(3))  -sin(E(3)) 0;...
    sin(E(3))  cos(E(3))  0;...
    0        0        1]; %Z-axis rotation
R=Rx*Ry*Rz; %Rotation matrix
Vrc=[R*Vc']'; %Rotating centred coordinates
Vr=Vrc+ones(size(Vs_copy,1),1)*pivot; %Shifting back to original location

set(Vs, 'XData', Vr(:, 1), 'YData', Vr(:, 2), 'ZData', Vr(:, 3));