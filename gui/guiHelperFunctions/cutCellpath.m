function [tLng,am,pm] = cutCellpath(tLng,am,pm,cutPath,frameNr)
% cutPath cuts one path in two at the current frame
%
% [tLng,am,pm] = cutPath(tLng,am,pm,cutPath,frameNr)
%
% the second path begins with the current selected frame and will be added
% at the end of the pathmatrix (pm).
% The old path will shrink.
%
% INPUT:
% tLng      timelineNG-struct that will be changed
% am        adjacency-matrix
% pm        pathmatrix
% cutPath   pathnumber of the selected path (in the GUI)
% frameNr   the current selected frame (in the GUI)
%
% OUTPUT:
% tLng      timelineNG-struct after changes
% am        adjacency-matrix
% pm        pathmatrix
%
% See also GETNODEINFO.
%
% Copyright M.B. 01.2010
%


% we get the cellpath
cpath = pm{cutPath,3};

% we cut it if the frameNumber is in the path
if cpath(1,1) < frameNr && frameNr <= cpath(end,1)
    index = find(frameNr==cpath(:,1));
    cpath1 = cpath(1:index-1,:);
    cpath2 = cpath(index:end,:);
    
    %insert the new path in the pm
    pm{cutPath,2} = frameNr-1;
    pm{cutPath,3} = cpath1;
    %the status for path1 is checked and corrected
    statusPath1 = dec2bin(pm{cutPath,4},11);
    statusPath1(5) = '0';
    statusPath1(7) = '0';
    statusPath1(8) = '0';
    statusPath1(10) = '0';
    pm{cutPath,4} = bin2dec(statusPath1);
    
    %insert the new path in the pm...
    pm{end+1,1} = frameNr;
    pm{end,2} = cpath(end,1);
    pm{end,3} = cpath2;
    %the status for path2 is checked and corrected
    statusPath2 = dec2bin(pm{cutPath,4},11);
    statusPath2(4) = '0';
    statusPath2(9) = '0';
    pm{end,4} = bin2dec(statusPath2);
    
    %...and the am
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,cutPath);
    
    am(end+1,:) = 0;
    am(:,end+1) = 0;
    path2 = length(am);
    
    if dOut >0
    for i = 1:size(cNOut,1)
        %new entries (from the old path) in the newly added row and colum
        am(cNOut(i,1),path2) = cNOut(i,2);
        am(path2,cNOut(i,1)) = cNOut(i,3);
        %now we must delete the old entry
        am(cNOut(i,1),cutPath) = 0;
        am(cutPath,cNOut(i,1)) = 0;
    end
    end
    
    %at last we add the connection between the two new path
    %we take the two cells from which we need the overlap
    cell1 = cpath1(end,2);
    cell2 = cpath2(1,2);
    %search the overlap in the tLng
    overlap1 = tLng.cell(frameNr-1).successor{cell1};
    overlap2 = tLng.cell(frameNr).predecessor{cell2};
%     
%     % we correct empty overlap 
%     if overlap1 == 0
%         overlap1 = 1;
%     end
%    
%      if overlap2 == 0
%         overlap2 = 1;
%      end
%     
    %insert the overlap in the am
    am(cutPath,path2) = overlap1(1,2);
    am(path2,cutPath) = -overlap2(1,2);
    %set the pathnumber of the new path for all its cells in the tLng
    for iCell = 1:size(cpath2,1)
        pathCellNr = cpath2(iCell,2);
        pathFrameNr = cpath2(iCell,1);
        tLng.cell(pathFrameNr).status(pathCellNr) = path2;
    end
else
    error('The frame number is outside of the path!');
end






