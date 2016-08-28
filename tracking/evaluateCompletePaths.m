function[completePathList,correctPathList] = evaluateCompletePaths(tLngRef,amRef,pmRef,tLng,am,pm,minPathOverlap,varargin)
% this function evaluates complete paths using a reference data set
%
%  [completeList,correctList] = evaluateCompletePaths(tLngRef,amRef,pmRef,tLng,am,pm,varargin)
%
%  
%
%
%
%
%  Example I
% 
%  load refdataSmaller.mat
%  tLngRef = tLng; amRef = am; pmRef = pm;fmRef = fm;
%
%  load smallertLng.mat
%   
%   % detect mitosis
%   mList = getMitosisGraph(am,pm);
%
%   % set mitosis status
%   for i = 1:length(mList)
%       iPath = mList(i);
%       [pm,tLng,newStatus] = setPathStatus(tLng,pm,iPath,'mitosis',1);
%   end
%
%   [completeList,correctList] = evaluateCompletePaths(tLngRef,amRef,pmRef,tLng,am,pm);
%   compLength = length(completeList);
%   corLength = length(correctList);
%   fprintf('%i complete paths \n',compLength);
%   fprintf('%i correct detected, ~%6.2f%%  \n',corLength,100 * corLength/compLength);
 %
%  Example II / see also:
%  
%  testNaiveTracking.m
%
% tim becker, june 2010

if ~exist('minPathOverlap','var')
    minPathOverlap = 6;
end


[mitoseList,mTimes] = evaluatePathStatus(pm,2);

pffm  = zeros(length(mitoseList),3);
for iPath = 1:length(mitoseList)
    pathNr = mitoseList(iPath);
     [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,pathNr);
     cCells =  cNOut(:,1)';
     % in the reference data, we allow mitotic cells 
     % with only one successor cell 
     % (border problem)
     
     if length(cCells) == 2
         pffm(iPath,:) = [pathNr,cCells(1:2)];
     else
         pffm(iPath,:) = 0;
     end
end



completePathList = [];
siblingsList = [];

for iPath = 1:length(pffm)
    
    %minPathLength = 20;
    child1 = pffm(iPath,2);
    child2 = pffm(iPath,3);
    
    % again we have to check if we have a path with
    % only on successor
    
    if child1 > 0 && child2 > 0
        CHILD1OK = pm{child1,2} - pm{child1,1} > minPathOverlap;
        CHILD2OK = pm{child2,2} - pm{child2,1} > minPathOverlap;
        
        s1 = sum(pffm(:,1) == child1);
        s2 = sum(pffm(:,1) == child2);
        
        
        if s1 && CHILD1OK
            completePathList = [completePathList,child1];
        end
        
        if s2 && CHILD2OK
            completePathList = [completePathList,child2];
        end
        
        if s1 && s2 && CHILD1OK && CHILD2OK
            siblingsList = [siblingsList;[child1, child2]];
        end
    end
end
noCor = [];

% fourth:  we check, if for each cell exists one reference path
correctPaths = 0;
correctPathList = [];
wrongPathList = [];
for iPath = 1:length(completePathList)
    pathTest = completePathList(iPath);
    % we have to extract the correspondinng path, therefore
    % we choose a cell in the middle, look for a corresponding cell
    % in the refdata. From that cell we get the corresponding path
    % -> then we can check the data
    
    
    checkNr = round( .8* length(pm{pathTest,3}));
    frameNr = pm{pathTest,3}(checkNr,1);
    cellNr = pm{pathTest,3}(checkNr,2);
    % corresponding cell nr
    corCell = getCorrespondingCell(tLng,frameNr,cellNr,tLngRef);
    
    if ~corCell
        checkNr = round( .8* length(pm{pathTest,3})) + 10;
        frameNr = pm{pathTest,3}(checkNr,1);
        cellNr = pm{pathTest,3}(checkNr,2);
        corCell = getCorrespondingCell(tLng,frameNr,cellNr,tLngRef);
    end
    
     if ~corCell
        checkNr = round( .8* length(pm{pathTest,3})) - 10;
        frameNr = pm{pathTest,3}(checkNr,1);
        cellNr = pm{pathTest,3}(checkNr,2);
        corCell = getCorrespondingCell(tLng,frameNr,cellNr,tLngRef);
     end
    
%      if ~corCell
%         checkNr = round( .5* length(pm{pathTest,3})) +4;
%         frameNr = pm{pathTest,3}(checkNr,1);
%         cellNr = pm{pathTest,3}(checkNr,2);
%         corCell = getCorrespondingCell(tLng,frameNr,cellNr,tLngRef);
%      end
%      
%       if ~corCell
%         checkNr = round( .5* length(pm{pathTest,3})) -4;
%         frameNr = pm{pathTest,3}(checkNr,1);
%         cellNr = pm{pathTest,3}(checkNr,2);
%         corCell = getCorrespondingCell(tLng,frameNr,cellNr,tLngRef);
%       end
     
    if corCell
        pathRef = tLngRef.cell(frameNr).status(corCell);
        % we check if the path is ok
        [samePath,cellsOK] = evaluateSinglePath(tLngRef,tLng,pmRef{pathRef,3},pm{pathTest,3});
        correctPaths = correctPaths + samePath;
        if samePath
            correctPathList(end+1) =  pathTest;
        else 
            wrongPathList(end+1) = pathTest;
        end
    else
        
        disp('no corresponding path found!');
        noCor = [noCor,pathTest];
        wrongPathList(end+1) = pathTest;
    end
    
end

