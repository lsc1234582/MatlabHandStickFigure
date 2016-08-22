function [X, cal] = calibrateData( X, cal )
% function [X, cal] = calibrateData( X, cal )
% Calibrates the data obtained from a Cyberglove. 


if ischar( cal )
    if size( X, 2 ) == 18
        cal = loadCal( cal, 'l' );
    elseif size( X, 2 ) == 22
        cal = loadCal( cal, 'r' );
    else
        error( 'Unknown data type. Please ensure the data has either 18 or 22 dimensions.' )
    end
end

X = bsxfun( @minus, X, cal(:, 1)' );
X = bsxfun( @times, X, cal(:, 2)' );
end

function cal = loadCal( fileName, hand )

delimiter = ' ';
startRow = 2;
formatSpec = '%s %s %s %s %[^\n\r]';

% Read calibration file
fileID = fopen(fileName, 'r');
tmp = textscan(fileID, formatSpec, 'Delimiter', delimiter, ...
    'MultipleDelimsAsOne', true, 'HeaderLines' ,startRow-1, ...
    'ReturnOnError', false);
fclose(fileID);

for k = 1:numel( tmp )
    for l = 1:numel( tmp{k} )
        tmp{k}{l} = str2double( tmp{k}{l} );
    end
end

ok_ = ~isnan( cell2mat( tmp{1} ) );

cal = [cell2mat( tmp{2} ) cell2mat( tmp{3} )];
cal = cal(ok_, :);

cal(12, 2) = cal(8, 2); % Because the files are messed up by the system

if any( strcmp( hand, {'r', 'R', 'right'} ) )
    cal([8 end], :) = [];   % Those two rows have no corresponding sensor.
elseif any( strcmp( hand, {'l', 'L', 'left'} ) )
    cal([7 8 11 15 19 end], :) = [];
else
    error( 'The handedness needs to be specified!' )
end
end