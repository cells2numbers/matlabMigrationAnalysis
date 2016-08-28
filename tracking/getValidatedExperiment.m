function [data,tLngFiles] = getValidatedExperiment(ExpPath,pathlength,timeWindow,outlier)
% 
%   [data,tLngFiles] = getValidatedExperiment(ExpPath)
%
%
%
%
%
% see also  getExperimentParameterFiles.m, getValidatedParameter.m,
%   mergeData
% t.b.

% if no path is given, we open an experiment folder
if ~exist('ExpPath','var')
    ExpPath = uigetdir();
end

if ~exist('outlier','var')
    outlier = [];
end

% if no values for pathlength / timewindow are given, default values are
% set
if ~exist('pathlength','var')
    pathlength = 5;
end

if ~exist('timeWindow','var')
    timeWindow = 5;
end

% extract timeline paths / names
[parameterFiles,tLngFiles] = getExperimentParameterFiles(ExpPath);

% get number of positions 
NPos = length(tLngFiles);

% for each position, the data struct is calculated
dataIn = {};
for iPos=1:NPos
    if isempty(outlier) || ~sum(outlier == iPos)
        fprintf('processing timeline %i/%i... ',iPos,NPos);
        load(tLngFiles{iPos});
        dataIn{end+1} = getValidatedParameter(tLng,pm,fm,pathlength,timeWindow);
        fprintf('done! \n');
    end
end
fprintf('done! \n \n merging data.... ');
% get rid of unused variables
clear('tLng','am','pm','fm','mu','sigma');

% merge all data into one 
data = mergeData(dataIn);
fprintf('done! \n');