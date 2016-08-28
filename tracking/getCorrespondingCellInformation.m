function [TPandFALSE,TP] = getCorrespondingCellInformation(tLngTest,tLngRef,thresh)
%
%
%
%
%
%
%
%
%
%

% number time frames
timeMax = tLngRef.time_max;

% init output variables
TPandFALSE = zeros(timeMax,1);
TP = zeros(timeMax,1);


for iFrame = 1:timeMax
    % extract the correct frame
    maskCorr = imageTimelineNG(tLngRef,iFrame);
    % extract the number of all test cells (TP + FP), i.e. all
    % cells in the test image
    TPandFALSE(iFrame) = tLngTest.cell(iFrame).number;
    % where do we find the cells in the tLng-struct?
    cellIDs = find(tLngTest.cell(iFrame).status>0);
    
    for i =1:length(cellIDs)
        iCell = cellIDs(i);
        
        [cellCorr,ov,ovCorr,ONECELL] = getCorrespondingCell(tLngTest,iFrame,...
            iCell,tLngRef,'cellmask',maskCorr);
        
        if ~isempty(ONECELL) && ONECELL && ov >= thresh && ovCorr >= thresh
            TP(iFrame)  = TP(iFrame)  +1;
        end
        
    end
    if ~mod(iFrame,20)
        %fprintf('finished frame %i \n',iFrame);
        fprintf('.');
    end
end