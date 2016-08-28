function[tLngNew] = addEmptyFrame(tLngNew)
%
%
%
%
%
%

newFrameID = length(tLngNew.cell) + 1;

tLngNew.time = newFrameID;

tLngNew.cell(newFrameID).number = 0;

tLngNew.cell(newFrameID).predecessor = {};
tLngNew.cell(newFrameID).successor = {};