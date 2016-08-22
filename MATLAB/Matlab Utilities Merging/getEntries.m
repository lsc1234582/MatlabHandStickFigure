function [out, ix] = getEntries( dB_, key, varargin )
% function [out, ix] = getEntries( dB_, key, cond1, cond2, ... )
% Returns the values for a field specified by 'key' in the database 'dB_'.
% Inputs:
% <dB_>     Database from which the field needs to be extracted. It is
%           expected that this database takes the form of a struct array.
%
% <key>     Name of the field to be extracted from the database. If key ==
%           [], the entire entry is returned.
%
% Parameters: (insert as parameter name/value pairs (e.g.: 'acc', 0.9))
% <condN>   Function handle to a condition to test on a database entry. 
%           Needs to return either true or false.
%
% Outputs:
% <out>     Cell array containing the value for the relevant fields
%
% <ix>      Logical array indicating whether the line in the database was
%           used (1) or not (0).
%
% Written by Andreas Thomik, July 2014

dB_ = dB_(:);
ix = true( size( dB_, 1 ), 1 );
if ~isempty( key )
    out = arrayfun( @(x) x.(key), dB_, 'UniformOutput', false );
else
    out = dB_;
end

if isempty( varargin ) && isempty( key )
    ix = cellfun( @(x) ~isempty( x ), out );
    out = out(ix);
    return
end

for k = 1:length( varargin )
    tmpIX = arrayfun( varargin{k}, dB_ );
    ix = ix & tmpIX;
end

out = out(ix);

end