function channel = getChannel(data, dataLabels, subjectLabel, ind)
% getChannel separates an individual channel from the merged data channel
%
% Returns: 
%   channel - the individual channel
% Arguments:
%   data - data channel where everything is merged together
%   dataLabels - a cell of strings that corresponds each column from data
%   to a label ('RightHand', 'Suit', etc)
%   subjectLabel - a string indicating the subject of the channel 
%   ('RightHand', 'Suit' etc)
%   ind - specifies which row subjectLabel belongs in dataLabels

channel = data(:, strcmp(dataLabels(ind, :), subjectLabel));

end