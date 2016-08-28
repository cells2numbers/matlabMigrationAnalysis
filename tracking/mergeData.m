function data = mergeData(dataIn)
%  data = mergeData(dataIn)
%  
%  function to merge several timelines belonging to one experiment
%  i.e. each timeline represents a different position
%   
%
%  Example 
%
%  dataPos1 = getValidatedParameter(tLng1,pm1,fm1);
%  dataPos2 = getValidatedParameter(tLng2,pm2,fm2);
%
%  data = mergeData({dataPos1,dataPos2});
%
%
% 3.2012 tb

% number of timelines to be merged and
% max. frames in each timeline
N = length(dataIn);
frameMax = size(dataIn{1}.mean,1);


% we initialize the data struct
data.list = {1,N};
data.pathList = {1,N};
data.cellList = {1,N};
data.growthcurve = ones(N,frameMax);

data.area = cell(1,frameMax);
data.brigthness = cell(1,frameMax);
data.length = cell(1,frameMax);
data.compactness = cell(1,frameMax);
data.orientation = cell(1,frameMax);

data.darea = cell(1,frameMax);
data.dbrigthness = cell(1,frameMax);
data.dlength = cell(1,frameMax);
data.dcompactness = cell(1,frameMax);
data.dorientation = cell(1,frameMax);


data.speed = cell(1,frameMax);
data.migration = cell(1,frameMax);


data.limMax = zeros(N,7);
data.limMin = ones(N,7) * inf;

data.dlimMax = zeros(N,7);
data.dlimMin = ones(N,7) * inf;


% for each timeline, all data is collected in the new data-struct
for iData=1:length(dataIn)
    D = dataIn{iData};
    % each list is stored separately
    data.list{iData} = D.list;
    data.pathList{iData} = D.pathList;
    data.cellList{iData} = D.cellList;
    
    % first, all data of the growthcurves and the 
    % limits are stored
    data.growthcurve(iData,:) = D.growthcurve;
    data.limMax(iData,:) = D.limMax;
    data.limMin(iData,:) = D.limMin;
    
    data.dlimMax(iData,:) = D.dlimMax;
    data.dlimMin(iData,:) = D.dlimMin;
    %
    % all morph. parameters are collected in the data-struct
    for iFrame = 1:frameMax
        data.area{iFrame} = [data.area{iFrame}; D.area{iFrame}];
        data.brigthness{iFrame} = [data.brigthness{iFrame}; D.brigthness{iFrame}];
        data.length{iFrame} = [data.length{iFrame}; D.length{iFrame}];
        data.compactness{iFrame} = [data.compactness{iFrame}; D.compactness{iFrame}];
        data.orientation{iFrame} = [data.orientation{iFrame}; D.orientation{iFrame}];
       
        data.darea{iFrame} = [data.darea{iFrame}; D.darea{iFrame}];
        data.dbrigthness{iFrame} = [data.dbrigthness{iFrame}; D.dbrigthness{iFrame}];
        data.dlength{iFrame} = [data.dlength{iFrame}; D.dlength{iFrame}];
        data.dcompactness{iFrame} = [data.dcompactness{iFrame}; D.dcompactness{iFrame}];
        data.dorientation{iFrame} = [data.dorientation{iFrame}; D.dorientation{iFrame}];
          
        data.speed{iFrame} = [data.speed{iFrame}  D.speed{iFrame}];
        data.migration{iFrame} = [data.migration{iFrame}  D.migration{iFrame}];
    end
end

% update mean / std values and limits

for iFrame = 1:frameMax
    % area
    data.mean(iFrame,1) = mean(data.area{iFrame} );
    data.std(iFrame,1) = std( data.area{iFrame} );
    
    data.dmean(iFrame,1) = mean(data.darea{iFrame} );
    data.dstd(iFrame,1) = std( data.darea{iFrame} );
    
    % brightness
    data.mean(iFrame,2) = mean(data.brigthness{iFrame} );
    data.std(iFrame,2) = std( data.brigthness{iFrame} );
    
    data.dmean(iFrame,2) = mean(data.dbrigthness{iFrame} );
    data.dstd(iFrame,2) = std( data.dbrigthness{iFrame} );
    
    % length
    data.mean(iFrame,3) = mean(data.length{iFrame} );
    data.std(iFrame,3) = std( data.length{iFrame} );
    
    data.dmean(iFrame,3) = mean(data.dlength{iFrame} );
    data.dstd(iFrame,3) = std( data.dlength{iFrame} );
    
    % compactness
    data.mean(iFrame,4) = mean(data.compactness{iFrame} );
    data.std(iFrame,4) = std( data.compactness{iFrame} );
    
    data.dmean(iFrame,4) = mean(data.dcompactness{iFrame} );
    data.dstd(iFrame,4) = std( data.dcompactness{iFrame} );
    
    % orientation
    data.mean(iFrame,5) = mean(data.orientation{iFrame} );
    data.std(iFrame,5) = std( data.orientation{iFrame} );
    
    data.dmean(iFrame,5) = mean(data.dorientation{iFrame} );
    data.dstd(iFrame,5) = std( data.dorientation{iFrame} );
    
    % speed
    data.mean(iFrame,6) = mean(data.speed{iFrame} );
    data.std(iFrame,6) = std( data.speed{iFrame} );
    
    % migration
    data.mean(iFrame,7) = mean(data.migration{iFrame} );
    data.std(iFrame,7) = std( data.migration{iFrame} );
end

% the growthcurve is calculated as the mean growthcurve over all positions
data.growthcurve =  mean(data.growthcurve);

% get the min / max values 

if  size(data.limMax,1) > 1
data.limMax = max(data.limMax);
data.limMin = min(data.limMin);

data.dlimMax = max(data.dlimMax);
data.dlimMin = min(data.dlimMin);
end
