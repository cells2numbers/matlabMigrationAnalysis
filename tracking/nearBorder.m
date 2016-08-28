function BORDER = nearBorder(tLng,time,cellNr,varargin)
% nearBorder checks if a cell is near the image-border 
%
%  BORDER = nearBorder(tLng,time,cellNr,distance)
%
%   Optional Arguments:
%  
%   distance   double
%
%   distance has a default value of 20;
%
%
%  Example 
%
%  BORDER = nearBorder(tLng,1,1)
%
%  BORDER =  nearBorder(tLng,1,1,10)
%  
% tim becker 06.2009 


if isempty(varargin)
    distance = 10;
else
    distance = varargin{1};
end

% we need the size of the image for x and y coordinates
maxY = tLng.image_size(1);
maxX = tLng.image_size(2);

% we get the cell position
cellPosY = tLng.cell(time).centroid(cellNr,1);
cellPosX = tLng.cell(time).centroid(cellNr,2);

% we calculate the min. distance from border
distY = min( cellPosY, maxY - cellPosY+1);
distX = min( cellPosX, maxX - cellPosX+1);

% we check the distance
if  (distX < distance) || (distY < distance)
    BORDER = 1;
else
    BORDER = 0;
end