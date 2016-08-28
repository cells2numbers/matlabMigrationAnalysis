function[tLng,am,pm] = connectLostEndsLostBeginsSpatial(tLng,am,pm,radius,verbose)
%
% Connect path fragments spatially;
% For path fragments with lost ends a spatial vicinity of radius 'radius'
% in the next frame is searched for path fragments with lost begin status.
% If this is the case for exactly one path fragment, the
% two fragments will be connected into one path.
%
%


% if radius is not given,  set default parameter:
if ~exist('radius','var')
    radius = 30;
end

% if verbose is not given, set default False
if ~exist('verbose','var')
    verbose = 0;
end

% we iterate over all paths as long as there is a change in the
% connectivity of all paths. To observe this connectivity, we iterate
% until no change in am can be observed. to start iteration, we need
% an altered adjacency matrix
amOld = am;
amOld(1,1) = 1;

id_lostBegin = [];
id_lostEnd = [];
frame_lostEnd = [];
frame_lostBegin = [];

iter = 1;
while ~isequal(amOld,am)
    amOld = am;
    id_lostBegin = [];
    id_lostEnd = [];
    frame_lostEnd = [];
    frame_lostBegin = [];
    connectedList = [0,0];
    
    [tLng,pm] = fillPathStatus(tLng,am,pm);
    
    % find all cellpaths with a lost begin
    % problem: paths with more than one predecessor are also set to
    % lost begin. we only want to connect cells with no predecessor
    [lostBeginList,lostBeginFrameList] =  evaluatePathStatus(pm,256);
    for i=1:length(lostBeginList)
        [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,lostBeginList(i));
        % degree of incoming nodes need to be zero
        if dIn == 0
            id_lostBegin(end+1) = lostBeginList(i);
            frame_lostBegin(end+1) = lostBeginFrameList(i);
        end
    end
    
    % and all cellpaths with a lost end
    [lostEndList,lostEndFrameList] =  evaluatePathStatus(pm,512);
    for i=1:length(lostEndList)
        [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,lostEndList(i));
        if dOut == 0
            id_lostEnd(end+1) = lostEndList(i);
            frame_lostEnd(end+1) = lostEndFrameList(i);
        end
    end
    
    % iterate over all lost ends
    for i=1:length(id_lostEnd)
        path1 = id_lostEnd(i);
        if ( frame_lostEnd(i) < tLng.time_max ) && isempty(intersect(path1,connectedList(:,2)))
            centroids = getPathCentroids(tLng,pm,path1);
            if ~isempty(centroids)
                last_centroid = centroids(end,:);
                [path2] = getNearPath(tLng,frame_lostEnd(i) + 1 ,last_centroid,'radius',radius);
                
                % we need to make sure that
                % 1) only one path was found and
                % 2) the path starts in frame frame_lostEnd(i) + 1
                
                if ~isempty(path2) && isequal(length(path2), 1) && ...
                        ~isempty(intersect(id_lostBegin,path2)) && ...
                        isequal(pm{path2,1}, (frame_lostEnd(i) + 1 ))
            
                    [tLng,am,pm] = connectCellpaths(tLng, am, pm, path1, path2,'verbose',0);
                    [tLng,pm] = fillPathStatus(tLng,am,pm);
            
                    connectedList(end+1,:) = [path1,path2];
                    
                end
            end
        end
    end
    
    if verbose
        fprintf('iteration %i finished \n',iter)
    end
    iter = iter + 1;
end

pathList = evaluatePathStatus(pm,1);
emptyList = setdiff( [1:size(pm,1)],pathList);
[tLng,am,pm] = sortAM(tLng,am,pm);
