function [treeList,treeRelationList,lm,treeLength] = getLineages(am,pm)
%This function calculates from a given am (adjacency-matrix) and pm
%(pathmatrix) a cellarray with every complete tree (as a list) in the data.
%
%[treeList,treeRelationList,lm,treeLength] = getLineages(am,pm)
%
%
%  THIS FUNCTION USES NO MITOSES FLAG, ONLY THE CONNECTIVITY!!!
%  ONLY TO EXTRACT LINEAGES OUT OF REFERENCE DATA SETS!!!
%
%
% Input:
% am                  
% pm                    pathmatrix with all the paths in the lintree
%
%  Output:
%
%  treeList             cell-array, entry n stores all paths
%                       belonging to tree number n
%  lm                   lineage-matrix, size [#paths x 4],
%                       stores the predecessor path in entry 1,
%                       and both successors in entry 2,3
%  treeRelationList     has length(#trees) and stores in
%                       entry  n the tree of path n
%
% copyright tb, M.B. 01.2009
%

%build the pathList
pathList = [];
for j = 1:size(pm,1)
    %empty paths or path without mitosis-flag is set to zero
    statusVec = getPathStatus(pm,j);
    if (~isempty(pm{j,1})) && statusVec(3)
        pathList(end+1,1) = j;
    else
        pathList(end+1,1) = 0;
    end
end

%initalize treeRelationList
totalPathCount = size(pathList,1);
treeRelationList = zeros(totalPathCount,1);


%build the lineageMatrix (every entry = -1)
lineageMatrix = ones(length(pathList),4);
lineageMatrix = lineageMatrix*(-1);

for iPath = 1:length(pathList)
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,iPath);
    children = cNOut(:,1)';
    ancestor = cNIn(:,1)';
    if ~isempty(children) && length(children) == 2
        lineageMatrix(iPath,2:3) = children;
    end
    
    if ~isempty(ancestor) && length(ancestor) == 1
        lineageMatrix(iPath,1) = ancestor;
    end
end
%store this version of the lineageMatrix
lm = lineageMatrix;

path2check = [];
%cellarray for the trees
treeList = {};

while pathList(pathList>0)
    %find entry that is not 0
    path2check = find(pathList,1);
    tempTreeListEntry = [];
    firstElementOfP2C = [];
    
    while ~isempty(path2check)
        %the set which will be added is filled with the correct entries
        tempSet = lineageMatrix(path2check(1),1:3);
        tempSet = tempSet(tempSet>0);
        insertSet = [];
        for i = 1:size(tempSet,2)
            %if we have values ~= -1 we add them to the set
            if ~isempty(lineageMatrix(tempSet(i),:)>0)
                insertSet = [insertSet;tempSet(i)];
            end
        end
        %we need the first element of the path2check because UNION sorts
        %the values of path2check and after that we wouldn't find this
        %element
        firstElementOfP2C = path2check(1);
        %generate an entry for the cellarray treeList or update in every
        %iteration
        tempTreeListEntry = union(firstElementOfP2C,tempTreeListEntry);
        tempTreeListEntry = union(insertSet,tempTreeListEntry);
        %fill path2check with the new pathnumbers (from the next paths of
        %the tree)
        path2check = union(path2check, insertSet);
        %delete the entry that we used from the lineageMatrix...
        lineageMatrix(firstElementOfP2C,1:3) = -1;
        %...and from the path2check-list
        path2check(path2check == firstElementOfP2C) = [];
    end
    %every entry should be in the same appearance
    if size(tempTreeListEntry,1)==1
        tempTreeListEntry = tempTreeListEntry;
    end
    %make a new entry for a new tree in the list with the generated data
    treeList{end+1} = tempTreeListEntry';
    %set this entries of the tree now to 0
    pathList(treeList{end}) = 0;
end

%the last thing to do is generate the treeRelationList
for i = 1:size(treeList,2)
    treeRelationList(treeList{i},1) = i;
end
 
% %delete zero entries in the treeRelationList
%  nonZeroEntries = treeRelationList((treeRelationList(:,2)>0),1);
%  treeRelationList = treeRelationList(nonZeroEntries,:);

treeLength = zeros(1,length(treeList));
for iTree = 1:length(treeList)
    treeLength(iTree) = length(treeList{iTree});
end

end