function suitSides = getSkelSide(skel, I, J)
% suitSides figures out the 'sideness' (left or right hand side) of the 'bones'
% of the stick figure
% Returns: 
%   suitSides - an array containing sideness of all 'bones'
% Arguments:
%   skel - skel struct
%   I - indices of the begining joints of the 'bones'
%   J - indices of the end joints of the 'bones'

for i = 1:length(I)
    joint1 = skel.tree(I(i)).name;
    joint2 = skel.tree(J(i)).name;
    if ~isempty(strfind(joint1, 'Left')) || ...
            ~isempty(strfind(joint2, 'Left'))
        suitSides{i} = 'Left';
    else
        if ~isempty(strfind(joint1, 'Right')) || ...
            ~isempty(strfind(joint2, 'Right'))
            suitSides{i} = 'Right';
        else
            suitSides{i} = 'Middle';
        end
    end     
end