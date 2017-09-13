function[] = publishAnalysis(expPath)
% 
%
%
% 05.2015 Tim Becker 

%% load stored tracking results 
load([expPath filesep 'results' filesep 'image_tLng.mat']);

% extract valid paths 
validPaths = getValidPath(pm);
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

% angle distribution of the direction of movement 
a = zeros(size(validPaths));
for i=1:length(validPaths)
   a(i) = atan2(trajectories{i}(end,1),trajectories{i}(end,2));
end



figure();
[T,R] = rose(a,20);
h = polarplot(T,R)
title({'Anzahl Trajektorien'},'FontWeight','bold','FontSize',16,...
   'Color',[0 0 1]);
pax = gca;
ticklabel = {};
for tic=0:11  
    ticklabel{tic+1} = [sprintf('%i%c',tic*30,char(176))];
end

pax.ThetaAxis.TickLabels = ticklabel;

%pax.FontSize = 14;
pax.RColor = [0 0 1];
pax.GridColor = 'black';
pax.LineWidth = 2;
pax.RAxis.Label.Rotation = 0;
pax.RAxisLocation = 80;

%pax.RAxis.Label.String = sprintf('Winkel [%c]', char(176));
pax.RAxis.Label.String = '\color[rgb]{0,0,0} \bf Winkel [\circ]';
pax.TitleFontSizeMultiplier = 1.3;
limits = pax.RAxis.Limits;

pax.RAxis.FontSize = 18;

pax.RAxis.Label.Position = [270  limits(2) * 1.13 0  ];
pax.RAxis.Color

set(h,'color','b','linewidth',1.5)

%hlines = findall(gcf,'Type','line','LineStyle','-');

%for i = 1:length(hlines)
%   set(hlines(i),'LineWidth',2);
%end

%    calculate X_FMI and Y_FMI
X_FMI = zeros(size(validPaths));
Y_FMI = zeros(size(validPaths));
D = zeros(size(validPaths));
M = zeros(size(validPaths,2),2);
for i=1:length(validPaths)
    %
   
    iPath = validPaths(i);
    centroids = getPathCentroids(tLng,pm,iPath);
    centroids = centroids - repmat(centroids(1,:),size(centroids,1),1);
    
    dist = centroids(2:end,:) - centroids(1:(end-1),:);
    dist_accum = sum(sqrt(sum(dist.^2,2)));
    
    dist_euc = norm(centroids(end,:));
    M(i,:) = centroids(end,:);
    X_FMI(i) =  centroids(end,2)/dist_accum;
    Y_FMI(i) =  centroids(end,1)/dist_accum;
    D(i) = dist_euc / dist_accum;
end

FMI(1) = sum(X_FMI) / length(validPaths);
FMI(2) = sum(Y_FMI) / length(validPaths);
fprintf('x-fmi: %3.3f \n',FMI(1));
fprintf('y-fmi: %3.3f \n',FMI(2));
fprintf('velocity (in px/frame): %3.3f \n',dist_accum / length(dist));
fprintf('distance traveled (accumulated distance): %3.3f \n',dist_accum);


[fraction, validObservationTime, totalObservationTime] = getValidObservationTime(pm);
fprintf('totalObservationTime (cummulative) : %5.3f \n',totalObservationTime);
fprintf('validObservationTime (cummulative) : %5.3f \n',validObservationTime);
fprintf('percentage of valid observation time: %2.2f \n',fraction);


[turningLeft, turningRight] = performSectorAnalysis(tLng,pm,validPaths,1);
fprintf('percentage turning left: %1.2f \n', length(turningLeft) / length(validPaths) );

fprintf('percentage turning right: %1.2f \n', length(turningRight) / length(validPaths) );

%M = mean(M) /length(validPaths);
%saveName = [expPath filesep 'results' filesep 'migrationData.mat'];
%save(saveName,'validPaths','X_FMI','Y_FMI','FMI','D','M','a');







