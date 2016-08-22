clear
clc
pc=1

% if pc
     addpath(genpath('L:\Data\Matlab Utilities\Merging'))
% else
%     addpath(genpath('/Users/Will/Dropbox/EthomicsWill/Matlab Utilities'))
% end

subject='AW_02';
setting='Kitchen';
info='NothingZeroed';

ethomeFileName=[ subject,'/',setting,'/',info]; % took away .. -> when used in lower dir


reCalculate=true;

if ~reCalculate % Try loading the ethome data
    success=fopen(cat(2,subject,'/',setting,info,'.mat'));
    
    try
        load( ethomeFileName )
    catch
        disp( ['Could not find file ' ethomeFileName ])
        return
    end
    
else % re-extract from raw data
    
    try
        load( 'L:\Data\database.mat' )
    catch
        disp( 'Could not find file L:\Data\database.mat' )
        return
    end
  
    
    currDate = datestr( date, 26 );
    currDate = strrep( currDate, '/', '' );
    
    
    
    
    dbEntry = getEntries( dB_, [], @(x) strcmp( x.SubjectID, subject ), @(x) strcmp( x.SettingID, setting ) );
    
    
    E = Ethome( dbEntry )
    E.LeftHand.setField( 'Data', removeJumps( E.LeftHand.Data ) );

    E.Sync(100,1)
    
    E.Data2XYZ;
    E.makeDataLabels('All');
    
    %save( ethomeFileName, 'E' );
end