function out = equivJoints(X)
% out = equivJoints(X)
% Given a Nx22 dimensional input matrix X corresponding to a recording with
% a CyberGlove 3, equivJoints(X) returns the 18 columns corresponding to
% the CyberGlove 1 sensors.
% 
% Inputs:
% <X>       Nx22 matrix of data collected with a CyberGlove 3.
%
% Outputs:
% <out>     Nx18 matrix of data with the equivalent joints to those
%           collected with a CyberGlove 1.
%
% Written by Andreas Thomik, March 2013

if size(X,2) ~= 22
    error('The input data dimensionality does not have 22 dimensions')
end

out = X(:, [1:6 8 9 11:13 15:17 19:22]);

end