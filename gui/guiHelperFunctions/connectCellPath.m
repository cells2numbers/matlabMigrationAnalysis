function pathdata = connectCellPath(tLng,pathdata,cellToConnect,frame)
% connects the paths of two cells 
%
% pathdata = connectCellPath(tLng,pathdata,cellToConnect,frame)
%
% we calculate the new cellpath, one forward, one backward for the new
% cell and then we connect the 2 paths
% if the backward cellpath exists the user decides what to do...
%
% INPUT:
% tLng       timelineNG-struct    
% pathdata   matrix => frames | x-coordinates | y-coordinates | cellnumber    
% cellToConnect     
% frame             
%
% OUTPUT:
% pathdata   matrix => frames | x-coordinates | y-coordinates | cellnumber
%
% Copyright M.B. 04.09
path_f = cellpathTimelineNG(tLng,cellToConnect,...
    'threshold_f',0.7,'threshold_b',0.7,'time',frame);
path_b = cellpathTimelineNG(tLng,cellToConnect,'backward',...
    'threshold_f',0.7,'threshold_b',0.7,'time',frame);
%if the backward path exists don't connect it, let the user decide
if size(path_b,1) > 1
%------------------------USER CHOICE CURRENTLY DEACTIVATED-----------------
    %errorMessage = sprintf('User interference needed!\nFrame: %d',frame);
    %userChoice = errorMenu(errorMessage,'take only forward path','abort');
    userChoice = 1;
%--------------------------------------------------------------------------
    %if user choices to take only the forward path do this
    if userChoice == 1
        path = path_f;
        
        %add the coordinates of the cells to the path
        path(:,4) = path(:,2);
        for j = 1:size(path,1)
            path(j,2:3) = tLng.cell(1,path(j,1)).centroid(path(j,2),:);
        end
        
        sizeOldPath = size(pathdata,1);
        pathdata(sizeOldPath+1:size(path,1)+sizeOldPath,1:4) = path;
    elseif userChoice == 2
        error('stopped by user interaction');
    end
else
    % make one big path
    path = [path_f(2:end,:);path_b];
    [v,i] = sort(path(:,1));  % sort them
    path = path(i,:);
    sizeOldPath = size(pathdata,1);
    %add the coordinates of the cells to the path
    path(:,4) = path(:,2);
    for j = 1:size(path,1)
        path(j,2:3) = tLng.cell(1,path(j,1)).centroid(path(j,2),:);
    end
    pathdata(sizeOldPath+1:size(path,1)+sizeOldPath,1:4) = path;
end
end