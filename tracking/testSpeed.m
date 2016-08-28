function speed = getCellSpeed(tLng,pm,pathnr,timeWindow)
% function to calculate the cell speed in a given time window
%
%  speed = getCellSpeed(tLng,pm,pathnr,timewindow)
%
%
%
%  input: 
%         tLng
%         pm 
%         pathnr 
%         timeWindow    size of the window. the cell speed is calculated
%                       as MSD over timeWindow frames. 
%
%  output:
%     speed        vector with size 1XN, where N is the length of the 
%                  path. the first values of the cellspeed are filles 
%                  up using  the first calculated speed, same with the
%                  missing speed values at the end
%
%          
%   Example: each x stands for a cell in a frame, s1,..,s10 are the 
%            different speed values for each time window. with N = 12 and 
%            timeWindow = 3 10 values can be calculated. therefore, the 
%            begin and end is extended. 
%            
%     
%     x  x   x   x   x   x   x   x   x   x   x   x 
%     -  s1  s2  s3  s4  s5  s6  s7  s8  s9  s10 - 
%     s1 s1  s2  s3  s4  s5  s6  s7  s8  s9  s10 s10 
%
%
%  03.2012 tb

% init output var
speed = [];

% set number of timesteps used to calculate the cell speed
if ~exist('timeWindow','var')
    timeWindow = 5;
end

% get centroid position for each cell(mask) in the path
centroids = getPathCentroids(tLng,pm,pathnr);

% calculate difference and MSD 
centroidsDiff = centroids(2:end,:) - centroids(1:end-1,:);

% the cellpath needs to be longer than the window-size
if  size(centroidsDiff,1) < timeWindow
    return
end

% distance each cell travelled in each frame as mean squared distance (MSD)
MSD = sqrt(sum(centroidsDiff.^2,2));


for iFrame = 1: (size(centroidsDiff,1) - timeWindow +1)
    idx = iFrame : (iFrame + timeWindow -1);
    speed(iFrame) = sum(MSD(idx)) ./ timeWindow;
end

% we fill up the missing frames at the beginning and at 
% the end of the cell path

nBegin = ceil(timeWindow/2);
nEnd = floor(timeWindow/2);

speed = [repmat(speed(1),1,nBegin), speed, repmat(speed(end),1,nEnd)];