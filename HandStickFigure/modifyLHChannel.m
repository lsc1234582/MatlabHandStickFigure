function modifiedCh = modifyLHChannel(ch, fingerAbdW, chAdj)
% Extra chanel for Zrotation for index lower joint
% After testing para is best to be set [1,0;0,1;0,1]
if isempty(fingerAbdW)
    fingerAbdW = [1,0;0,1;0,1];
end
if isempty(chAdj)
    chAdj = zeros(1, 18);
end

% A little bit of magic
neg_dang = [fingerAbdW(1,1)*ch(:, 9), fingerAbdW(2,1)*ch(:, 12), fingerAbdW(3,1)*ch(:, 15)];
pos_dang = [fingerAbdW(1,2)*ch(:, 9), fingerAbdW(2,2)*ch(:, 12), fingerAbdW(3,2)*ch(:, 15)];

abs_abd = [neg_dang(:, 1), neg_dang(:, 2:3) - pos_dang(:, 1:2), -pos_dang(:, 3)];

ch = [ch(:, 1:6), abs_abd(:, 1), ch(:, 7:8), abs_abd(:, 2), ch(:, 10:11), ...
    abs_abd(:, 3), ch(:, 13:14), abs_abd(:, 4), ch(:, 16:18)];

modifiedCh = [ch(:,18:19), ...
    ch(:,1), ch(:,4), ...
    ch(:,2), ...
    ch(:,3), ...
    ch(:,5), ch(:,7), ...
    ch(:,6), ...
    ch(:,8), ch(:,10), ...
    ch(:,9), ...
    ch(:,11), ch(:,13), ...
    ch(:,12), ...
    ch(:,14), ch(:,16), ...
    ch(:,15)];