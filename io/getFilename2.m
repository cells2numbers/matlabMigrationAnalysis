function fname=getFilename2(imInfos, i)
% function fname=getFilename(imInfos, i)
% 
% returns a filename with number i as image number
% filename according to imInfos-specification
%
% returns empty set if file does not exist

imageNumber = ['%0' num2str(length(imInfos.number)) 'd'];
fname = [imInfos.path imInfos.first sprintf(imageNumber,i) '.' imInfos.type];
