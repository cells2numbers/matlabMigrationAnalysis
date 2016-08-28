function [] = performBatchTracking(expPath,OVERWRITE)
%
%
%
% 

if ~exist('OVERWRITE','var')
    OVERWRITE = 0;
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

fprintf('\nfound %i extracted experiment(s) \n ',nFiles);
fprintf(' parameter stored: %i \n ',length(find(exp.detectionParaStored)));  
fprintf(' already tracked:  %i \n ',length(find(exp.tracked)));
fprintf(' already analyzed: %i \n',length(find(exp.analyzed)));

%%

if OVERWRITE
     index2track = find(exp.detectionParaStored);
else 
    index2track = setdiff(find(exp.detectionParaStored), find(exp.tracked));
end

if length(index2track) == 0
    fprintf('I am bored, nothing to do. Bye... \n');
else
    
    parfor i=1:length(index2track)
        fprintf('---------------------------------------------------\n');
        fprintf('tracking image series %i of the last missing %i \n',i,length(index2track));
        iExp = index2track(i);
        performTracking(pathList{iExp},'image_001.png',...
            detection_method,radius,frameRadius,SAVE);
        fprintf('finished image series %i of the last missing %i \n',i,length(index2track));
        fprintf('---------------------------------------------------\n\n');
    end
end

