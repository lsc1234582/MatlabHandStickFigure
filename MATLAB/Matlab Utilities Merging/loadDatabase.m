function dB_ = loadDatabase( fPath )
% function dB_ = loadDatabase( fPath )
% Loads MAT and Excel datab ases, merges their values and returns the
% merged database as Matlab table. Copies of the old databases are 
% backed up and the merged data base is saved in MAT and Excel format.
%
% Optional Inputs:
% <fPath>   Path to the folder where the database files are stored.
%           Default is 'L:\Data'.
%
% Outputs:
% <dB_>     Matlab table containing the merged input from the Excel and MAT
%           data base.
%
% Written by Andreas Thomik, November 2014
%
% Update by Andreas Thomik, November 2014:
% Modified backup to save as .zip and keep previous versions (limited to
% one version per day)
%
% TODO (IMPORTANT): handling of linkedFiles seems to be buggy.

if nargin == 0 || isempty( fPath )
    fPath = 'L:\Data\';
end

%% Determine most recent file
matDate = dir( [fPath 'database.mat'] );
matDate = matDate.datenum;

xlsDate = dir( [fPath 'database.xlsx'] );
xlsDate = xlsDate.datenum;

if xlsDate > matDate
    disp( 'Excel file determined as being most recent.' )
    ref = 'xls';
elseif matDate > xlsDate
    disp( 'Matlab file determined as being most recent.' )
    ref = 'mat';
else
    error( 'Could not determine the precedence of database files.' )
end

%% Do a bit of house keeping

% Matlab data base
dB0_ = load( [fPath 'database.mat'], 'dB_' );
dB0_ = dB0_.dB_;
dB0_ = struct2table( dB0_ );
% linkedFiles is a struct array which cannot be written to an Excel file
% Always use the one from the Matlab file. Separate to allow merger.

linkedFiles = dB0_(:, 'linkedFiles');
dB0_(:, 'linkedFiles') = [];

% Older database files may have a problem with hasLog and supInfo
ix = cellfun( @isempty, dB0_{:, 'hasLog'} );
dB0_{ix, 'hasLog'} = {false};
tmp = cell2table( dB0_{:, 'hasLog'} );
dB0_(:, 'hasLog') = [];
dB0_(:, 'hasLog') = tmp;

ix = cellfun( @isempty, dB0_{:, 'supInfo'} );
dB0_{ix, 'supInfo'} = {''};

% Excel data base
dB1_ = readtable( [fPath 'database.xlsx'] );
dB1_(:, 'linkedFiles') = [];

ix = arrayfun( @isnan, dB1_{:, 'hasLog'} );
dB1_{ix, 'hasLog'} = false;

% Test whether the record dates are in the same format
fID = dB0_{1, 'FileID'};
testEntry = dB1_(dB1_{:, 'FileID'} == fID, :);

if datenum( dB0_{1, 'RecordDate'} ) ~= datenum( testEntry{1, 'RecordDate'} )
    disp( 'Date formats are not matching, trying to fix it.' )
    tmpDates = dB1_{:, 'RecordDate'};
    tmpDates = datestr( datenum( tmpDates, 'dd/mm/yyyy' ), 26 );
    tmpDates = num2cell( tmpDates, 2 );
    tmpDates = strrep( tmpDates, '/', '-' );
    ix = dB1_{:, 'FileID'} == fID;
    if datenum( dB0_{1, 'RecordDate'} ) ~= datenum( tmpDates(ix) )
        error( 'Could not fix the date format.' )
    else
        disp( 'Date fixed!' )
        dB1_(:, 'RecordDate') = cell2table( tmpDates );
    end
end
    
%% Join data bases
dB_ = outerjoin( dB0_, dB1_, 'MergeKeys', true );
clearvars -except dB_ linkedFiles fPath ref

%% Conflicting entries are not merged - do it manually
[~, ia, ic] = unique( dB_{:, 'FileID'}, 'stable' );

if numel( ia ) == numel( ic )
    return
end

disp( 'Conflicts found, trying to resolve them...' )

varNames = dB_.Properties.VariableNames;
dB2_ = table2cell( dB_ );
dB_ = cell( numel( ia ), width( dB_ ) );

for k = 1:numel( ia )
    if sum( ic == ic(ia(k)) ) == 1 % There are no other entries with the same ID
        dB_(k, :) = dB2_(ia(k), :);
        continue
    end
    
    disp( ['Conflict found with entry ' dB2_{ia(k), 1}] )
    
    ix = find( ic == ic(ia(k)) );
    for l = 1:size( dB_, 2 )
        if ischar( dB2_{ix(1), l} )
            if strcmp( dB2_{ix(1), l}, dB2_{ix(2), l} )
                dB_{k, l} = dB2_{ix(1), l};
            elseif strcmp( ref, 'mat' )
                disp( ['Replacing ' varNames{l} ': ' dB2_{ix(2), l} ' by ' dB2_{ix(1), l}] )
                dB_{k, l} = dB2_{ix(1), l};
            else
                disp( ['Replacing ' varNames{l} ': ' dB2_{ix(1), l} ' by ' dB2_{ix(2), l}] )
                dB_{k, l} = dB2_{ix(2), l};
            end
        else
            if dB2_{ix(1), l} == dB2_{ix(2), l}
                dB_{k, l} = dB2_{ix(1), l};
            elseif strcmp( ref, 'mat' )
                disp( ['Replacing ' varNames{l} ': ' num2str( dB2_{ix(2), l} ) ' by ' num2str( dB2_{ix(1), l} )] )
                dB_{k, l} = dB2_{ix(1), l};
            else
                disp( ['Replacing ' varNames{l} ': ' num2str( dB2_{ix(1), l} ) ' by ' num2str( dB2_{ix(2), l} )] )
                dB_{k, l} = dB2_{ix(2), l};
            end
        end
    end
end

dB_ = cell2table( dB_, 'VariableNames', varNames );
dB_(:, 'linkedFiles') = linkedFiles;
dB_ = table2struct( dB_ );

%% Make backup of old data bases and save new ones
disp( 'Backing up old databases and saving merged version...' )

currDate = datestr( date, 26 );
currDate = strrep( currDate, '/', '' );

system( ['copy ' fPath 'database.mat "' fPath 'Database Backups\database.mat"'] )
system( ['copy ' fPath 'database.xlsx "' fPath 'Database Backups\database.xlsx"'] )

zip( [fPath 'Database Backups\database_backup_' currDate '.zip'], ...
    {[fPath 'Database Backups\database.mat'], [fPath 'Database Backups\database.xlsx']} )

system( ['del "' fPath 'Database Backups\database.mat"'] )
system( ['del "' fPath 'Database Backups\database.xlsx"'] )

disp( 'Done!' )

end