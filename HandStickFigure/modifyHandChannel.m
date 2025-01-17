function modifiedCh = modifyHandChannel(ch, fingerAbdW)
% modifyHandChannel(ch, fingerAbdW)
% 
% Converts raw (calibrated) sensor data into joint angle data that can be
% used by bvh skeleton to play back motion.
%
% Returns:
%   modifiedCh: converted channel
%
% Arguments:
%   ch: raw and calibrated sensor data
%   fingerAbdW: a 3x2 matrix containing linear weights for the extent of 
%       left/hand finger abduction sensors; if left blanck default value 
%       [1,0;0,1;0,1] will be used.

if isempty(fingerAbdW)
    fingerAbdW = [1,0;0,1;0,1];
end
    
% A little bit of magic
if size(ch, 2) == 18
    neg_dang = [fingerAbdW(1,1)*ch(:, 9), fingerAbdW(2,1)*ch(:, 12), fingerAbdW(3,1)*ch(:, 15)];
    pos_dang = [fingerAbdW(1,2)*ch(:, 9), fingerAbdW(2,2)*ch(:, 12), fingerAbdW(3,2)*ch(:, 15)];

    abs_abd = [neg_dang(:, 1), neg_dang(:, 2:3) - pos_dang(:, 1:2), -pos_dang(:, 3)];

    ch = [ch(:, 1:6), abs_abd(:, 1), ch(:, 7:8), abs_abd(:, 2), ch(:, 10:11), ...
        abs_abd(:, 3), ch(:, 13:14), abs_abd(:, 4), ch(:, 16:18)];

    % Negate y rotation for left hand.
    modifiedCh = [-ch(:,18), ch(:,19), ...
        -ch(:,1), ch(:,4), ...
        ch(:,2), ...
        ch(:,3), ...
        -ch(:,5), ch(:,7), ...
        -ch(:,6), ...
        -ch(:,8), ch(:,10), ...
        -ch(:,9), ...
        -ch(:,11), ch(:,13), ...
        -ch(:,12), ...
        -ch(:,14), ch(:,16), ...
        -ch(:,15)];
else
    neg_dang = [fingerAbdW(1,1)*ch(:, 11), fingerAbdW(2,1)*ch(:, 15), fingerAbdW(3,1)*ch(:, 19)];
    pos_dang = [fingerAbdW(1,2)*ch(:, 11), fingerAbdW(2,2)*ch(:, 15), fingerAbdW(3,2)*ch(:, 19)];

    abs_abd = [neg_dang(:, 1), neg_dang(:, 2:3) - pos_dang(:, 1:2), -pos_dang(:, 3)];

    ch = [ch(:, 1:7), abs_abd(:, 1), ch(:, 8:10), abs_abd(:, 2), ch(:, 12:14), ...
        abs_abd(:, 3), ch(:, 16:18), abs_abd(:, 4), ch(:, 20:22)];

    modifiedCh = [ch(:,22:23), ...
        ch(:,1), ch(:,4), ...
        ch(:,2), ...
        ch(:,3), ...
        ch(:,5), ch(:,8), ...
        ch(:,6), ...
        ch(:,7), ...
        ch(:,9), ch(:,12), ...
        ch(:,10), ...
        ch(:,11), ...
        ch(:,13), ch(:,16), ...
        ch(:,14), ...
        ch(:,15), ...
        ch(:,17), ch(:,20), ...
        ch(:,18), ...
        ch(:,19),];
end
