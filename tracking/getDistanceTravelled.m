function[dist, distAccum] = getDistanceTravelled(tLng,pm,pathList)
% function to calculate the distance travelled 
%
% TB

%%
trajectories = cell(size(pathList));

dist = zeros(size(trajectories));

distAccum = zeros(size(trajectories));
for i=1:length(pathList)
    iPath = pathList(i);
    iCentroids = getPathCentroids(tLng,pm,iPath);
    % center all trajectories in [0 0] 
    iCentroids = iCentroids - repmat(iCentroids(1,:),size(iCentroids,1),1);
    trajectories{i} = iCentroids;
    
    dist(i) = norm(trajectories{i}(end,:)) / length(trajectories{i});
    
    d = trajectories{i}(2:end,:) - trajectories{i}(1:(end-1),:);
    distAccum(i) = sum( sqrt( d(:,1).^2 + d(:,2).^2 ));
end