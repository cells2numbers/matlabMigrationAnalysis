function [fraction, validObservationTime, totalObservationTime] = getValidObservationTime(pm)
% calcuate the cummulative fraction of valid observation time
%
% Function to calculate the cummulative total obvservation time of all
% trajectories and the valid fraction of the total observation time.
%
% Input
%
%  pm           path matrix
%
% Output
%
%   fraction                fraction of valid paths of the cummulative
%                           total observation time
%   validObservationTime    cummulative temporal length of all valid paths
%                           in frames
%   totalObservationTime    cummulative temporal length of all paths
%
% TB 11.2016

pathLength = [pm{:,2}] - [pm{:,1}] +1;
totalObservationTime = sum(pathLength);

validPaths = getValidPath(pm);
validObservationTime = sum(pathLength(validPaths));

fraction = 100*validObservationTime / totalObservationTime;
end

