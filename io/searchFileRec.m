function[fileList,pathList] = searchFileRec(searchPath,filename)
% recursive file search 
%
% [fileList,pathList] = searchFileRec(searchPath,filename)
%
% input: 
%     searchPath         beginning from this folder, the filename or 
%                        expression given in filename is recursively 
%                        searched in each subfolder.
%
%     filename           name of file that is searched. can also be given 
%                        as expression, i.e. '.png' 
%
% output 
%                        for each found file, the exact filename and 
%                        path is returned. 
% 
%  fileList              cell array size 1xn with n found files 
%  pathList              cell array size 1xn with n found files 
%
%
% 5.2015, tim becker 

% search for the given file / filename in the searchpath 
fileList = {};
pathList = {};
list = dir([searchPath filesep filename]);

for iFile=1:length(list)
    fileList{end+1} = [searchPath filesep list(iFile).name];
    pathList{end+1} = searchPath;
end

% now we recursively search all folder 
dirList = dir(searchPath);
dirListIndex = find([dirList.isdir]);

for iDir=dirListIndex
  if ~(isequal(dirList(iDir).name,'.') || isequal(dirList(iDir).name,'..'))
      [fileListRec,pathListRec] =  searchFileRec([searchPath filesep dirList(iDir).name] ,filename);
      if ~isempty(fileListRec)
          fileList = {fileList{:},fileListRec{:}};
          pathList = {pathList{:},pathListRec{:}};
      end
    
  end
end
    