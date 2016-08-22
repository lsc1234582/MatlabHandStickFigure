function [sL, tL, aL, map] = parseAnnotationXLS( file )

% TODO: add representation of "general actions"

% removed below as excel seems to hang
% [~, ~, sL] = xlsread( file, 'scenarioList' );
% [~, ~, tL] = xlsread( file, 'taskList' );
% [~, ~, aL] = xlsread( file, 'actionList' );
% [~, ~, map] = xlsread( file, 'Overview', 'T3:U78' );



[pathstr,name,ext] =fileparts(file);
load([pathstr '\AnnotationListExcelReplacement.mat']);

% scenarioTable = aL( strcmp( 'Scenario', aL(:, 1) ), 2:end );
% taskTable = aL( strcmp( 'Task', aL(:, 1) ), 2:end );
% actionTable = aL( strcmp( 'Action', aL(:, 1) ), 2:end );
% actionTable(strcmp( 'ActiveX VT_ERROR: ', actionTable )) = {NaN};
% actionTable = cell2mat( actionTable );
% 
% tL = [scenarioTable(:), tL];
% 
% tmpAL = {};
% for k = 1:size( tL, 1 )
%     nEl = sum( isfinite( actionTable(:, k) ) );
%     tmp = cell( nEl, 4 );
%     tmp(:, 1) = { scenarioTable{k} };
%     tmp(:, 2) = { taskTable{k} };
%     tmp(:, 3) = num2cell( actionTable(isfinite( actionTable(:, k) ), k));
%     for l = 1:nEl
%         tmp{l, 4} = map{cell2mat( map(:, 2) ) == tmp{l, 3}, 1};
%     end
%     tmpAL = [tmpAL; tmp];
% end

% aL = tmpAL;
end