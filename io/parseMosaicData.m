function [ trajectories ] = parseMosaicData(fileName)


%%
minLength = 10;

PLOT = 1;
if ~exist('filename','var')
    [fileName, pathname] = uigetfile( ...
       {'*.txt'},'Pick a MOSAIC txt file');
   fileName = [pathname filesep fileName];
end

mosaicData = importdata(fileName);
mosaicTrackingData = mosaicData.data(:,2:5);

nTrajectory = max(mosaicTrackingData(:,1));
trajectories = {};

for iTrajectory = 1:nTrajectory
    id = find( mosaicTrackingData(:,1) == iTrajectory);
    if length(id>minLength)
        trajectories{end+1} = ...
            [mosaicTrackingData(id, 4) - mosaicTrackingData(id(1), 4),...
             mosaicTrackingData(id, 3) - mosaicTrackingData(id(1), 3) ];
    end  
end

a = zeros(size(trajectories));

for i=1:length(trajectories)
   a(i) = atan2(trajectories{i}(end,1),trajectories{i}(end,2));
end


turningLeft  = [find(a> 3*pi/4), find(a<-3*pi/4)];
turningRight = intersect( find(a < pi/4), find(a>-pi/4));

turningUpDown = setdiff(1:length(a), intersect(turningLeft,turningRight));

if PLOT
    %%
    h = figure();
    hold on;
   for i=1:length(turningUpDown)
       iPath = turningUpDown(i);
       plot(trajectories{iPath}(:,2),trajectories{iPath}(:,1),'k');
   end
    for i=1:length(turningLeft)
       iPath = turningLeft(i);
       plot(trajectories{iPath}(:,2),trajectories{iPath}(:,1),'g');
    end
    for i=1:length(turningRight)
       iPath = turningRight(i);
       plot(trajectories{iPath}(:,2),trajectories{iPath}(:,1),'r');
    end
   hold off;
   axis equal;
   
end
