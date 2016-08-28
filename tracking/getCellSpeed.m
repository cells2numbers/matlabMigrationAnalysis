function [speed,migration,frames] = getCellSpeed(tLng,pm,pathnr,timeWindow)
% function to calculate the cell speed in a given time window
%
%  [speed,migration,frames] = getCellSpeed(tLng,pm,pathnr,timewindow)
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
%                  path. the first values of the cellspeed are filled 
%                  up with the first calculated speed, same with the
%                  missing speed values at the end
%
%     frames       timepoint for each speed value
%
%     migration    distance travelled
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
migration = [];

%  extract time frames (only needed as output)
frames = pm{pathnr,3}(:,1);

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
    speed = zeros(size(frames));
    migration = zeros(size(frames));
    return
end

% distance each cell travelled in each frame as mean squared distance (MSD)
MSD = sqrt(sum(centroidsDiff.^2,2));


for iFrame = 1: (size(centroidsDiff,1) - timeWindow +1)
    idx = iFrame : (iFrame + timeWindow -1);
    speed(iFrame) = sum(MSD(idx)) ./ timeWindow;
    mig = centroids(idx(1),:) - centroids(idx(end),:);
    migration(iFrame) = norm(mig);
end

% we fill up the missing frames at the beginning and at 
% the end of the cell path 

nBegin = ceil(timeWindow/2);
nEnd = floor(timeWindow/2);

speed = [repmat(speed(1),1,nBegin), speed, repmat(speed(end),1,nEnd)];
migration =  [repmat(migration(1),1,nBegin), migration,...
    repmat(migration(end),1,nEnd)];