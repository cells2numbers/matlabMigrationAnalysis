function fm = correctFM(tLng,fm,imInfos,frameNr,cellnumber)
%function for feature-matrix correction
%
% fm = correctFM(tLng,fm,imInfos,frameNr,cellnumber)
%
% INPUT:
% tLng          timelineNG struct
% fm            the feature-matrix
% imInfos       imInfos (image informations struct)
% frameNr       the current number of the frame that should be corrected
% cellnumber    the cellnumber of the cell that should be corrected        
%
% OUTPUT:
% fm            the corrected feature-matrix
%
% Copyright M.B. 03.2010
%

I = imread(getFilename2(imInfos,frameNr));
cellmask = imageTimelineNG(tLng,frameNr);

maskProp =  regionprops(cellmask,'Area','Centroid','Perimeter',...
    'Orientation','EquivDiameter','MajorAxisLength');
f_vector = zeros(1,7);
% mean brightness of each cell
f_bright = mean(I(tLng.cell(frameNr).cells{cellnumber}));

f_vector(cellnumber,:) = ...
    [maskProp(cellnumber).Centroid(end:-1:1), ...
    maskProp(cellnumber).Area, ...
    f_bright, ...
    maskProp(cellnumber).MajorAxisLength,...
    (maskProp(cellnumber).Perimeter /...
    (maskProp(cellnumber).EquivDiameter*pi))^2,...
    maskProp(cellnumber).Orientation];
%not very nice...
fm{frameNr}(cellnumber,1) =  f_vector(1);
fm{frameNr}(cellnumber,2) =  f_vector(2);
fm{frameNr}(cellnumber,3) =  f_vector(3);
fm{frameNr}(cellnumber,4) =  f_vector(4);
fm{frameNr}(cellnumber,5) =  f_vector(5);
fm{frameNr}(cellnumber,6) =  f_vector(6);
fm{frameNr}(cellnumber,7) =  f_vector(7);