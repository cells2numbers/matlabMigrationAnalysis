% add source folder to the matlab path
source_paths = {'analysis','detection','gui','io','tracking'};

for iPath = 1:length(source_paths)
   pathinfo = what(source_paths{iPath});
   addpath(genpath(pathinfo(end).path));
end

clear;
