function[csv,csvHeader] = performCSVExport(experimentPath)
% export cell and trajectory information in a tidy format
%
% [csv,csvHeader] = performCSVExport(experimentPath)
%
% The csv is stored in the results folder of the experiment 
%
% Input
% 
%   expPath       Path to an experiment analyzes using migrationAnalysis
%
% Output 
%   csv         Matrix storing all features 
%   csvHeader   Header of the csv File 
%
%
%    1. frameID 
%    2. cellID 
%    3. trajectoryID
%    4. x-position 
%    5. y-position 
%    6. area          as sum of pixels 
%    7. brightness    mean brigthness of the cell area in the raw image
%    8. length        of the major axis
%    9. compactness   as (4 pi Area) / Perimeter^2 
%   10. orientation   between -90 and 90
%   11. image name 
%
%  
% see also exportTidyTrajectories, correctFM, performBatchCSVExport
%
% TB 03.2017


load([experimentPath filesep 'results' filesep 'image_tLng.mat'])
load([experimentPath filesep 'results' filesep 'migrationDataValidPaths.mat'])

csvName = [experimentPath filesep 'results' filesep 'featureList.csv' ];

csv = exportTidyTrajectories(pm,fm,validPaths);

% get experiment name 
fileSepPosition = strfind(experimentPath,filesep);
experimentName = experimentPath(fileSepPosition(end)+1:end);

csvHeader = {'frameID','cellID','trajectoryID','x position','y position',...
    'area','brightness','length','compacthness','orientation','experimentID'};

% first we write the header
fid = fopen(csvName,'w');
for i=1:length(csvHeader)
    if i==length(csvHeader)
        fprintf(fid,'%s ',csvHeader{i});
    else
        fprintf(fid,'%s, ',csvHeader{i});
    end
end

fprintf(fid,'\n');
%%
for i=1:size(csv,1)
    fprintf(fid,'%i, %i, %i, %6.6f, %6.6f ,%6.6f, %6.6f, %6.6f, %6.6f, %6.6f, %s \n',csv(i,:),experimentName);
end
fclose(fid);