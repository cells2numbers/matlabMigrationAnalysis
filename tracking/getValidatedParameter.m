function [data] = getValidatedParameter(tLng,pm,fm,pathlength,timeWindow,varargin)
% function to extract parameters from valid paths only 
%
%   [data] = getValidParameter(tLng,pm,fm,pathlength,timeWindow,varargin)
%
%  this function uses a simple validation process to only return valid 
%  cell paths for further evaluation. 
%
%
%  data.list          all valid paths, size 1xN wiht N validated paths
%  
%                     the following entries are cell arrays
%
%  data.pathList      all valid paths per frame size 1xM with M frames
%  data.cellList      all cells belonging to the paths from this frame
%  
%                    
%                     the next variables store the morpho. feature for 
%                     all cells belonging to a valid path in each frame
%
%  data.area          size 1xM with M frames 
%  data.brightness    size 1xM with M frames
%  data.length        size 1xM with M frames
%  data.compactness   size 1xM with M frames
%  data.orientation   size 1xM with M frames
%  data.speed         size 1xM with M frames
%
%  data.mean
%
%  data.limMax;
%  data.limMin;
% 
%
%
% Example 
%
% load manualTrackTLng;
% data = getValidatedParameter(tLng,pm,fm)
%
% data = 
% 
%            list: {1x209 cell}
%        pathList: {1x209 cell}
%        cellList: {1x209 cell}
%            area: {1x209 cell}
%      brigthness: {1x209 cell}
%          length: {1x209 cell}
%     compactness: {1x209 cell}
%     orientation: {1x209 cell}
%          limMax: [753 254.8750 90.9723 8.3207 8.3207]
%          limMin: [45 116.0392 8.0538 0 0.8861]
% 
% 03.2012 tb

if ~exist('pathlength','var')
    pathlength = 5;
end

if ~exist('timeWindow','var')
    timeWindow = 5;
end


% extract save / validated paths, the min. path length is set to the 
% timeWindow for speed calculation
data.list = getValidPath(pm,'length',pathlength);



%% create and fill data structure

% list with all paths belonging to one frame
data.pathList = cell(1,tLng.time_max);
data.cellList = cell(1,tLng.time_max);


% for each path, all frames / timepoints are remembered in data.list 
for iPath = data.list
    % each frame in that the current path appears is stored 
    % in data.list
    for iFrame = pm{iPath,1} :  pm{iPath,2}
        % we store the path number
        data.pathList{iFrame}(end+1) = iPath;
        % we store the cell number
        data.cellList{iFrame}(end+1) = pm{iPath,3}(iFrame -pm{iPath,1}+1,2);
    end
end

%%
% cell proliferation as growthcurve
data.growthcurve = [tLng.cell(:).number];

% for each path, we store the area / size, compactness, length, brightness
data.area =  cell(1,tLng.time_max);
data.brigthness =  cell(1,tLng.time_max);
data.length = cell(1,tLng.time_max);
data.compactness = cell(1,tLng.time_max);
data.orientation = cell(1,tLng.time_max);

% difference values
data.darea =  cell(1,tLng.time_max);
data.dbrigthness =  cell(1,tLng.time_max);
data.dlength = cell(1,tLng.time_max);
data.dcompactness = cell(1,tLng.time_max);
data.dorientation = cell(1,tLng.time_max);


data.speed = cell(1,tLng.time_max);
data.migration = cell(1,tLng.time_max);
% for initial values, we set the first values for 
% area, brightness, length and compactness
data.limMax =  [fm{1}(1,3:7),0,0];
data.limMin =  [fm{1}(1,3:7),inf,inf];

data.dlimMax =  [0 0 0 0 0 0 0];
data.dlimMin =  [inf inf inf inf inf inf inf ];
% we extract size / length... for each 
%
% format of the feature matrix: 
%        1  x-pos
%        2  y-pos
%        3  size
%        4  brightness
%        5  max length
%        6  compactness
%        7  orientation 


% the mean / std for each feature is stored 
data.mean = zeros(tLng.time_max,7);
data.std = zeros(tLng.time_max,7);

data.dmean = zeros(tLng.time_max,7);
data.dstd = zeros(tLng.time_max,7);

for iFrame = 1:tLng.time_max
    % get are parameter with min / max limits
    % !! for parloop, aList has be removed and we need to call fm twice
    
    
    
    aList =fm{iFrame}(data.cellList{iFrame},3);
    data.area{iFrame} = aList;
    % get global min / max values (needed for axis / limits /  plotting )
    data.limMax(1) = max( [data.limMax(1); aList(:)]);
    
    data.limMin(1) = min( [data.limMin(1); aList(:)]);
    data.mean(iFrame,1) = mean(aList);
    data.std(iFrame,1) = std(aList);
    
    
    
    % same for brightness
    bList =  fm{iFrame}(data.cellList{iFrame},4);
    data.brigthness{iFrame} = bList;
    data.limMax(2) = max( [data.limMax(2);bList(:)]);
    data.limMin(2) = min( [data.limMin(2);bList(:)]);
    data.mean(iFrame,2) = mean(bList);
    data.std(iFrame,2) = std(bList);
    
    % length
    lList = fm{iFrame}(data.cellList{iFrame},5);
    data.length{iFrame} = lList;
    data.limMax(3) = max( [data.limMax(3); lList(:)]);
    data.limMin(3) = min( [data.limMin(3); lList(:)]);
    data.mean(iFrame,3) = mean(lList);
    data.std(iFrame,3) = std(lList);
    
    % compactness
    cList = fm{iFrame}(data.cellList{iFrame},6);
    data.compactness{iFrame} = cList;
    data.limMax(4) = max( [data.limMax(4); cList(:)]);
    data.limMin(4) = min( [data.limMin(4); cList(:)]);
    data.mean(iFrame,4) = mean(cList);
    data.std(iFrame,4) = std(cList);
    
    % orientation between [-90 90 ] is scaled to [ 0 180 ]
    oList = fm{iFrame}(data.cellList{iFrame},7) + 90;
    data.orientation{iFrame} = oList;
    data.limMax(5) = max( [data.limMax(5); oList(:)]);
    data.limMin(5) = min( [data.limMax(5); oList(:)]);
    data.mean(iFrame,5) = mean(oList);
    data.std(iFrame,5) = std(oList);
end


 %% calculation of cell speed as MSD for N frames, N=timeWindow
 

 for iPath=data.list
     [speed,migration,frames] = getCellSpeed(tLng,pm,iPath,timeWindow);
     data.limMax(6) = max( [ data.limMax(6);speed(:)]);
     data.limMin(6) = min( [ data.limMin(6);speed(:)]);
     
     data.limMax(7) = max( [ data.limMax(7); migration(:)]);
     data.limMin(7) = min( [ data.limMin(7); migration(:)]);
     
     for iFrame = 1:length(frames)
         data.speed{frames(iFrame)}(end+1) = speed(iFrame);
         data.migration{frames(iFrame)}(end+1) = migration(iFrame);
     end
 end
 
 % calculate mean / std for speed and migration
 for iFrame = 1:tLng.time_max
     % speed 
     
     nonZero = find(data.speed{iFrame} ~= 0);
     
     data.mean(iFrame,6) = mean(data.speed{iFrame}(nonZero) );
     data.std(iFrame,6) = std( data.speed{iFrame}(nonZero)  );
     % migration
     data.mean(iFrame,7) = mean(data.migration{iFrame}(nonZero)  );
     data.std(iFrame,7) = std( data.migration{iFrame}(nonZero)  );
 end

 
 %%  add calculation for feature path difference 
 
 for iPath=data.list
       [featureVektor,diffTimes] = getFeaturePathDiff(pm,fm,iPath);
       % we add a zero row to fill up missing parameters
       % (we have on number(cells) -1 difference values, that sucks)
       featureVektor = [zeros(1,7);featureVektor];
       % and we need to add the time 
       diffTimes  = [diffTimes(1)-1,diffTimes];
       for iFrame = 1:length(diffTimes)
           data.darea{diffTimes(iFrame)} =  [data.darea{diffTimes(iFrame)};featureVektor(iFrame,3)];
           data.dlimMax(1) = max( [data.dlimMax(1); featureVektor(iFrame,3)]);
           data.dlimMin(1) = min( [data.dlimMin(1); featureVektor(iFrame,3)]);
           
           data.dbrigthness{diffTimes(iFrame)} = [data.dbrigthness{diffTimes(iFrame)};featureVektor(iFrame,4)];
           data.dlimMax(2) = max( [data.dlimMax(2); featureVektor(iFrame,4)]);
           data.dlimMin(2) = min( [data.dlimMin(2); featureVektor(iFrame,4)]);
           
           data.dlength{diffTimes(iFrame)} = [data.dlength{diffTimes(iFrame)};featureVektor(iFrame,5)];
           data.dlimMax(3) = max( [data.dlimMax(3); featureVektor(iFrame,5)]);
           data.dlimMin(3) = min( [data.dlimMin(3); featureVektor(iFrame,5)]);
           
           data.dcompactness{diffTimes(iFrame)} = [data.dcompactness{diffTimes(iFrame)};featureVektor(iFrame,6)];
           data.dlimMax(4) = max( [data.dlimMax(4); featureVektor(iFrame,6)]);
           data.dlimMin(4) = min( [data.dlimMin(4); featureVektor(iFrame,6)]);
           
           data.dorientation{diffTimes(iFrame)} = [data.dorientation{diffTimes(iFrame)};featureVektor(iFrame,7)];
           data.dlimMax(5) = max( [data.dlimMax(5); featureVektor(iFrame,7)]);
           data.dlimMin(5) = min( [data.dlimMin(5); featureVektor(iFrame,7)]);   
           
       end
 end
 

 %% calculation of mean values for the feature differences

 for iFrame = 1:tLng.time_max
    % area
    data.dmean(iFrame,1) = mean(data.darea{iFrame} );
    data.dstd(iFrame,1) = std( data.darea{iFrame} );
    
    % brightness
    data.dmean(iFrame,2) = mean(data.dbrigthness{iFrame} );
    data.dstd(iFrame,2) = std( data.dbrigthness{iFrame} );
    
    % length
    data.dmean(iFrame,3) = mean(data.dlength{iFrame} );
    data.dstd(iFrame,3) = std( data.dlength{iFrame} );
    
    % compactness
    data.dmean(iFrame,4) = mean(data.dcompactness{iFrame} );
    data.dstd(iFrame,4) = std( data.dcompactness{iFrame} );
    
    % orientation
    data.dmean(iFrame,5) = mean(data.dorientation{iFrame} );
    data.dstd(iFrame,5) = std( data.dorientation{iFrame} );
end
 