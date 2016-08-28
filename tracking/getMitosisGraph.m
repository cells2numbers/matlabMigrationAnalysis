function mitoseList = getMitosisGraph(am,pm,varargin)
% getMitosisGraph() searchs for mitosis
%
%  mitosesList = getMitosisGraph(am,pm)
%
%             case 'length',          i=i+1; minPathLength = varargin{i};
%             case 'path',            i=i+1; mPath = varargin{i};
%
% tb 08.2009


minPathLength = 2;
i = 1;
mPath = [];
%
VERBOSE = 0;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'verbose',         i=i+1; VERBOSE = varargin{i};
            case 'length',          i=i+1; minPathLength = varargin{i};
            case 'path',            i=i+1; mPath = varargin{i};
                
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['getMitosisGraph.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
    end
    i = i+1;
end


mitoseList = [];

if isempty(mPath)
    maxLength = length(am);
else
    maxLength = length(mPath);
end
    

% loop over all paths
for i=1:maxLength
    
    if ~isempty(mPath)
        iPath = mPath(i);
    else
        iPath = i;
    end
    
    NODELENGTHOK = 0;
    % get cellpath iPath
    cellpath = pm{iPath,3};
    % check of the length of the path is OK
    LENGTHOK = length(cellpath) >= minPathLength;
    
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,iPath); % node information
    % check the connected nodes
     NODEOK = (dOut == 2) && (sum(cNOut(:,4))==2) && ~isempty(cNOut);
    % NODEOK = (dOut == 2)  && ~isempty(cNOut);
    % length of the nodes
    
    if NODEOK && LENGTHOK
        
       NODELENGTHOK =  length(pm{cNOut(1,1),3}) >= minPathLength &&  ...
           length(pm{cNOut(2,1),3}) >= minPathLength ;
    end
    
    % if length and nodes are ok, we add the path
    if NODELENGTHOK
        mitoseList = [mitoseList;iPath];
    end
    
    if VERBOSE
       fprintf('\r finished %i from %i paths ',iPath, size(am,1));
    end
end 
