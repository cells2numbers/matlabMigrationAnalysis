function [] = performBatchMigrationAnalysis(expPath,OVERWRITE)
%
%
%
%
% 


if ~exist('OVERWRITE','var')
    OVERWRITE = 1; 
end

filename = 'expInfo.mat';
[fileList,pathList] = searchFileRec(expPath,filename);

nFiles = size(fileList,2);

radius = 45;
frameRadius = 3;
SAVE = 1;
detection_method = 2;

for i=1:nFiles
    % check if detection file is written
    exp.detectionParaStored(i) = exist([pathList{i} filesep 'images' filesep 'image_parameters.mat'],'file');
    exp.tracked(i) =  exist([pathList{i} filesep 'results' filesep 'image_tLng.mat'],'file');
    exp.analyzed(i) =  exist([pathList{i} filesep 'results' filesep 'migrationDataValidPaths.mat'],'file');
end

fprintf('found %i extracted experiments (image series) \n ',nFiles);
fprintf(' parameter stored: %i \n ',length(find(exp.detectionParaStored)));  
fprintf(' already tracked:  %i \n ',length(find(exp.tracked)));
fprintf(' already analyzed: %i \n',length(find(exp.analyzed)));

%%

if OVERWRITE 
    index2analyze = find(exp.tracked);
else 
    index2analyze = setdiff(find(exp.tracked), find(exp.analyzed));
end


parfor i=1:length(index2analyze)
    fprintf('---------------------------------------------------\n');
    fprintf('analyzing image series %i of the last missing %i \n',i,length(index2analyze));
    iExp = index2analyze(i);
    performMigrationAnalysis(pathList{iExp});
    fprintf('finished image series %i of the last missing %i \n',i,length(index2analyze));
    fprintf('---------------------------------------------------\n\n');
end

% update index of analyzed files 
for i=1:nFiles
    exp.detectionParaStored(i) = exist([pathList{i} filesep 'images' filesep 'image_parameters.mat'],'file');
    exp.tracked(i) =  exist([pathList{i} filesep 'results' filesep 'image_tLng.mat'],'file');
    exp.analyzed(i) =  exist([pathList{i} filesep 'results' filesep 'migrationDataValidPaths.mat'],'file');
end

if 1
    nPaths = [];
    %%
    indexAnalyzed = find(exp.analyzed);
    fprintf('\n');
    fprintf('-----------------------------------------------------------\n');
    fprintf('paths \t valid \t ratio \t X-FMI \t Y-FMI \t velo \t D \t VOT \t left \t right \t filename \n');
    fprintf('-----------------------------------------------------------\n');
    for i=1:length(indexAnalyzed)
        iExp = indexAnalyzed(i);
        trackingDataFile = [pathList{iExp} filesep 'results' filesep 'image_tLng.mat'];
        migrationDataFile = [pathList{iExp} filesep 'results' filesep 'migrationDataValidPaths.mat'];
        load(trackingDataFile);
        load(migrationDataFile);
        nPaths(i) = size(pm,1);
        nValidPaths(i) = length(validPaths);
        xfmi(i) = FMI(1);
        yfmi(i) = FMI(2);
        meanVelocity(i) = mean(velocity);
        d(i) = sum(D)/length(D);
        turnLeft(i) = percentageLeft;
        turnRight(i) = percentageRight;
        validObservationTime(i) = fractionValidObservationTime;
        
        fprintf('%i \t  %i \t %1.2f \t %1.2f \t %1.2f \t %1.2f \t %1.2f \t %3.2f \t %3.2f \t %3.2f \t %s \n',...
            nPaths(i),nValidPaths(i),nValidPaths(i)/nPaths(i),xfmi(i),yfmi(i),meanVelocity(i),d(i), validObservationTime(i),turnLeft(i), turnRight(i), fileList{i});
    end
end
    
 migrationData = [nPaths',nValidPaths',nValidPaths'./nPaths',xfmi',yfmi',...
                  meanVelocity',d',validObservationTime',turnLeft',turnRight'];
              
 csvHeader = {'number of paths', 'valid paths', 'perc. of valid paths',...
              'xfmi','yfmi','mean velocity','directionality',...
              'valid observation time','perc. turning left',...
              'perc. turning right','experiment'};
 
 save([expPath filesep 'migrationData.mat'],'migrationData','fileList','pathList','csvHeader');
 %csvwrite_with_headers([expPath filesep 'migrationData.csv'],migrationData,csvHeader );

 % export to csv
 fid = fopen([expPath filesep 'migrationData.csv'],'w');
 for i=1:length(csvHeader)
     fprintf(fid,'%s,',csvHeader{i});
 end
 fprintf(fid,'\n');
 for i=1:size(migrationData,1)
     [~,iPath] =  fileparts(pathList{i});
     fprintf(fid,'%i, %i, %2.4f, %f2.4, %f2.4, %f2.4, %2.4f, %2.4f, %2.4f, %2.4f,  %s \n',migrationData(i,:),iPath);
 end

