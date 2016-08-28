function [tLng,pm,am] = removeCellFromPath(tLng,pm,am,pathNumber,frameNr)
% This function deletes a cell from a path and changes the pm and am
% automatically.
%
% [tLng,pm,am] = removeCellFromPath(tLng,pm,am,pathNumber,frameNr)
%
% Three cases will be tested:
% 1.    the cell is the first cell in the path. => Cut the cell and leave 
%       the rest of the path intact.
% 2.    the cell is the last cell in the path. => Cut the cell and leave 
%       the first part of the path intact.
% 3.    the cell in the middle of the path. => Cut the path in two at the
%       postion of the cell (the frame before and after the cell are the 
%       ending/beginning of the first/second new paths).
%
% INPUT:
% tLng          timelineNG-struct that will be changed
% pm            pathmatrix
% am            adjacency-matrix
% pathNumber    pathnumber of the selected path (in the GUI)
% frameNr       the current selected frame (in the GUI)
%
% OUTPUT:
% tLng          timelineNG-struct after changes
% pm            pathmatrix
% am            adjacency-matrix
%
% See also GETNODEINFO.
%
% Copyright M.B. 01.2010
%

path = pm{pathNumber,3};
if size(path,1)>1
    %the path is not only the single cell
    if frameNr == path(1,1)
        %the cell is the first cell in the path
        %we need to change the pm...
        pm{pathNumber,3} = pm{pathNumber,3}(2:end,:);
        pm{pathNumber,1} = pm{pathNumber,1}+1;
        %status
        pathStatus = dec2bin(pm{pathNumber,4},11);
        %no beginning-flag
        pathStatus(4) = '0';
        pathStatus(9) = '0';
        pm{pathNumber,4} = bin2dec(pathStatus);
        %...and the am
        [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,pathNumber);
        for i = 1:size(cNIn,1)
            am(cNIn(i,1),pathNumber) = 0;
            am(pathNumber,cNIn(i,1)) = 0;
        end
        disp('The cell is at the beginning of the path. Path is now one cell shorter.');
    elseif frameNr == path(end,1)
        %the cell is the last cell in the path
        %we need to change the pm...
        pm{pathNumber,3} = pm{pathNumber,3}(1:end-1,:);
        pm{pathNumber,2} = pm{pathNumber,2}-1;
        %status
        pathStatus = dec2bin(pm{pathNumber,4},11);
        %no ending-flag aso.
        pathStatus(5) = '0';
        pathStatus(7) = '0';
        pathStatus(8) = '0';
        pathStatus(10) = '0';
        pm{pathNumber,4} = bin2dec(pathStatus);
        %...and the am
        [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,pathNumber);
        for i = 1:size(cNOut,1)
            am(cNOut(i,1),pathNumber) = 0;
            am(pathNumber,cNOut(i,1)) = 0;
        end
        disp('The cell is at the end of the path. Path is now one cell shorter.');
    else
        %the cell is in the middle of the path
        %we need the index of the cell
        index = find(frameNr==path(:,1));
        path1 = path(1:index-1,:);
        path2 = path(index+1:end,:);
        %change the old path in the pm...
        pm{pathNumber,2} = frameNr-1;
        pm{pathNumber,3} = path1;
        %the status for path1 is checked and corrected
        statusPath1 = dec2bin(pm{pathNumber,4},11);
        statusPath1(5) = '0';
        statusPath1(7) = '0';
        statusPath1(8) = '0';
        statusPath1(10) = '0';
        pm{pathNumber,4} = bin2dec(statusPath1);
        %...and the am
        [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,pathNumber);
        for i = 1:size(cNOut,1)
            am(cNOut(i,1),pathNumber) = 0;
            am(pathNumber,cNOut(i,1)) = 0;
        end
        
        %insert the new path in the pm...
        pm{end+1,1} = frameNr+1;
        pm{end,2} = path(end,1);
        pm{end,3} = path2;
        %the status for path2 is checked and corrected
        statusPath2 = dec2bin(pm{pathNumber,4},11);
        statusPath2(4) = '0';
        pm{end,4} = bin2dec(statusPath2);
        %...and the am
        am(end+1,:) = 0;
        am(:,end+1) = 0;
        pathNumber2 = length(am);
        for i = 1:size(cNOut,1)
            %new entries (from the old path) in the newly added row and colum
            am(cNOut(i,1),pathNumber2) = cNOut(i,2);
            am(pathNumber2,cNOut(i,1)) = cNOut(i,3);
        end
        %set the pathnumber of the new path for all its cells in the tLng
        for iCell = 1:size(path2,1)
            pathCellNr = path2(iCell,2);
            pathFrameNr = path2(iCell,1);
            tLng.cell(pathFrameNr).status(pathCellNr) = pathNumber2;
        end
        disp('The cell is in the middle of the path. Path is cut into two.');
    end
else
    %the path is just one single cell
     % we "reset" the path in the pathmatrix
     for i=1:4
         pm{pathNumber,i} = [];
     end
     %we "reset" the path in the the am
     am(pathNumber,:) = zeros(length(am),1);
     am(:,pathNumber) = zeros(length(am),1)';
    disp('The path has the length 1. Just remove the cell and everything is okay.');
end