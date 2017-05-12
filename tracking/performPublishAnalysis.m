function [] = performPublishAnalysis(expPath)
% publish analysis of tracking experiments
%
% Function to recursively publish all tracked migration experiments
% in an given path. 
%
% Input
%   expPath      Folder storing all experiment data
%   
%
%

filename = 'expInfo.mat';
[fileList,pathList] = searchFileRec(expPath,filename);

nFiles = size(fileList,2);


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

index2publish = find(exp.analyzed);

for i=1:length(index2publish)
    fprintf('---------------------------------------------------\n');
    fprintf('analyzing image series %i of %i \n',i,length(index2publish));
    iExp = index2publish(i);
    
    opts.codeToEvaluate =  sprintf('publishAnalysis(''%s'');',pathList{iExp});
    opts.outputDir = [ pathList{iExp} filesep 'results']; 
    file = publish('publishAnalysis',opts);
    
    fprintf('finished image series %i of  %i \n',i,length(index2publish));
    fprintf('---------------------------------------------------\n\n');
end



