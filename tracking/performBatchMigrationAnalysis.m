function [] = performBatchMigrationAnalysis(expPath,OVERWRITE)
% Batch analysis 
%
% All tracked experiments found in the given folder are analysed 
%
% Input
%   expPath         The experiment path is recursively searched for 
%                   analyzed experiments
%
% Optional Input
%   OVERWRITE       Force overwrite of already analyzed experiments    
% 
%
% 3.2017 tb


if ~exist('OVERWRITE','var')
    OVERWRITE = 1; 
end

minPathLength = 0;

filename = 'expInfo.mat';
[fileList,pathList] = searchFileRec(expPath,filename);

nFiles = size(fileList,2);


for i=1:nFiles
    % check if detection file is written
    exp.detectionParaStored(i) = exist([pathList{i} filesep 'images' filesep 'image_parameters.mat'],'file');
    exp.tracked(i) =  exist([pathList{i} filesep 'results' filesep 'image_tLng.mat'],'file');
    exp.analyzed(i) =  exist([pathList{i} filesep 'results' filesep 'migrationDataValidPaths.mat'],'file');
    exp.exported(i) =  exist([pathList{i} filesep 'results' filesep 'featureList.csv'],'file');    
end

fprintf('found %i extracted experiments (image series) \n ',nFiles);
fprintf(' parameter stored: %i \n ',length(find(exp.detectionParaStored)));  
fprintf(' already tracked:  %i \n ',length(find(exp.tracked)));
fprintf(' already analyzed: %i \n',length(find(exp.analyzed)));
fprintf(' already exported: %i \n ',length(find(exp.exported)));
%%

if OVERWRITE 
    index2analyze = find(exp.tracked);
else 
    index2analyze = setdiff(find(exp.tracked), find(exp.analyzed));
end


parfor i=1:length(index2analyze)
    %fprintf('---------------------------------------------------\n');
    fprintf('analyzing series %i / %i ',i,length(index2analyze));
    iExp = index2analyze(i);
    performMigrationAnalysis(pathList{iExp},1,minPathLength);
    fprintf('  finished!\n');
    %fprintf('---------------------------------------------------\n\n');
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
        
        distanceLeft(i) = mean(distLeft);
        distanceLeftAccu(i) = mean(distALeft); 
        distanceRight(i) = mean(distRight);
        distanceRightAccu(i) = mean(distARight);
        validObservationTime(i) = fractionValidObservationTime;
        meanVelocityLeft(i) = mean(velocityLeft);
        meanVelocityRight(i) = mean(velocityRight);
        meanVelocityNeutral(i) = mean(velocityNeutral);
        meanDLeft(i) = mean(DLeft);
        meanDRight(i) = mean(DRight);
        [p,n,e] = fileparts(fileList{i});
        filesepPosition = strfind(p,filesep);
        
        fprintf('%i \t  %i \t %1.2f \t %1.2f \t %1.2f \t %1.2f \t %1.2f \t %3.2f \t %3.2f \t %3.2f \t %s \n',...
            nPaths(i),nValidPaths(i),nValidPaths(i)/nPaths(i),xfmi(i),yfmi(i),meanVelocity(i),d(i), validObservationTime(i),turnLeft(i), turnRight(i), p((filesepPosition(end-2)+1):end));
    end
end
    
 migrationData = [nPaths',nValidPaths',nValidPaths'./nPaths',xfmi',yfmi',...
                  meanVelocity',d',validObservationTime',turnLeft',turnRight',...
                  distanceLeft',distanceLeftAccu',distanceRight',distanceRightAccu',meanVelocityLeft',meanVelocityRight',meanVelocityNeutral',meanDLeft',meanDRight'];
              
 csvHeader = {'number of paths', 'valid paths', 'perc. of valid paths',...
              'xfmi','yfmi','mean velocity','directionality',...
              'valid observation time','perc. turning left',...
              'perc. turning right','dist left', 'ac. dist left','dist right','ac. dist right','velocity left','velocity right','velocity neutral','DLeft','DRight'};
 
 save([expPath filesep 'migrationData.mat'],'migrationData','fileList','pathList','csvHeader');
 %csvwrite_with_headers([expPath filesep 'migrationData.csv'],migrationData,csvHeader );
%%
 % export to csv
 fid = fopen([expPath filesep 'migrationData.csv'],'w');
 for i=1:length(csvHeader)
     fprintf(fid,'%s,',csvHeader{i});
 end
 
 fprintf(fid,'\n');
 %%
 for i=1:size(migrationData,1)
     [p,n,e] = fileparts(fileList{i});
     filesepPosition = strfind(p,filesep);
     expPathString = p((filesepPosition(end-2)+1):end);
     fprintf(fid,'%i, %i, %2.4e, %2.4e, %2.4e, %2.4e, %2.4e, %2.4e, %2.4e, %2.4e, %2.4e, %2.4e, %2.4e, %2.4e,%2.4e, %2.4e, %2.4e, %2.4e, %2.4e,  %s \n',migrationData(i,:),expPathString);
 end

