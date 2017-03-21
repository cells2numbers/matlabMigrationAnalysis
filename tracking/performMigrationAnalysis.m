function[] = performMigrationAnalysis(expPath,PLOTMORE)
% 
%
%
% 05.2015 Tim Becker 

if ~exist('PLOTMORE','var')
    PLOTMORE = 0;
end

%% load stored tracking results 
load([expPath filesep 'results' filesep 'image_tLng.mat']);

% extract valid paths 
validPaths = getValidPath(pm,'length',20);
trajectories = cell(size(validPaths));

for i=1:length(validPaths)
    iPath = validPaths(i);
    iCentroids = getPathCentroids(tLng,pm,iPath);
    % center all trajectories in [0 0] 
    iCentroids = iCentroids - repmat(iCentroids(1,:),size(iCentroids,1),1);
    trajectories{i} = iCentroids;
end
% plot trajectories 
figure();hold on;
for i=1:length(validPaths)
   % all trajectories moving to the 'left' are plotted in red,
   % all trajectories moving to the 'right' are plotted in black
   if trajectories{i}(end,2) > 0
       plot(trajectories{i}(:,2),trajectories{i}(:,1),'k');
   else
       plot(trajectories{i}(:,2),trajectories{i}(:,1),'r');
   end
    %drawnow
end
grid on;
axis equal
title('Trajektorien');    

% aangle distribution of the direction of movement 
trajectoryAngle = zeros(size(validPaths));
for i=1:length(validPaths)
   trajectoryAngle(i) = atan2(trajectories{i}(end,1),trajectories{i}(end,2));
end
figure();
rose(trajectoryAngle,18)
title('distribution of trajectories direction')

%    calculate X_FMI and Y_FMI
X_FMI = zeros(size(validPaths));
Y_FMI = zeros(size(validPaths));
D = zeros(size(validPaths));
M = zeros(size(validPaths,2),2);
velocity = zeros(size(validPaths));

for i=1:length(validPaths)

    iPath = validPaths(i);
    centroids = getPathCentroids(tLng,pm,iPath);
    centroids = centroids - repmat(centroids(1,:),size(centroids,1),1);
    
    dist = centroids(2:end,:) - centroids(1:(end-1),:);
    dist_accum = sum(sqrt(sum(dist.^2,2)));
    velocity(i) = dist_accum / length(dist);
    
    dist_euc = norm(centroids(end,:));
    M(i,:) = centroids(end,:);
    X_FMI(i) =  centroids(end,2)/dist_accum;
    Y_FMI(i) =  centroids(end,1)/dist_accum;
    D(i) = dist_euc / dist_accum;
end

FMI(1) = sum(X_FMI) / length(validPaths);
FMI(2) = sum(Y_FMI) / length(validPaths);

M = mean(M) /length(validPaths);

pathLength = [pm{validPaths,2}]- [pm{validPaths,1}] +1;

saveName = [expPath filesep 'results' filesep 'migrationDataValidPaths.mat'];

% 
[fractionValidObservationTime, validObservationTime, totalObservationTime] = getValidObservationTime(pm);
[turningLeft, turningRight] = performSectorAnalysis(tLng,pm,validPaths,1);

velocityLeft = zeros(size(turningLeft));
DLeft = zeros(size(turningLeft));
for i = 1:length(turningLeft)
    velocityLeft(i) = velocity( find(validPaths == turningLeft(i)));
    DLeft(i) = D( find(validPaths == turningLeft(i)));
end

velocityRight = zeros(size(turningRight));
DRight = zeros(size(turningRight));
for i = 1:length(turningRight)
    velocityRight(i) = velocity( find(validPaths == turningRight(i)));
    DRight(i) = D( find(validPaths == turningRight(i)));
end

turningNeutral = setdiff(validPaths,[turningLeft,turningRight]);

velocityNeutral = zeros(size(turningNeutral));
%D = zeros(size(turningNeutral));
if ~isempty(turningNeutral)
    for i = 1:length(turningNeutral)
        velocityNeutral(i) = velocity(find(validPaths == turningNeutral(i)));
        %    D(i) = D(find(validPaths == turningNeutral(i)));
    end
end

percentageLeft = length(turningLeft) / length(validPaths); 
percentageRight = length(turningRight) / length(validPaths);

[distLeft, distALeft] = getDistanceTravelled(tLng,pm,turningLeft);
[distRight, distARight] = getDistanceTravelled(tLng,pm,turningRight);

% save as mat file 
save(saveName,'validPaths','velocity','X_FMI','Y_FMI','FMI','D','M','trajectoryAngle',...
    'pathLength','fractionValidObservationTime','percentageLeft','percentageRight',...
    'distLeft','distALeft','distRight','distARight','velocityLeft','velocityRight',...
    'turningLeft','turningRight','turningNeutral','velocityNeutral','DLeft','DRight');


% save all parameters for each trajectory as csv 
saveNameCSV1 = [expPath filesep 'results' filesep 'migrationDataValidPaths.csv'];
migrationDataMatrix = [pathLength',velocity',X_FMI',Y_FMI',D',trajectoryAngle'];
csvHeader1 = {'pathlength','velocity','x-fmi','y-fmi','directionality','angle'};
csvwrite_with_headers(saveNameCSV1,migrationDataMatrix,csvHeader1);

% save all parameters describing the complete experiment as separate csv
saveNameCSV2 = [expPath filesep 'results' filesep 'migrationDataExperiment.csv'];
migrationDataExperiment = [percentageLeft, percentageRight, fractionValidObservationTime];
csvHeader2 = {'percentageLeft','percentageRight','fractionValidObservationTime'};
csvwrite_with_headers(saveNameCSV2,migrationDataExperiment,csvHeader2);

if PLOTMORE
    
    %%
    figure();
    plot(X_FMI,Y_FMI,'x');
    xlabel('X-FMI');
    ylabel('Y-FMI');
    axis square;
    
    figure();
    plot(X_FMI,velocity,'x');
    xlabel('X-FMI');
    ylabel('velocity');
    axis square;
    
    figure();
    plot(Y_FMI,velocity,'x');
    xlabel('Y-FMI');
    ylabel('velocity');
    axis square;
    
    figure();
    boxplot(migrationDataMatrix(:,2))
    title('velocity');
    
    figure();
    boxplot(migrationDataMatrix(:,3))
    title('X-FMI');
    
    figure();
    boxplot(migrationDataMatrix(:,4))
    title('Y-FMI');
    
    figure();
    boxplot(migrationDataMatrix(:,5))
    title('directionality');

    
    
end
