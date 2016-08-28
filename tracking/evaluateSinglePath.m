function [samePath,cellsOK] = evaluateSinglePath(tLngRef,tLngTest,pathRef,pathTest,varargin)
% function to check if two paths for different timelines are identical
%
% 
%  samePath = evaluateSinglePath(tLngRef,tLngTest,pathRef,pathTest)
%
%  where samePath returns TRUE / FALSE values
%
%  pathRef and pathTest are both paths as given in pm
%  ( for example  pathRef = pm{7,3} )
%
% tim becker, march 2010


% some parameters for path evaluation, later as optional arguments
CHECKLENGTH = 0;  
LENGTHOK = 1;
PATHOK = 1;
MAXDISTANCE = 15;
OVERLAPTHRESH = .1;

% init return value
samePath = 0;

% at first we check the length of each path
% if either end or begin are a distance  more 
%than two frames we dont accept the length as 
% valid
if abs( pathRef(1,1) - pathTest(1,1)) > MAXDISTANCE ||...
    abs( pathRef(end,1) - pathTest(end,1)) > MAXDISTANCE
    LENGTHOK = 0;
end

% we need the start and end values for both paths
% (the frames with cells in both paths, else we have 
% a problem if the paths start at different times)
pathBegin = max(pathRef(1,1),pathTest(1,1));
pathEnd = min(pathRef(end,1),pathTest(end,1));

% we check each cell, therefore we need:
cellsOK = zeros(pathEnd - pathBegin +1,1);

% loop over all frames existing in both paths (see above)
for iFrame = pathBegin:1:pathEnd
    % we need the cellnumber 
    cellRef  =  pathRef(pathRef(:,1) == iFrame,2);
    cellTest =  pathTest(pathTest(:,1) == iFrame,2);
    % and now the mask for each each   
    % we have to check for coupled cells: in this case we can
        % have an emtpy mask...
    if  ~isempty(cellRef) &&  ~isempty(cellTest)
        maskRef = tLngRef.cell(iFrame).cells{cellRef};
        maskTest =  tLngTest.cell(iFrame).cells{cellTest};
        % now we can check if both mask describe the same cell
    
        cellsOK(iFrame - pathBegin + 1) = length(intersect(maskTest,maskRef)) / length(maskTest) > OVERLAPTHRESH;
    else  % if one of the masks is empty, we have an coupled cell, the 
          % paths lacks a cell in one timestep...  
          cellsOK(iFrame - pathBegin + 1) = 1;
    end
end

PATHOK = sum(cellsOK) == length(cellsOK);


samePath = LENGTHOK && PATHOK;