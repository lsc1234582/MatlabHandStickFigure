function runningTime = getRunningTime(data)
% getRunningTime(data)
%
% Gets the non-nan length of a time-series data matrix
%
% Returns:
%   runningTime - the non-nan length of DATA
% Arguments:
%   data - time seriese data matrix (data channel) where the time progresses 
%       along the first dim (rows)  

[runI, runJ] = ind2sub(size(data), find(isnan(data)));
runI = unique(runI);
runningTime = size(data, 1) - size(runI, 1); 

end