function resampledData = quickCheck( dataPath )
% function quickCheck( dataPath )
% Aligns, resamples and plots all the data available in a current folder
% and displays it for quick checking.
%
% Inputs:
% <dataPath>    Character array indicating the path to the folder with the
%               data. Can be a top-level folder.
%               If a top-level folder is specified, the data needs to be in
%               folders whose name starts with 'Data_Recording_Date_'.
% 
% Written by Andreas Thomik, August 2013.
home

if nargin == 0 || isempty( dataPath )
    dataPath = cd;
end

if exist( [ dataPath '\SuitTime.txt' ], 'file' ) || ...
        exist( [ dataPath '\SuitData.txt' ], 'file' ) || ...
        exist( [ dataPath '\RightHandData.txt' ], 'file' ) || ...
        exist( [ dataPath '\LeftHandData.txt' ], 'file' )
    addpath( dataPath );
else
    % We are (hopefully) in the top-level directory
    tmp = dir( [dataPath '\Data_Recording_Date_*'] );
    
    % If there is nothing, return an error.
    if isempty( tmp )
        error( 'Could not find any folder with the specified name' );
    end
    
    id = 0;
    allDataFolders = cell( length( tmp ), 2 );
    for k = 1:length( allDataFolders )
        allDataFolders{k, 1} = k;
        allDataFolders{k, 2} = tmp(k).name;
    end
    disp( 'Please enter the number of the data set you would like to analyse' )
    disp( ' ' )
    disp( allDataFolders )
    disp( ' ' )
    while ~id || id > length( allDataFolders )
        id = input( 'Folder number: ' );
    end
    dataPath = [ dataPath '\' allDataFolders{id, 2} ];
    addpath( dataPath );
end

% Try parsing the data
try     % Left hand data
    [lhData, lhTime] = parseEthomics( [ dataPath '\LeftHandData.txt' ], ...
        'leftHand', true );
catch
    lhData = [];
    lhTime = [];
end

try     % Right hand data
    [rhData, rhTime] = parseEthomics( [ dataPath '\RightHandData.txt' ], ...
        'rightHand', true );
catch
    rhData = [];
    rhTime = [];
end

try     % Suit data
    [suitData, ~] = parseEthomics( [ dataPath '\SuitData.bvh' ], 'suitData' );
    load( 'D:\Matlab Toolboxes\Ethomics\StandardSkeleton.mat' );
    suitData  = getRelativeJointMotion( suitData, skel );
    [~, suitTime] = parseEthomics( [ dataPath '\SuitTime.txt' ], 'suitTime' );
catch
    suitData = [];
    suitTime = [];
end

try     % Eye-tracker data
    [eyeData, eyeTime] = parseEthomics( [ dataPath '\GazeData.txt' ], 'eyeTracker' );
catch
    eyeData = [];
    eyeTime = [];
end

if ~isempty( suitTime ) && size( suitTime, 1 ) ~= size( suitData.angles, 1 )
    dT = size( suitTime, 1 ) - size( suitData.angles, 1 );
    if dT > 0
        disp( ['Looks like we have ' num2str( dT ) ' more time stamps than data for the suit...'] )
        disp( 'Typically there are a few duplicates at the beginning, mind checking?' )
        disp( ' ' )
        disp( [ linspace( 1, ceil( 1.33*dT ), ceil( 1.33*dT ) )', suitTime(1:ceil( 1.33*dT ), :) ] );
        disp( ' ' )
        disp( [ 'I suggest to start the time stamps at point ' num2str( dT+1 ) ' or finish early.'] )
        disp( 'To start later, type S. To end early, type E. Any other key to abort.'  )
        s = input('Do you wish to proceed? ', 's' );
        
        if any( strcmp( s, {'S', 's',} ) )
            suitTime = suitTime(dT+1:end, :);
        elseif any( strcmp( s, {'E', 'e',} ) )
            suitTime = suitTime(end-dT:end, :);
        else
            disp( 'Sorry!' )
            suitTime = [];
            suitData = [];
        end
    else
        disp( 'There are more data points than time stamps. I cannot help with this, sorry.' )
        disp( 'Ignoring suit data...' )
    end
end

[suitTime, lhTime, rhTime, eyeTime] = getMilliSecondTime( suitTime, lhTime, rhTime, eyeTime );
resampledData = resampleEthomicsData( suitTime, suitData.angles, ...
    lhTime, lhData, rhTime, rhData, eyeTime, eyeData, ...
    suitTime, suitData.reducedAngles );

xmin = 0;
xmax = 0;

for k = 1:5
    try
        if resampledData{k, 1}(end) > xmax
            xmax = resampledData{k, 1}(end);
        end
    catch
        continue
    end
end


figure
subplot( 4, 1, 1 )
plot( resampledData{1, 1}, resampledData{1, 2} )
title( 'Suit Data' )
xlabel( 'Time [ms]' )
ylabel( 'Amplitude [a.u.]' )
xlim( [xmin xmax] )
subplot( 4, 1, 2 )
plot( resampledData{2, 1}, resampledData{2, 2} )
title( 'Left Hand Data' )
xlabel( 'Time [ms]' )
ylabel( 'Amplitude [a.u.]' )
xlim( [xmin xmax] )
subplot( 4, 1, 3 )
plot( resampledData{3, 1}, resampledData{3, 2} )
title( 'Right Hand Data' )
xlabel( 'Time [ms]' )
ylabel( 'Amplitude [a.u.]' )
xlim( [xmin xmax] )
if ~isempty( resampledData{4, 2} )
    subplot( 4, 1, 4 )
    plot( resampledData{4, 1}, resampledData{4, 2}(:, 4:9) )
    title( 'Eye Tracker Data' )
    xlabel( 'Time [ms]' )
    ylabel( 'Amplitude [a.u.]' )
    xlim( [xmin xmax] )
end


% Clear up the added path
rmpath( dataPath );
end