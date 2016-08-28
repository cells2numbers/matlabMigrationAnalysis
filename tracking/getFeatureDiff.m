function featureVector =  getFeatureDiff(fm,cell1,cell2)
% getFeatureDiff calculates the feature-diff. in percent
% 
%  featureVector =  getFeatureDiff(fm,cell1,cell2)
%
%  where cell1/cell2 = [frameNr, pathNr] 
%
%
% tim becker

featureVector = fm{cell2(1)}(cell2(2),:) - fm{cell1(1)}(cell1(2),:);


%
ind1 = find(featureVector(:,7) < -90);
ind2 = find(featureVector(:,7) >= 90);

featureVector(ind1,7) = featureVector(ind1,7) + 180;
featureVector(ind2,7) = featureVector(ind2,7) - 180;

% we normalize the orientation to the interval [-1,1]
% all other values are changes in percent
featureVector = featureVector ...
    ./[fm{cell1(1)}(cell1(2),1:end-2),1,90];
