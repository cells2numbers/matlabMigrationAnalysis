function [tLng,am,pm,changeList] = defragAM(tLng,am,pm,pathList,emptyList)
% defragAM: function to defrag a timlin (tlng, am, pm)
%
%  [tLng,am,pm] = defragAM(tLng,am,pm,pathlist,emptylist)
%
%  input: 
%      -tLng,am,pm:  complete timeline
%      -pathlist:    paths that should be defraged
%      -emptylist:   empty paths (free space,   
%
% TODO: document this function
changeList = [];

while ~isempty(pathList) && ~isempty(emptyList)
    % we move p1 into p2 and clean p1
    p1 = pathList(1);
    p2 = emptyList(end);
    
    
    changeList = [changeList;p1,p2];
    pm(p2,:) = pm(p1,:);
    pm(p1,:) = {[] [] [] [0] };
    
    % we change the connectivity in the adjacency matrix
    am(p2,:) = am(p1,:);
    am(:,p2) = am(:,p1);
    am(p1,:) = 0;
    am(:,p1) = 0;
    
    % the last step: correct the timeline, we have to update
    % each single cell belonging to the changed path
    cellpath = pm{p2,3};
    
    for i=1:size(cellpath,1)
        frameNr = cellpath(i,1);
        cellNr = cellpath(i,2);
        tLng.cell(frameNr).status(cellNr) = p2;
    end
    
    % now we shorten the lists
    pathList = pathList(2:end);
    emptyList = emptyList(1:end-1);
    
end