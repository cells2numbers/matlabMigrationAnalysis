function [NnumberOffCells,confluency] = countCells(BW)
%  [number_of_cells,confluency] = countCells(BW)
%
% function to calculate the confluency and the number of cells in a given 
% binary image. 
%
% Input
%    BW               binary image
%
%  Output
%    numberOfCells    number of cells
%    confluency       confluency measurd as area(foreground) / area(image)
% TB

% remove border artefacts
BW = imclearborder(BW);

[~, NnumberOffCells] = bwlabel(BW);

confluency=  length(find(BW)) / numel(BW); 
