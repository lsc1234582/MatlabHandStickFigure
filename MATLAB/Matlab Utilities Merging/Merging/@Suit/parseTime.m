function [time, ID] = parseTime( filename )
% function [time, ID] = parseTime( filename )
% Parses the time stamps for suit files.
%
% Inputs:
% <fileName>    Full path to the BVH file to be read.
%
% Outputs:
% <time>        Nx4 matrix of time-stamps.
% 
% <ID>          
% 
% Written by Andreas Thomik, November 2014.

% Set the format specifier
delimiter = {' '};
startRow = 1;
formatSpec = '%s%f%f%f%f%[^\n\r]';

% Open the text file.
fileID = fopen( filename, 'r' );

% Read columns of data according to format string.
dataArray = textscan( fileID, formatSpec, 'Delimiter', delimiter, ...
    'MultipleDelimsAsOne', 1, 'HeaderLines', startRow-1, 'EmptyValue', NaN );

% Close the text file.
fclose( fileID );

% Return the data and time stamp according to the file read
minLength = size( dataArray{1}, 1 );
sameLength = true;
for k = 1:size( dataArray, 2 )-1
    if size( dataArray{k}, 1 ) < minLength
        minLength = size( dataArray{k}, 1 );
        sameLength = false;
    end
end

if ~sameLength
    warning( 'The data record may be corrupted. Check file!' )
    for k = 1:size( dataArray, 2 )
        dataArray{k} = dataArray{k}(1:minLength);
    end
end

ID      = dataArray{1}; 
data    = [dataArray{2:end-1}];

timeArr = data(strcmp( '#T', ID ), :);
time    = getMilliSecondTime( timeArr );
IDTime  = data(~strcmp( '#T', ID ), :);
tmp.ID  = ID(~strcmp( '#T', ID ));
tmp.Time = getMilliSecondTime( IDTime );
ID = tmp;

end