function [tLngDefrag,amDefrag,pmDefrag] = sortAM(tLngDefrag,amDefrag,pmDefrag)
% function to rewrite pmDefrag / amDefrag / tLngDefrag and to sort it
%  
%   [tLngDefrag,amDefrag,pmDefrag] = sortAM(tLng,am,pm)
%
%
%
%
%
% tim becker, 2010-2011



%
% first, we write all paths at the end of the timeline
% we start at the end and search for the first free 
% position, 
%


% we need enough empty space 
% we double the size of amDefrag(pmDefrag 
% (this is ok, am is sparse, and pm empty, -> only 
%  very little memory is needed )
n = size(amDefrag,1);

amDefrag(2*n,2*n) = 0;
pmDefrag(2*n,:) = {[] [] [] []};

% we extract all paths and all empty paths
pathList = evaluatePathStatus(pmDefrag,1);
emptyList = setdiff(1:length(pmDefrag),pathList);

% we move all paths to the end and all empty ones 
% to the beginning
[tLngDefrag,amDefrag,pmDefrag,changeList] = defragAM(tLngDefrag,amDefrag,...
    pmDefrag,pathList,emptyList);

% to check if the all empty paths are shifted to the beginning:
%pathList = evaluatePathStatus(pmDefrag,1);
%emptyList = setdiff(1:length(pmDefrag),pathList);
%isequal(emptyList,1:length(emptyList))



%% reorder paths (tree by tree)
% get lineages
[treeList,treeRelationList,lm,treeLength] = getLineages(amDefrag,pmDefrag);
pathList2 = evaluatePathStatus(pmDefrag,1);
pathList = [];

% 
for iPath=1:length(pmDefrag)
    if ~isempty(pmDefrag{iPath,1})
        pathList = [pathList,iPath];
    end
end
emptyList = setdiff(1:length(pmDefrag),pathList);

tList = [];
for i=1:length(treeList)
    tList = [tList; treeList{i}(:)];
end
noTreeList = setdiff(pathList,tList);

%%
for iTree = 1:length(treeList)
    tree = treeList{iTree};
    pathList = evaluatePathStatus(pmDefrag,1);
    emptyList = setdiff(1:length(pmDefrag),pathList);
    [tLngDefrag,amDefrag,pmDefrag] = defragAM(tLngDefrag,amDefrag,...
    pmDefrag,tree,emptyList(end:-1:1));
end

%
% todo: notEmptyPathlist <- k.a. was ich da meinte, hat das 
% noch bedeutung?
%
 pathList = evaluatePathStatus(pmDefrag,1);
 emptyList = setdiff(1:length(pmDefrag),pathList);
 [tLngDefrag,amDefrag,pmDefrag] = defragAM(tLngDefrag,amDefrag,...
     pmDefrag,noTreeList,emptyList(end:-1:1));

%%


pathnumber = length(pathList);
% the last step: we delete all empty paths
amDefrag = amDefrag(1:pathnumber,1:pathnumber);
pmDefrag = pmDefrag(1:pathnumber,:);



