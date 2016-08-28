function[mu,sigma] = getMuSigma(tLng, am,pm,fm,varargin)
%  = getMuSigma uses safe paths to estimate mu and sigma
%
%
%   [mu,sigma] = getMuSigma(tLng, am,pm,fm,varargin)
% 
%
%  optional arguments: see getSafePath, ( all optional 
%  arguments are passed to getSafePath(tLng,am,pm)
%       
% tb oct 2009
%

% we get some safe paths
if isempty(varargin) 
    [pList,threshList] = getSafePath(tLng,am,pm);
else
    [pList,threshList] = getSafePath(tLng,am,pm,varargin{:});
end

% the plot-flag is for verbose information
PLOT =0;
 
%%
featureList = [];
fList2 = [];
for iPath=1:length(pList)
    pathNr = pList(iPath);
    cpath = pm{pathNr,3};

    for iFrame=1:pm{pathNr,2}-pm{pathNr,1}
        % we got a problem if we have a missing cell 
        if size(cpath,1) >= (iFrame+1)
            tFeat =  getFeatureDiff(fm,cpath(iFrame,:),cpath(iFrame+1,:));
            featureList =  [featureList;tFeat];
            fList2 = [fList2;fm{cpath(iFrame,1)}(cpath(iFrame,2),:)];
        end
    end
    if ~mod(iPath,500)
    	%fprintf('features calculated for frame %i from %i \n',iPath,length(pList));
        fprintf('.');
    end
end
%%

titletext = {'x-pos','y-pos','size','brightness','length','compactness'};

if PLOT
    for i=1:6
        subplot(3,2,i);
        hist(featureList(:,i),50);
        title(titletext{i});
    end
    figure();
    for i=1:6
        subplot(3,2,i);
        hist(fList2(:,i),50);
        title(titletext{i});
    end
    
end

if size(featureList,1) > 0
    featureList = featureList( find(featureList(:,6)~=inf),:);
    featureList = featureList( find(featureList(:,6)~=NaN),:);
end

sigma = cov(featureList);
mu = mean(featureList);
 
