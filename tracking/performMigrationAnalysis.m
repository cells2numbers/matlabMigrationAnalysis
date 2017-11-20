function[] = performMigrationAnalysis(expPath,PLOTMORE,minPathLength)
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
validPaths = getValidPath(pm,'length',minPathLength);
trajectories = cell(size(validPaths));

for i=1:length(validPaths)
    iPath = validPaths(i);
    iCentroids = getPathCentroids(tLng,pm,iPath);
    % center all trajectories in [0 0] 
    iCentroids = iCentroids - repmat(iCentroids(1,:),size(iCentroids,1),1);
    trajectories{i} = iCentroids;
end

% plot trajectories
if PLOTMORE
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
end

% aangle distribution of the direction of movement 
trajectoryAngle = zeros(size(validPaths));
for i=1:length(validPaths)
   trajectoryAngle(i) = atan2(trajectories{i}(end,1),trajectories{i}(end,2));
end

if PLOTMORE
    figure();
    rose(trajectoryAngle,18)
    title('distribution of trajectories direction')
end
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
    dist_accum_vector(i) = dist_accum;
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
[turningLeft, turningRight] = performSectorAnalysis(tLng,pm,validPaths,0);

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

sector_positive = (trajectoryAngle > (3*pi/4)) + (trajectoryAngle < (-3*pi/4));
sector_negative = (trajectoryAngle < pi/4) & (trajectoryAngle > -pi/4);
sector_analysis = sector_positive + 2*sector_negative;

% pixel size = 0.7819
% frames per minute = 2
% factor speed = 

pixel_size = 0.7819;
frames_per_second = 1/30;
% frames are recorded each 30 seconds, i.e. 
factor_speed = pixel_size * frames_per_second;
factor_time = 1/frames_per_second;

% save all parameters for each trajectory as csv 
saveNameCSV1 = [expPath filesep 'results' filesep ' Migration_Parameters_Valid_Paths.csv'];
saveNameXLS1 = [expPath filesep 'results' filesep ' Migration_Parameters_Valid_Paths.xls'];

migrationDataMatrix = [dist_accum_vector' * pixel_size, ...
                       pathLength' * factor_time,...
                       velocity' * factor_speed,...
                       X_FMI',...
                       Y_FMI',...
                       D',...
                       trajectoryAngle',...
                       sector_analysis'
                       ];
                   
header = {'distance_traveled_in_micrometer_m',...
              'lifetime_in_seconds',...
              'velocity_micrometer_seconds',...
              'x_fmi',...
              'y_fmi',...
              'directionality',...
              'angle',...
              'sector_0neutral_1positive_2negative'
              };
          
csvwrite_with_headers(saveNameCSV1,migrationDataMatrix,header);
a = array2table(migrationDataMatrix,'VariableNames',header);

% get version info
v = ver('MATLAB');
matlab_version = str2double(v.Version);

if matlab_version >= 9
    writetable(a, saveNameXLS1);
end
%%
% loop over different sectors, 
%   0 = neutral, 
%   1 = positive, 
%   2 = negative


data = cell(1,5);
test_file = [expPath filesep 'results' filesep 'Migration_Parameters_Valid_Paths_analyzed.xlsx'];
for value_i = 1:5
    mean_values = zeros(4,5);
    
    all_values = migrationDataMatrix(:,value_i);
    mean_values(4, 1) = median(all_values);
    mean_values(4, 2) = mean(all_values);
    mean_values(4, 3) = std(all_values) / sqrt(length(all_values));
    mean_values(4, 4) = std(all_values);
    mean_values(4, 5) = length(all_values);
    for index_i =0:2
        index = find(migrationDataMatrix(:,end) == index_i);
        values = migrationDataMatrix(index,value_i);
        mean_values(index_i + 1,1) = median(values);
        mean_values(index_i + 1,2) = mean(values);
        mean_values(index_i + 1,3) = std(values) / sqrt(length(values));
        mean_values(index_i + 1,4) = std(values);
        mean_values(index_i + 1,5) = length(values);
    end
    
    Sector = {'neutral','positive','negative','all'};
    MEDIAN = mean_values(:,1);
    MEAN = mean_values(:,2);
    SEM = mean_values(:,3);
    SD = mean_values(:,4);
    N = mean_values(:,5);
    N_Fraction = N ./ mean_values(4, 5);
    T = table(Sector', MEAN, MEDIAN, SEM, SD, N, N_Fraction);
    if matlab_version >= 9
        writetable(T,test_file, 'sheet',value_i, 'Range','A5');
    end
    Feature = header(value_i);
    T_with_name = table(Feature);
    if matlab_version >= 9
        writetable(T_with_name,test_file, 'sheet',value_i, 'Range', 'A1');
    end
end
%%


% save all parameters describing the complete experiment as separate csv
saveNameCSV2 = [expPath filesep 'results' filesep 'Migration_Metadata.csv'];
saveNameXLS2 = [expPath filesep 'results' filesep 'Migration_Metadata.xls'];
%migrationDataExperiment = [percentageLeft, percentageRight, fractionValidObservationTime];

migrationDataExperiment2 = [tLng.time_max,...
                            fractionValidObservationTime,...
                            size(pm,1),...
                            length(validPaths),...
                            length(validPaths) / size(pm,1),...
                            length(turningLeft),...
                            length(turningRight),...
                            length(turningNeutral),...
                            ];
                            

%csvHeader2 = {'percentageLeft','percentageRight','fractionValidObservationTime'};
csvHeader2 = {'frames_analyzed',...
              'VOT',...
              'tracks',...
              'valid_tracks',...
              'valid_track_fraction',...
              'tracks_positive_sector',...
              'tracks_negative_sector',...
              'tracks_in_neutral_sector'};
csvwrite_with_headers(saveNameCSV2,migrationDataExperiment2,csvHeader2);
%csvwrite_with_headers(saveNameCSV1,migrationDataMatrix,header);
b = array2table(migrationDataExperiment2,'VariableNames',csvHeader2);

if matlab_version >= 9
    writetable(b, saveNameXLS2);
end

if 0
    
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
