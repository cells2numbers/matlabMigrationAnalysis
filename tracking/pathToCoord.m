function pmCoord = pathToCoord(tLng,pm,pathNr)
%   pathToCoord  Changes the path-info from pm to coordinates
%
%   pmCoord = pathToCoord(tLng,pm,pathNr)
% 
% Changes the path-info of any given path from [Frame, CellNr]
% into [Frame, x-coord, y-coord]
%  
%
% jaafar al-hasani  sept. 2009


% we get the path ( as stored in the path-matrix,
%                   with format [ frameNr, cellNr; ...]
path = pm{pathNr,3};
pmCoord = zeros(size(path,1),3);
for iFrame=1:size(path,1)
    frameNr =  path(iFrame,1);
    cellNr = path(iFrame,2);
    % we read the coord. out of the timeline
    newEntry = [frameNr,tLng.cell(frameNr).centroid(cellNr,:)];
    pmCoord(iFrame,:) = newEntry;
end




