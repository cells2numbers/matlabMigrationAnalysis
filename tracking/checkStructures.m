function [PATHOK,path2correct] = checkStructures(am,pm,fm,tLng,VERBOSE)
% checkStructures(am,pm,fm,tLng)
%
%  [PATHOK,path2correct] = checkStructures(am,pm,fm,tLng)
% 
%
% input          am 
%                pm
%                fm
%                tLng
%
%
% output         PATHOK         Bindary value, true if all paths are ok 
%                path2correct   cell array containing all lists with 
%                               wrong lists (cellpahts) 
%                               
%                               path2correct = {wrongMitosis,...
%                                     wrongLost,wrongBegin,wrongEnd,...
%                                     wrongPred,wrongSucc,noEnd};
%
% checkStructures checks for consitency of the given data 
% data structures (am,pm,tLng,fm)
%
% a typical output looks like this:
%
% all wrong paths can be accessed using different 
% path-list, to access these, run the function as 
% an script (otherwise they are deleted)
%
%  path consistency,  	 	       no error
%  AM entries checked, 	 	       no error
%  cellpaths checked,  	 	       no error 
%  feature matrix checked, 	       no error
%  mitotic cells checked,  	       no error
%  ending cells checked,  	       no error
%  beginning cells checked,  	   no error
%  lost cells checked,  	  	   no error
%  predecessor cells checked,      no error
%  successor cells checked,   	   no error
%  all paths ends checked,   	   no error
%  good work: no errors detected!
%
%  complete structure check performed in  0.769 seconds
%
%  empty pahts    0
%  ~empty pahts   1431
%  corrected      0
% ----------------------
%  left           1431

% check for optional parameter VERBOSE
if ~exist('VERBOSE','var')
    VERBOSE = 0;
end


%% script / function to check the structure for am / pm / fm / tLng
timeBegin = tic;
pathlist = [];
epathlist = [];
FAIL =0;

% first we count empty paths
for i=1:size(pm,1)
   if isempty(pm{i,1})
       epathlist = [epathlist,i];
   else
       pathlist = [pathlist,i];
   end
end

%% path length check
% we check if we have two cells in one frame 
% or if one frame is missing a cell
wrongPath = [];
for iPath=1:size(pm,1)
    if ~isempty(pm{iPath,1})
       frames = unique( pm{iPath,3}(:,1));
       if length(frames) ~= pm{iPath,2} - pm{iPath,1} +1 || ...
              ~isequal( sort(pm{iPath,3}(:,1)),unique( pm{iPath,3}(:,1)))
           wrongPath = [wrongPath,iPath];
       end
    end
end


if ~isempty(wrongPath)
    fprintf('  path consistency checked, \t error, see "wrongPath" \n');
    FAIL = 1;
else
    fprintf('  path consistency,  \t \t no error \n');
end

%% check deleted cellpaths
% we check if the connections from / to all empty paths are deleted
wrongAM = zeros(1,length(epathlist));
for iPath=1:length(epathlist)
    pNr = epathlist(iPath);
    wrongAM(iPath) =  sum(am(pNr,:)~=0) + sum(am(:,pNr)~=0);
end

wrongAM = epathlist(wrongAM > 0);


if ~isempty(wrongAM)
    fprintf('  AM entries  checked, \t \t %i error, see "wrongAM"\n',length(wrongAM));
    FAIL = 1;
else
    fprintf('  AM entries checked, \t \t no error\n');
end



%% cellpath check

% first we search for all cells not belonging to a path
% and for deleted cells
wrongCellpath = [];
cellDeleted = [];

for iFrame = 1:tLng.time_max
    pathNrs = tLng.cell(iFrame).status;
    for iCell = 1:length(pathNrs)
        
        iPath = pathNrs(iCell);
        
        if iPath == -10  % deleted cells have status -10
            cellDeleted = [cellDeleted;iFrame,iCell];
        elseif  isempty(pm{iPath,1}) % wrong status or empty path
            wrongCellpath = [wrongCellpath;iFrame,iCell,iPath];
        end
        
    end
    if VERBOSE & ~mod(iFrame,10)
        fprintf('pathcheck: %i from %i done \n',iFrame,tLng.time_max);
    end
end


if ~isempty(wrongCellpath)
    fprintf('  cellpaths checked,  \t  \t error, see "wrongCellpath" \n');
    FAIL = 1;
else
    fprintf('  cellpaths checked,  \t \t no error \n');
end



% now we check if all deleted cells really are deleted
cellNotDeleted = [];
for iCell = 1:size(cellDeleted,1)
    frameNr = cellDeleted(iCell,1); 
    cellNr = cellDeleted(iCell,2);
    if ~isempty(tLng.cell(frameNr).cells{cellNr})
        cellNotDeleted = [ cellNotDeleted;frameNr,cellNr];
%    else 
%         tLng.cell(frameNr).status(cellNr) = -10;
%        tLng.cell(frameNr).predecessor{cellNr} = [];
%        tLng.cell(frameNr).successor{cellNr} =  [];
%        tLng.cell(frameNr).neighbour(cellNr,:) = zeros(1,10);
%        tLng.cell(frameNr).centroid(cellNr,:) = [10^5,10^5];
    end
end


%% we check the feature matrix
wrongFeatureFrame = [];

if ~isempty(fm)
    for iFrame=1:tLng.time_max
        if size(fm{iFrame},1) ~= length(tLng.cell(iFrame).status)
            wrongFeatureFrame = [wrongFeatureFrame,iFrame];
        end
    end
    
    if ~isempty(wrongFeatureFrame)
        fprintf('  feature matrix checked, \t error, see "wrongFeatureFrame" ');
        FAIL = 1;
    else
        fprintf('  feature matrix checked, \t no error\n');
    end
    
end



%% we check the flags, first mitosis

mitosisList = [];
endList = [];
beginList = [];
borderBeginList = [];
borderEndList = [];
lostList = [];
lostEndList = [];
lostBeginList = [];
correctedList = [];
coupledList = [];
 
for iPath=pathlist
    [statusVector,statusInt] = getPathStatus(pm,iPath);
    
    if statusVector(3)
        mitosisList = [mitosisList,iPath];
    end
    
    if statusVector(4)
        borderBeginList = [borderBeginList,iPath];
    end
    
    if statusVector(5)
        borderEndList = [borderEndList,iPath];
    end

    % this lost flag is obsolete 
    % ( see lostEnd and lostBegin flag)
    if statusVector(6)
        lostList = [lostList,iPath];
    end
    
    % this 
    if statusVector(7)
        correctedList = [correctedList,iPath];
    end
    
    if statusVector(8)
        endList = [endList,iPath];
    end
    
    if statusVector(9)
        beginList = [beginList,iPath];
    end
     
    if statusVector(10)
        lostBeginList = [lostBeginList,iPath];
    end
    
    if statusVector(11)
        lostEndList = [lostEndList,iPath];
    end
    
    if statusVector(12)
        coupledList = [coupledList,iPath];
    end
end



%% mitosis check
% we count all children in the childList
childList = zeros(size(mitosisList));
for iPath = 1:length(mitosisList)
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,mitosisList(iPath));
    childList(iPath) = dOut;
end
% we select the mitoses with more or less than two children
wrongMitosis  = mitosisList(childList ~= 2);

if ~isempty(wrongMitosis)
    fprintf('  mitotic cells checked,  \t error, see "wrongMitosis"\n');
    FAIL = 1;
else
    fprintf('  mitotic cells checked,  \t no error\n');
end



%% we check for correct ending / beginning flags
% begin flags are only allowed in cellpaths beginning in frame 1
% ending flags only in the last frame
wrongEnd = zeros(size(endList));

for iPath=1:length(wrongEnd)
    wrongEnd(iPath) = pm{endList(iPath),2} ~=tLng.time_max;
end
wrongEnd = endList(wrongEnd==1);
% we only allow one ending flag set, so we count all intersecting paths
% 
% no, i thought about it, we just now allow more flags... 
% ( after some thousand paths corrected it seems the better way)
%
%wrongEnd = [wrongEnd,...
%    intersect(lostEndList,endList),...
%    intersect(lostEndList,borderEndList),...
%    intersect(endList,borderEndList)];

if ~isempty(wrongEnd)
    fprintf('  ending cells checked,  \t error, see "wrongEnd"\n');
    FAIL = 1;
else
    fprintf('  ending cells checked,  \t no error\n');
end

wrongBegin = zeros(size(beginList));
for iPath=1:length(wrongBegin)
    wrongBegin(iPath) = pm{beginList(iPath),1} ~=1;
end
wrongBegin = beginList(wrongBegin == 1);
%wrongBegin = [wrongBegin,...
%    intersect(lostBeginList,beginList),...
%    intersect(lostBeginList,borderBeginList),...
%    intersect(beginList,borderBeginList)];


if ~isempty(wrongBegin)
    fprintf('  beginning cells checked,  \t error, see "wrongBegin"\n');
    FAIL = 1;
else
    fprintf('  beginning cells checked,  \t no error\n');
end



%% OBSOLETE: we check lost flags

wrongLost = zeros(size(lostList));

for iPath = 1:length(lostList)
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,lostList(iPath));
    wrongLost(iPath) = dOut;
end
wrongLost = lostList(wrongLost >0);

if ~isempty(wrongLost)
    fprintf('  lost cells checked,  \t  \t error, see "wrongLost"\n');
    FAIL = 1;
else
    fprintf('  lost cells checked,  \t  \t no error\n');
end



%% we check predecessor/ successor cells
wrongPred = zeros(size(pathlist));
for iPath = 1:length(pathlist)
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,pathlist(iPath));
    wrongPred(iPath) = dIn;
end
% all paths are only allowed to have exactly one predecessor
wrongPred = pathlist(wrongPred>1);
wrongPred = setdiff(wrongPred,lostBeginList);

if ~isempty(wrongPred)
    fprintf('  predecessor cells checked,   \t error, see "wrongPred"\n');
    FAIL = 1;
else
    fprintf('  predecessor cells checked,   \t no error\n');
end



%% !!! how to check successor cells ???
pathNoMitosis = setdiff(pathlist,mitosisList);
wrongSucc = zeros(size(pathNoMitosis));

for iPath = 1:length(pathNoMitosis)
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,pathNoMitosis(iPath));
    wrongSucc(iPath) = dOut;
end

wrongSucc = pathNoMitosis(wrongSucc>=1);
wrongSucc = setdiff(wrongSucc,lostEndList);
if ~isempty(wrongSucc)
    fprintf('  successor cells checked,   \t error, see "wrongSucc"\n');
    FAIL = 1;
else
    fprintf('  successor cells checked,   \t no error\n');
end

% cells with no ending flag

noEnd = setdiff(pathlist, unique([mitosisList,endList,borderEndList,lostEndList]));

%timeEnd = toc(timeBegin);


if ~isempty(noEnd)
    fprintf('  all paths ends checked,   \t error, see "noEnd"\n');
    FAIL = 1;
else
    fprintf('  all paths ends checked,   \t no error\n');
end

if FAIL
    fprintf('\n ERROR(S) FOUND, SEE MESSAGES / LISTS!! \n');
else
    disp(' good work: no errors detected!');
end


%% we check the path status



%%
fprintf('\n complete structure check performed in %6.3f seconds\n\n',toc(timeBegin));
fprintf(' empty pahts    %i\n',length(epathlist));
fprintf(' ~empty pahts   %i\n',length(pathlist));
fprintf(' corrected      %i\n',length(correctedList));
fprintf('----------------------\n');
fprintf(' left           %i\n',length(pathlist) - length(correctedList));



%% additional check, 
% we check for each cell in the timline if this cell is stored
% % in the cellpath in the pm
 suckList = [];
for iFrame=1:tLng.time_max
    for iCell = 1:length(tLng.cell(iFrame).status)
        
            pathNr = tLng.cell(iFrame).status(iCell);
            
            if pathNr >0
                cellpath = pm{pathNr,3};
                if ~isempty(cellpath)
                    cellNr = cellpath(cellpath(:,1) ==iFrame,2);
                else
                    cellNr = 0;
                end
                if cellNr ~=iCell
                    suckList = [suckList;iFrame,iCell,pathNr];
                end
                
            end
    end
end
%%
%for i=1:size(suckList,1)
%    frameNr = suckList(i,1); 
%    cellNr = suckList(i,2);   
%    tLng = removeCell(tLng,frameNr,cellNr);
%end
%%
sList = [];
for iFrame = 1:tLng.time_max
    pathlist = tLng.cell(iFrame).status;
   pathlist =  pathlist(pathlist>0);
  if  length(pathlist) ~= length(unique(pathlist))
    sList = [sList,iFrame];
  end
end

PATHOK = ~FAIL;


 
%%
PLOT = 0;
if PLOT
 emptySum = [3132 3179 3307 3533 3977 4347 4735 4919 5326 5564 5835 6136 6321 6548 6753];
 pathSum =  [6670 6636 6584 6483 6267 6024 5785 5654 5435 5284 5126 4969 4893 4799 4687];
 corrSum =  [1222 1272 1345 1516 1842 2163 2561 2810 3087 3249 3615 4126 4451 4602 4687];
 todoSum =  [5448 5364 5345 4967 4425 3861 3224 2844 2348 2035 1511  843  442  197   0];
 timeSum =  [0    0.5  1    1.5  2    2.5  3    3.5  4    5    5.5  6    6.5  7    7.5];

figure();
plot(timeSum,emptySum,':');hold on;
plot(timeSum,pathSum,'-.')
plot(timeSum,corrSum,'--')
plot(timeSum,todoSum,'b')
legend('empty','not empty','correct','todo')
end

%%
path2correct = {wrongMitosis,wrongLost,wrongBegin,wrongEnd,wrongPred,wrongSucc,noEnd};
fprintf('output: \n 1. wrongMitosis \n 2. wrongLost \n 3. wrongBegin  \n 4. wrongEnd \n 5. wrongPred \n 6. wrongSucc \n 7. noEnd \n');