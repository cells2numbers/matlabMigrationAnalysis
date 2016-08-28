function [frr,far,frrFrame,farFrame] = evaluateTimeline(tLngTest,tLngRef,OVERLAPTHRESH)
%
%  Example 
%
% fprintf('loading reference data...');
% [filename, pathname] = uigetfile;
% load([pathname filename]);
% tLngRef = tLng;
% fprintf('done!\n');
% 
% fprintf('loading test data....');
% [filename, pathname] = uigetfile;
% load([pathname filename]);
% %
% tLngTest = tLng;
% fprintf('done!\n');
% %  now the evaluation
% 
% timeMax = tLngRef.time_max;
%  
%  [frr,far,frrFrame,farFrame] = evaluateTimeline(tLngTest,tLngRef,.3)
%
% figure();
% plot(frrFrame);hold on;
% plot(farFrame,'r'); hold off;
% legend('frr','far');
% toc

%
%
%
% 05.2012 tim becker 


if ~exist('OVERLAPTHRESH','var')
    OVERLAPTHRESH = 0.3;
end

tic
[allNumberTest,correctCellsTest] = getCorrespondingCellInformation(tLngTest,tLngRef,OVERLAPTHRESH);
farFrame = 1- correctCellsTest ./ allNumberTest;
far = 1- sum(correctCellsTest) / sum(allNumberTest);

[allNumberRef,correctCellsRef] = getCorrespondingCellInformation(tLngRef,tLngTest,OVERLAPTHRESH);
frrFrame =  1- correctCellsRef ./ allNumberRef;
frr =  1- sum(correctCellsRef) / sum(allNumberRef);
fprintf('evaluation of cell detection finished \n');