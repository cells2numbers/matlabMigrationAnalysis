cd '/media/beckert/My Passport/2015_daten_migration/';

filename = 'expInfo.mat';
[fileList,pathList] = searchFileRec(pwd,filename);


nFiles = size(fileList,2);

radius = 45;
frameRadius = 3;
SAVE = 1;
detection_method = 2;

for i=1:nFiles
    % check if detection file is written
    exp.detectionParaStored(i) = exist([pathList{i} filesep 'images' filesep 'image_parameters.mat'],'file');
    exp.tracked(i) =  exist([pathList{i} filesep 'results' filesep 'image_tLng.mat'],'file');
    exp.analyzed(i) =  exist([pathList{i} filesep 'results' filesep 'migrationData.mat'],'file');
end

fprintf('found %i extracted experiments (image series) \n ',nFiles);
fprintf(' parameter stored: %i \n ',length(find(exp.detectionParaStored)));  
fprintf(' already tracked:  %i \n ',length(find(exp.tracked)));
fprintf(' already analyzed: %i \n',length(find(exp.analyzed)));

%%

index2track = setdiff(find(exp.detectionParaStored), find(exp.tracked));

index2amalyze = setdiff(find(exp.tracked), find(exp.analyzed));

parfor i=1:length(index2track)
    fprintf('---------------------------------------------------\n');
    fprintf('tracking image series %i of the last missing %i \n',i,length(index2track));
    iExp = index2track(i);
    performTracking(pathList{iExp},'image_001.png',...
        detection_method,radius,frameRadius,SAVE);
    fprintf('finished image series %i of the last missing %i \n',i,length(index2track));
    fprintf('---------------------------------------------------\n\n');
end
%

parfor i=1:length(index2amalyze)
    fprintf('---------------------------------------------------\n');
    fprintf('analyzing image series %i of the last missing %i \n',i,length(index2amalyze));
    iExp = index2amalyze(i);
    performMigrationAnalysis(pathList{iExp});
    fprintf('finished image series %i of the last missing %i \n',i,length(index2amalyze));
    fprintf('---------------------------------------------------\n\n');
end


if 1
    %%
    indexAnalyzed = find(exp.analyzed);
    fprintf('\n');
    fprintf('-----------------------------------------------------------\n');
    fprintf('paths \t valid \t ratio \t X-FMI \t Y-FMI \t D \t filename \n');
    fprintf('-----------------------------------------------------------\n');
    for i=1:length(indexAnalyzed)
        iExp = indexAnalyzed(i);
        trackingDataFile = [pathList{iExp} filesep 'results' filesep 'image_tLng.mat'];
        migrationDataFile = [pathList{iExp} filesep 'results' filesep 'migrationData.mat'];
        load(trackingDataFile);
        load(migrationDataFile);
        nPaths(i) = size(pm,1);
        nValidPaths(i) = length(validPaths);
        xfmi(i) = FMI(1);
        yfmi(i) = FMI(2);
        d(i) = sum(D)/length(D);
        fprintf('%i \t  %i \t %1.2f \t %1.2f \t %1.2f \t %1.2f \t %s \n',...
            nPaths(i),nValidPaths(i),nValidPaths(i)/nPaths(i),xfmi(i),yfmi(i),d(i),fileList{i});
    end
end
    
migrationData = [nPaths',nValidPaths',nValidPaths'./nPaths',xfmi',yfmi',d'];

save('migrationData.mat','migrationData','fileList','pathList');

