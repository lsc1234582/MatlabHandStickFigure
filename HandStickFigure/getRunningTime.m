function runningTime = getRunningTime(data)
% getRunningTime gets the non-nan length of a time-series data matrix
%
% Returns:
%   RUNNINGTIME - the non-nan length of DATA
% Arguments:
%   DATA - time seriese data matrix where the time progresses along the
%	first dim (rows)  

[runI, runJ] = ind2sub(size(data), find(isnan(data)));
runI = unique(runI);
runningTime = size(data, 1) - size(runI, 1); 

end