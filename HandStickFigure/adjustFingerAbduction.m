function modifiedch = adjustFingerAbduction(ch)
% Infer Zrotation(absolute abduction) angles (in degree) for all finger lower joints
% from finger abduction sensors(local abduction).
% Adds an extra channel (the 8th channel) for Zrotation(abduction) of index
% lower joint
% Thumb absolute abduction angle's deviation from local abduction is insignificant 
% thus not inferred

dang = 0.5 * [ch(:, 11) ch(:, 15) ch(:, 19)];
% A little bit of magic
abs_abd = [dang(:, 1), dang(:, 2:3) - dang(:, 1:2), -dang(:, 3)];

modifiedch = [ch(:, 1:7), abs_abd(:, 1), ch(:, 8:10), abs_abd(:, 2), ch(:, 12:14), ...
    abs_abd(:, 3), ch(:, 16:18), abs_abd(:, 4), ch(:, 20:22)];

