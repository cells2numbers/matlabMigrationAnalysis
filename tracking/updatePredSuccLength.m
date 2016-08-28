function[tLngNew] = updatePredSuccLength(tLngNew)
%
%
%

for iFrame = 1:tLngNew.time_max
    
    cellNumber = tLngNew.cell(iFrame).number;
    
    maxInd = max(cellNumber, length(tLngNew.cell(iFrame).status));
    
    if size(tLngNew.cell(iFrame).predecessor,2) < maxInd
        tLngNew.cell(iFrame).predecessor{maxInd} = [];
    end
   
    if size(tLngNew.cell(iFrame).successor,2) < maxInd
        tLngNew.cell(iFrame).successor{maxInd} = [];
    end
   
    
end