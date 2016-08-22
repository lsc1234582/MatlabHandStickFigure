function bvhWriteFile(fileName, skel, channels, cheat, frameLength)

% BVHWRITEFILE Write a bvh file from a given structure and channels.
%
%	Description:
%
%	BVHWRITEFILE(FILENAME, SKEL, CHANNELS, CHEAT, FRAMELENGTH) writes a bvh
%	file from a given structure and channels.
%	 Arguments:
%	  FILENAME - the file name to use.
%	  SKEL - the skeleton structure to use.
%	  CHANNELS - the channels to use.
%	  FRAMELENGTH - the length of a frame.
%
%
%	See also
%	BVHREADFILE


%	Copyright (c) 2006 Neil D. Lawrence
% 	bvhWriteFile.m CVS version 1.2
% 	bvhWriteFile.m SVN version 42
% 	last update 2008-08-12T20:23:47.000000Z

global SAVECHANNELS
SAVECHANNELS = [];

if nargin < 4
    cheat = false;
    frameLength = 0.03333;
end

if nargin < 5
    frameLength = 0.03333;
end

fid = fopen(fileName, 'w');
depth = 0;
printedNodes = [];
fprintf(fid, 'HIERARCHY\n');
i = 1;
while ~any(printedNodes==i)
    printedNodes = printNode(fid, 1, skel, printedNodes, depth, channels, cheat);
end
fprintf(fid, 'MOTION\n');
fprintf(fid, 'Frames: %d\n', size(channels, 1));
fprintf(fid, 'Frame Time: %2.6f\n', frameLength);

if cheat
    SAVECHANNELS = channels';
    SAVECHANNELS = SAVECHANNELS(:);
    fprintf(fid, [repmat( '%2.4f ', 1, 65 ) '%2.4f\n'], SAVECHANNELS);
    fclose( fid );
    return
end

for i = 1:size( channels, 1 )
    for j = 1:size( channels, 2 )
        fprintf(fid, '%2.4f ', SAVECHANNELS(i, j));
    end
    fprintf(fid, '\n');
end
fclose(fid);



function printedNodes = printNode(fid, j, skel, printedNodes, ...
    depth, channels, cheat)

% PRINTNODE Print out the details from the given node.

global SAVECHANNELS

prePart = computePrePart(depth);
if depth > 0
    if strcmp(skel.tree(j).name, 'Site')
        fprintf(fid, [prePart 'End Site\n']);
    else
        fprintf(fid, [prePart 'JOINT %s\n'], skel.tree(j).name);
    end
else
    fprintf(fid, [prePart 'ROOT %s\n'], skel.tree(j).name);
end
fprintf(fid, [prePart '{\n']);
depth = depth + 1;
prePart = computePrePart(depth);
fprintf(fid, [prePart 'OFFSET %2.4f %2.4f %2.4f\n'], ...
    skel.tree(j).offset(1), ...
    skel.tree(j).offset(2), ...
    skel.tree(j).offset(3));
if ~strcmp(skel.tree(j).name, 'Site')
    fprintf(fid, [prePart 'CHANNELS %d'], length(skel.tree(j).channels));
    if any(strcmp('Xposition', skel.tree(j).channels))
        if ~cheat
            SAVECHANNELS = [SAVECHANNELS channels(:, skel.tree(j).posInd(1))];
        end
        fprintf(fid, ' Xposition');
    end
    if any(strcmp('Yposition', skel.tree(j).channels))
        if ~cheat
            SAVECHANNELS = [SAVECHANNELS channels(:, skel.tree(j).posInd(2))];
        end
        fprintf(fid, ' Yposition');
    end
    if any(strcmp('Zposition', skel.tree(j).channels))
        if ~cheat
            SAVECHANNELS = [SAVECHANNELS channels(:, skel.tree(j).posInd(3))];
        end
        fprintf(fid, ' Zposition');
    end
    if any(strcmp('Zrotation', skel.tree(j).channels))
        if ~cheat
            SAVECHANNELS = [SAVECHANNELS channels(:, skel.tree(j).rotInd(3))];
        end
        fprintf(fid, ' Zrotation');
    end
    if any(strcmp('Xrotation', skel.tree(j).channels))
        if ~cheat
            SAVECHANNELS = [SAVECHANNELS channels(:, skel.tree(j).rotInd(1))];
        end
        fprintf(fid, ' Xrotation');
    end
    if any(strcmp('Yrotation', skel.tree(j).channels))
        if ~cheat
            SAVECHANNELS = [SAVECHANNELS channels(:, skel.tree(j).rotInd(2))];
        end
        fprintf(fid, ' Yrotation');
    end
    fprintf(fid, '\n');
end

% print out channels
printedNodes = j;
for i = skel.tree(j).children
    printedNodes = [printedNodes printNode(fid, i, skel, printedNodes, ...
        depth, channels, cheat)];
end
depth = depth - 1;
prePart = computePrePart(depth);
fprintf(fid, [prePart '}\n']);


function prePart = computePrePart(depth);

prePart = [];
for i = 1:depth
    prePart = [prePart '\t'];
end
