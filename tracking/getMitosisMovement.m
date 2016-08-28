function [r,s,d,cellRelation ] = getMitosisMovement(am,pm,fm,varargin )
%
%
%
%
%
%

% set minimal length for parent and daughter cell paths
minLengthParent = 10;
minLengthDaughter = 10;


% evaluate (optional) input arguments
i=1;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'minLengthParent',   i=i+1; minLengthParent = varargin{i};
            case 'minLengthDaughter', i=i+1; minLengthDaughter = varargin{i};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    
    if ~argok,
        disp(['getMitosisMovement.m : WARNING! Ignoring invalid argument #' num2str(i)]);
    end
    i = i+1;
end


pathflag.lostBegin = evaluatePathStatus(pm,256);
pathflag.lostEnd = evaluatePathStatus(pm,512);
pathflag.borderBegin = evaluatePathStatus(pm,4);
pathflag.boderEnd = evaluatePathStatus(pm,8);
pathflag.coupled = evaluatePathStatus(pm,1024);
pathflag.begin =  evaluatePathStatus(pm,128);
pathflag.mitosis =  evaluatePathStatus(pm,2);
pathflag.path =  evaluatePathStatus(pm,1);


%%



% init ouput var
cellRelation = [];
pathLength = [];

for i=1:length(pathflag.mitosis)
    iPath = pathflag.mitosis(i);
    
    % path length = cell cycle time of parent path
    pLength = size(pm{iPath,3},1);
    
    % find daughter cells
    idx =  find(am(iPath,:) > 0);
    
    % have we two daughter cells?
    for k=1:length(idx)
        dLength(k) = size(pm{idx(k),3},1);
    end
        
    if length(idx) == 2
        cellRelation(end+1,:) = [iPath,idx];
        pathLength(end+1,:) = [pLength,dLength];
    end 

end

%% find all paths with a length > given length
idxLengthOK = find(pathLength(:,1) > minLengthParent &...
    pathLength(:,2) > minLengthDaughter & ...
    pathLength(:,3) > minLengthDaughter);

cellRelation = cellRelation(idxLengthOK,:);
pathLength = pathLength(idxLengthOK,:);

%%


%     The following features are calculated:
%  
%     1.  x-position 
%     2.  y-position 
%     3.  area          as sum of pixels 
%     4.  brightness    mean brigthness of the cell area in the raw image
%     5.  length        of the major axis
%     6.  compactness   as (4 pi Area) / Perimeter^2 
%     7.  orientation   between -90 and 90

features = cell(3,size(pathLength,1));

% return the minLengthParent last features 
for i=1:size(cellRelation,1)
    iPath = cellRelation(i,1);
    features{1,i} = getCellPathFeature(pm,fm,iPath,0,minLengthParent);
end

% return the  minLengthDaughter first features
for i=1:size(cellRelation,1)
    iPath1 = cellRelation(i,2);
    iPath2 = cellRelation(i,3);
    features{2,i} = getCellPathFeature(pm,fm,iPath1,1,minLengthDaughter);
    features{3,i} = getCellPathFeature(pm,fm,iPath2,1,minLengthDaughter);
end

%% 
s = cell(size(features));
r = s;
d = s;
for j=1:3 % 1=mother, 2,3= daughters
    for i=1:size(features,2)
        diff = features{j,i}(2:end,1:2) - features{j,i}(1:(end-1),1:2);
        d{j,i} = diff;
        % distance and direction
        r{j,i} =  features{j,i}(end,1:2) - features{j,i}(1,1:2);
        % velocity 
        s{j,i} = sqrt(sum(diff.^2,2));
    end
end


end

