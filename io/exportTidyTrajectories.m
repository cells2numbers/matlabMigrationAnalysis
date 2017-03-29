function[tidyFeature] = exportTidyTrajectories(pm,fm,trajectoryList)
% Export cell information as tidy list
% 
% exportedFeatures = exportTracks(pm,fm,trajectoryList)
%
% Export all cellular information in a tidy form in which 
% each row represents a cell. The description is extracted using the 
% feature matrix fm. 
%
% A subset of of trajectories can be selected using the optional variable 
% trajectoryList
%
% Input:
%   pm              path matrix
%   fm              feature matrix, cell array with size frames x 1
%                   Entry n of fm stores all features of the cells in 
%                   image n as matrix with size cellnumber x 7
% 
% Optional:
%   trajetoryList   subset of trajectories that is used for export.
%                   default: all trajectories are selected for export. 
%
% Output:
%   
%   tidyFeature     matrix of size mx10, where N is the sum off all cells 
%                   in all images. each row reprents a cell, the columns 
%                   store the following feature 
% 
%                     1. frameID 
%                     2. cellID 
%                     3. trajectoryID
%                     4. x-position 
%                     5. y-position 
%                     6. area           
%                     7. brightness    
%                     8. length        
%                     9. compactness    
%                     10. orientation   
%                     11. Experimentname 
%
%  See also correctFM, performBatchCSVExport,performCSVExport
%
% T.B. 03.2017


if ~exist('trajectoryList','var') 
    trajectoryList = 1:size(fm,1);
end

tidyFeature = [];

for iTrajectoryList = 1:length(trajectoryList)
    trajectoryNr = trajectoryList(iTrajectoryList);
    trajectoryCoordinates = pm{trajectoryNr,3};
    
    for iCoord = 1:size(trajectoryCoordinates, 1)
        frameNr = trajectoryCoordinates(iCoord, 1);
        cellNr = trajectoryCoordinates(iCoord, 2);
        feature = [frameNr,cellNr,trajectoryNr,fm{frameNr}(cellNr,:)];
        tidyFeature(end+1,:) = feature;
    end
end
% 'frameID','cellID','trajectoryID',