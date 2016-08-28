function [ h1,h2 ] = showTrajectoryAndAngle( tLngFile,validPaths )
% UNTITLED Summary of this function goes here
%   Detailed explanation goes here

load(tLngFile);
%% extract valid paths
trajectories = cell(size(validPaths));

for i=1:length(validPaths)
    iPath = validPaths(i);
    iCentroids = getPathCentroids(tLng,pm,iPath);
    % center all trajectories in [0 0]
    iCentroids = iCentroids - repmat(iCentroids(1,:),size(iCentroids,1),1);
    trajectories{i} = iCentroids;
end
% plot trajectories
h1 = figure();

hold on;
for i=1:length(validPaths)
    % all trajectories moving to the 'left' are plotted in red,
    % all trajectories moving to the 'right' are plotted in black
    if trajectories{i}(end,2) > 0
        plot(trajectories{i}(:,2),trajectories{i}(:,1),'k');
    else
        plot(trajectories{i}(:,2),trajectories{i}(:,1),'r');
    end
    drawnow
end
grid on;
axis equal; 
title('trajectories');

% angle distribution of the direction of movement
a = zeros(size(validPaths));
for i=1:length(validPaths)
    a(i) = atan2(trajectories{i}(end,2),trajectories{i}(end,1));
end
h2 = figure();
rose(a,18)
title('distribution of trajectories direction')
axis square;
end

