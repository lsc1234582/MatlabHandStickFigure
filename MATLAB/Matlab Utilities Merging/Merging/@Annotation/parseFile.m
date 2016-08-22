function out = parseFile( path, type, ver )
% function out = parseFile( path, ver )
% Parses annotation files recorded with DALI or logING
%
% Inputs:
% <path>    Path to the file to be parsed.
%
% <type>    String indicating the software used for recording the data. Can
%           be either 'DALI' or 'LogING'.
%
% <ver>     String indicating the version of the recording software. This 
%           can be passed either as the recording date ('YYYY-MM-DD') or as
%           software version ('vXX').
%           Required only for DALI records.
%
% Outputs:
% <out>     Struct with the following fields:
%               - Time: Nx1 vector. Time stamps in milliseconds since
%                   midnight on that day.
%               - Action: Nx1 cell vector. Name of the action being
%                   performed at that time.
%               - ID: NxM double matrix with non-zero entries whenever an
%                   action is being performed
%               - Map: Cell array. Maps Action to ID.
%
% Written by Andreas Thomik, December 2014.

switch type
    case 'DALI'
        out = parseDALI( path, ver );
    case 'LogING'
        out = parseLogING( path );
    otherwise
        error( 'Unknown annotation method.' )
end

end

function out = parseDALI( path, ver )

try
    data = load( path );
    disp( ['Read ' num2str( size( data, 1 ) ) ' lines of valid annotations.' ] )
catch
    disp( 'The file seems to be broken, trying to open again...' )
    data = parseBrokenDALI( path );
    disp( ['Read ' num2str( size( data, 1 ) ) ' lines of valid annotations.' ] )
end

timeStamp   = data(:, 1:4);
actionID    = data(:, 5:end);
actionID    = num2cell( actionID, 2 );

% Determine recording date
dateRegExp = '(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})';
recDate = regexp( ver, dateRegExp, 'names' );
recDate = structfun( @str2double, recDate );

% Check what version of the recording we are looking at
if recDate(1) <= 2013 && recDate(2) <= 9 && recDate(3) <= 21
    oldFileType = true;
else
    oldFileType = false;
end

% Determine path of file
locPath = mfilename( 'fullpath' );
locPath(strfind( locPath, '\parseFile' )+1:end) = [];

switch oldFileType
    case true
        [sL, tL] = Annotation.parseAnnotationXLS( [locPath 'AnnotationList.xlsx'] );
        %[id, act] = xlsread( [locPath 'AnnotationList.xlsx'], 'actionList_Prior_21092013' );
        load( [locPath 'AnnotId.mat']);
        load( [locPath 'AnnotNames.mat']);
        
        [uid, ia] = unique( id(:, 3) );
        uacts = act(ia);
        map.ActionMap = [num2cell( uid, 2 ), uacts];
    case false
        [sL, tL, aL, aMap] = Annotation.parseAnnotationXLS( [locPath 'AnnotationList.xlsx'] );
        id  = cell2mat( aL(:, 1:3) );
        act = aL(:, 4);
        map.ActionMap = fliplr( aMap );
end

[uid, ia] =  unique( [tL{:, 2}] );
utasks = tL(ia, 3);
map.TaskMap = [num2cell( uid', 2 ) utasks];

[uid, ia] =  unique( [sL{:, 1}] );
usetts = sL(ia, 2);
map.SettingMap = [num2cell( uid', 2 ) usetts];

ID = cell2mat( actionID );
Action = ID(:, 3);
Action(Action == 0) = NaN;
Task = ID(:, 2);
Task(Task == 0) = NaN;
Setting = ID(:, 1);
Setting(Setting == 0) = NaN;

% Prepare output
out.Time    = getMilliSecondTime( timeStamp );
out.Action  = bsxfun( @eq, repmat( Action, 1, size( map.ActionMap, 1 ) ), 1:size( map.ActionMap, 1 ) );
out.Map     = map;
out.Task    = Task;
out.Setting = Setting;

end

function data = parseBrokenDALI( path )
% Parses the file in a more principled way than load, can be useful if the
% file is somehow broken.

delimiter = {'\t', ' '};
startRow = 1;
formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';

% Open the text file.
fileID = fopen( path, 'r' );

% Read columns of data according to format string.
dataArray = textscan( fileID, formatSpec, 'Delimiter', delimiter, ...
    'MultipleDelimsAsOne', 1, 'HeaderLines', startRow-1, 'EmptyValue', NaN );

% Close the text file.
fclose( fileID );

data = [dataArray{1:end-1}];
data = str2double( data );

% Check how many lines are broken
bad = sum( isnan( data ) );
bad = max( bad );

disp( ['Found ' num2str( bad ) ' broken lines'] )
disp( 'Discarding broken lines...' )

ok_ = sum( isnan( data ), 2 ) == 0;
data(~ok_, :) = [];

disp( ['Read ' num2str( size( data, 1 ) ) ' lines of valid annotations.' ] )

end

function out = parseLogING( filePath )
% function out = parseLogING( filePath )

load( filePath )

T = Events.time;
E = Events.event;

%% Check for size consistency
if any( size( T ) ~= size( E ) )
    disp( ['Error parsing log file ' filePath '.'])
    disp( 'The number of events and of timestamps does not match.' )
    out.Action  = [];
    out.Task    = [];
    out.Setting = [];
    out.Map.ActionMap   = [];
    out.Map.TaskMap     = [];
    out.Map.SettingMap  = [];
    out.Time = [];
    return
end

%% Remove any empty annotations and time stamps
ix = ~cellfun( @isempty, E );
T = T(ix);
E = E(ix);

%% Give unique identifier to each event
locPath = mfilename( 'fullpath' );
locPath(strfind( locPath, '\parseFile' )+1:end) = [];
tmp = load( [locPath 'LogINGActionIDs.mat'] );
ActionID = tmp.ActionID;
ID = 1:numel( ActionID );

for k = 1:length( ActionID )
    if ~strcmpi( ActionID{k}(end), 'S' )
        continue
    end
    action = ActionID{k};
    action(end) = 'E';
    ix = strcmpi( action, ActionID );
    ID(ix) = -ID(k);
end

uIX = unique( abs( ID ) );
[~, ix] = ismember( E, ActionID );
ix(ix==0) = [];
eID = ID(ix);

t = 0:0.1:roundn( T(end), -1 );
t = roundn( t, -1 ); % To compensate for numerical inaccuracies
out = nan( length( uIX ), length( t ) );

for k = 1:length( uIX )
    
    ixS = find( eID == uIX(k) );
    ixE = find( eID == -uIX(k) );
    
    if ~isempty( ixE ) && ~isempty( ixS )
        if length( ixS ) == length( ixE )
            for l = 1:length( ixS )
                tS = find( t == roundn( T(ixS(l)), -1 ) );
                tE = find( t == roundn( T(ixE(l)), -1 ) );
                out(k, tS:tE) = 1;
            end
        elseif length( ixS ) > length( ixE )
            % Find matching start and end times
            % Equivalent to finding closest start to end time
            ok_ = false( size( ixS ) );
            for l = 1:length( ixE )
                tmp = ixE(l) - ixS;
                tmp( tmp < 0 ) = Inf;   % Exclude starting points after the end
                [~, tmp] = min( tmp );
                ok_(tmp) = true;
            end
            ixS2 = ixS(ok_);
            for l = 1:length( ixS2 )
                tS = find( t == roundn( T(ixS2(l)), -1 ) );
                tE = find( t == roundn( T(ixE(l)), -1 ) );
                out(k, tS:tE) = 1;
            end
            
            ixS2 = ixS(~ok_);
            for l = 1:length( ixS2 )
                tS = find( t == roundn( T(ixS2(l)), -1 ) );
                out(k, tS) = 2;
            end
        else % if length( ixE ) > length( ixS )
            % Find matching start and end times
            ok_ = false( size( ixE ) );
            for l = 1:length( ixS )
                tmp = ixE - ixS(l);
                tmp( tmp < 0 ) = Inf;   % Exclude starting points after the end
                [~, tmp] = min( tmp );
                ok_(tmp) = true;
            end
            ixE2 = ixE(ok_);
            for l = 1:length( ixE2 )
                tS = find( t == roundn( T(ixS(l)), -1 ) );
                tE = find( t == roundn( T(ixE2(l)), -1 ) );
                out(k, tS:tE) = 1;
            end
            
            ixE2 = ixE(~ok_);
            for l = 1:length( ixE2 )
                tE = find( t == roundn( T(ixE2(l)), -1 ) );
                out(k, tE) = -2;
            end
        end
    elseif isempty( ixE )
        for l = 1:length( ixS )
            tS = find( t == roundn( T(ixS(l)), -1 ) );
            out(k, tS) = 3;
        end
    elseif isempty( ixS )
        for l = 1:length( ixE )
            tE = find( t == roundn( T(ixE(l)), -1 ) );
            out(k, tE) = -3;
        end
    end
end

actions = ActionID(uIX);

tmp = out';
clearvars out

[~, ix] = unique( abs( ID ) );

out.Action  = tmp;
out.Task    = nan( size( tmp, 1 ), 1 );
out.Setting = nan( size( tmp, 1 ), 1 );
out.Map.ActionMap   = ActionID(ix);
out.Map.TaskMap     = [];
out.Map.SettingMap  = [];
out.Time = t';

end