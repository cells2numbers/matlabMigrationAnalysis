function [] = performBatchCSVExport(expPath,OVERWRITE)
% Batch csv export as tidy list 
%
% All analyzed experiments found in the given folder are exported as 
% csv
%
% Input
%   expPath         The experiment path is recursively searched for 
%                   analyzed experiments
%
% Optional Input
%   OVERWRITE       Force overwrite of already exported experiments    
% 
%
% See also exportTidyTrajectories, correctFM, performCSVExport
% 3.2017 tb

if ~exist('OVERWRITE','var')
    OVERWRITE = 0;
end

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

fprintf('\nfound %i extracted experiment(s) \n ',nFiles);
fprintf(' parameter stored: %i \n ',length(find(exp.detectionParaStored)));  
fprintf(' already tracked:  %i \n ',length(find(exp.tracked)));
fprintf(' already analyzed: %i \n ',length(find(exp.analyzed)));
fprintf(' already exported: %i \n ',length(find(exp.exported)));

if OVERWRITE
     index2export = find(exp.analyzed);
else 
    index2export = setdiff(find(exp.analyzed), find(exp.exported));
end

if isempty(index2export)
    fprintf('I am bored, nothing to do. Bye... \n');
else
    parfor i=1:length(index2export)
        fprintf('exporting image series %i / %i \n',i,length(index2export));
        iExp = index2export(i);
        performCSVExport(pathList{iExp});
    end
end