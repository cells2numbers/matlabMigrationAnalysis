function[turningLeft, turningRight,idLeft,idRight] = performSectorAnalysis(tLng,pm,pathList,PLOT)
%
%
%
%
%
%
% tb 11.2016 

%%

if ~exist('PLOT','var')
    PLOT = 0;
end

trajectories = cell(size(pathList));

for i=1:length(pathList)
    iPath = pathList(i);
    iCentroids = getPathCentroids(tLng,pm,iPath);
    % center all trajectories in [0 0] 
    iCentroids = iCentroids - repmat(iCentroids(1,:),size(iCentroids,1),1);
    trajectories{i} = iCentroids;
end

a = zeros(size(trajectories));
for i=1:length(trajectories)
   a(i) = atan2(trajectories{i}(end,1),trajectories{i}(end,2));
end


turningLeft  = [find(a> 3*pi/4), find(a<-3*pi/4)];
turningRight = intersect( find(a < pi/4), find( a > -pi/4));

turningUpDown = setdiff(1:length(a), intersect(turningLeft,turningRight));





if PLOT
    %%
    h = figure();
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

turningLeft = pathList(turningLeft);
turningRight = pathList(turningRight);
