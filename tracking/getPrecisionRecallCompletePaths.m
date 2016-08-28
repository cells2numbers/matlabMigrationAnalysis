function [PRE,REC,ACU,completeList,correctList] = getPrecisionRecallCompletePaths(tLngRef,amRef,pmRef,tLngTest,amTest,pmTest,mList,NPATH,minPathOverlap)
%
%
%
%
%

 if ~exist('minPathOverlap','var')
    minPathOverlap = 6;
end

VERBOSE = 1;
 
 % first we reset all mitosis flags
 mitosis = evaluatePathStatus(pmTest,2);
 if ~isempty(mitosis)
     for i=1:length(mitosis)
         
         [pmTest,tLngTest,newStatus] = setPathStatus(tLngTest,pmTest,mitosis(i),'mitosis',0);
     end
 end
 
 % check if all mitosis are delted
 mitosis = evaluatePathStatus(pmTest,2);
 
 %%

 
 if ~isempty(mList)
     for i=1:length(mList)
         [pmTest,tLngTest,newStatus] = setPathStatus(tLngTest,pmTest,mList(i),'mitosis',1);
     end
 end
 
 %%
 
 [completeList,correctList] = evaluateCompletePaths(tLngRef,amRef,pmRef,tLngTest,amTest,pmTest,minPathOverlap);
 compLength = length(completeList);
 corLength = length(correctList);
  
 %
 TP = corLength;
 FP = compLength - corLength;
 FN = NPATH - corLength;
 
 PRE = TP / ( TP + FP);
 REC = TP / ( TP + FN);
 ACU = TP / ( TP + FP + FN);
 
 if VERBOSE 
     fprintf('results as number of paths: \n');
     fprintf('\t TP: %i \n',TP);
     fprintf('\t FP: %i \n',FP);
     fprintf('\t FN: %i \n',FN);
     fprintf('results as precision / recall: \n');
     fprintf('\t precision: %3.2f \n',PRE);
     fprintf('\t recall: %3.2f \n',REC);
 end
 