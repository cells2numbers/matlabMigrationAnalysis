% Start script for the migration analysis. It does the following: 
% -add paths temporarily to the MATLAB path
% -check if parallel processing toolbox is available and starts a
%  matlabpool
% -start the migration gui
%
% Tim Becker

source_paths = {'analysis','detection','gui','io','tracking'};

for iPath = 1:length(source_paths)
   pathinfo = what(source_paths{iPath});
   addpath(genpath(pathinfo(end).path));
end

% check if parallel processing toolbox is available 
toolboxName = 'Parallel Computing Toolbox';
matlabVersion = ver;

if any(strcmp(toolboxName, {matlabVersion.Name}))
    % in new version, the parallel processing functionality is provided 
    % by parpool 
    if exist('parpool','file') == 2 
        parpool();
    else % in older version, matlabpool is used 
        matlabpool();
    end
end

clear;
migrationAnalysis()