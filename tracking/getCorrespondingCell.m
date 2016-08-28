function [cellCorr,ov,ovCorr,ONECELL] = getCorrespondingCell(tLngTest,frame,cellnr,tLngRef,varargin)
% tracking-function to find a corresponding cell in a reference timeline 
%
%  [cellCorr,ov,ovCorr,ONECELL] = getCorrespondingCell(tLngTest,frame,...
%                                    cellnr,tLngRef)
%
%  
%  This function returns for a given cell and timeline the 
%  corresponding cell in a second timeline. (usefull for evaluatio).
%  As output you get the cell number (cellCorr) of the corresponding 
%  cell, two  overlaps ( the intersection of both cells divided by 
%  1) the given cell = ov
%  2) the corresponding cell = ovCorr
%
%  As fourth output you get a ONCELL flag, this flag is 1, when the 
%  given cell ovelaps only with one other cells, else it is zero.
%  
%
%  If either the given cell or the corresponding cell couldnt be found,
%  all values are returned empty.
%
%  Example: get corresponding cell and path
%
%   [cellCorr,ov,ovCorr,ONECELL] = getCorrespondingCell(tLngTest,1,...
%                                    1,tLngRef)
%
%   pathCorr = tLng.cell(1).status(cellCorr);
%  
%  Optional argument: 
%  'cellmask',cellmask        
%
%   This optional argument is very usefull when every cell in one frame 
%   has to be checked (evaluation of a timeline using reference data)
% 
%   Example:
%     mask = imageTimelineNG(tLng,1);
%      [cellCorr,ov,ovCorr,ONECELL] = getCorrespondingCell(tLngTest,1,...
%                                    1,tLngRef,'cellmask',maskCorr);
%
%
%  See also imageTimelineNG, evaluateTimeline.m, imageTimelineNG.m
%
%
% tim becker, july 2010
%

VERBOSE = 0;
cellCorr = [];
ov = [];
ovCorr = [];
ONECELL = [];
maskCorr = [];


i = 1;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'cellmask',     i=i+1; maskCorr = varargin{i};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['getCorrespondingCell.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
    end
    i = i+1;
end
    

% extract the cellmaks for the corresponding-timelines
% (needed to get the corresponding cell)
if isempty(maskCorr)
    maskCorr = imageTimelineNG(tLngRef,frame);
end

% get the index of the original cell 
indexCell = tLngTest.cell(frame).cells{cellnr};

if ~isempty(indexCell)
    % the number of the corresponding cell(s) are the labels
    % for the search-index searchInd in the mask
    indexCorr = maskCorr(indexCell);
    indexCorr = indexCorr(indexCorr ~=0 ); % delete zeros
    
    if ~isempty(indexCorr)
        % we check, if we have only one cell label in indexCorr
        ONECELL = max(indexCorr) == min(indexCorr);
        
        
        % choose the cellnr with the biggest overlap
        % (if more than one corresponding cell found)
        if ~ONECELL
            
            [cellCorr,count] = unique(indexCorr);
            % we get the number of all cellnrs
            count = [count(1),count(2:end)' - count(1:end-1)'];
            [val,ind] = max(count);
            cellCorr = cellCorr(ind);
        else
            cellCorr =  max(indexCorr);
        end
        
        
        % we calculate the intersection of both cells
        indexIntersect = indexCorr(indexCorr == cellCorr);
        
        % the overlap intersection / cellmask
        ov = length(indexIntersect) / length(indexCell);
        
        % now the intersection / cellmaskCorr
        ovCorr = length(indexIntersect) / length(tLngRef.cell(frame).cells{cellCorr});
    elseif VERBOSE
        disp('getCorrespondingCell: no corresponding cell found');
    end
else
    disp('getCorrespondingCell: no valid as input given! cant get corr. cell');
end



