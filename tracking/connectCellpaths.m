function [tLng,am,pm] = connectCellpaths(tLng, am, pm, path1, path2,varargin)
% connectCellpaths connectes two paths
%
% [am,pm] = connectCellpaths(tLng, am, pm, path1, path2)
%
% the second path (path2) will be deleted, path1 will grow
%
% optional arguments
%
%  'verbose'
%
%  Example
%
%  [tLng,am,pm] = connectCellpaths(tLng, am, pm, path1, path2,'verbose',1)
%
%  t.b. 08.2009, modified dec. 2009


i = 1;
% we check for all input arguments
%
VERBOSE = 0;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'VERBOSE',         i=i+1; VERBOSE = varargin{i};
            case 'verbose',         i=i+1; VERBOSE = varargin{i};
            case 'Verbose',         i=i+1; VERBOSE = varargin{i};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['connectCellPath.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
    end
    i = i+1;
end

% we get the two cellpaths
cpath1 = pm{path1,3};
cpath2 = pm{path2,3};

% we combine them
cpath3 = [cpath1;cpath2];

% we sort them
[v,i] = sort(cpath3(:,1));
cpath3 = cpath3(i,:);

% we delete double entries if we have some
[b,i,j] = unique(cpath3(:,1),'first');

% we write new parameters
pm{path1,3} = cpath3(i,:);
pm{path1,1} = cpath3(1,1);
pm{path1,2} = cpath3(end,1);

% we "reset" path2
for i=1:3
    pm{path2,i} = [];
end
pm{path2,4} = 0;

% now we update am: first we delete the
% connection between path1 and path2
am(path1,path2) = 0;
am(path2,path1) = 0;


% if path1 ends before path2 starts
% we delete all cells ending / beginning at the end of path1.
% if not, we remove

if cpath1(end,1) < cpath2(1,1)
    
    % all outgoing paths connected to path1 are removed
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,path1);
    if dOut > 0
        oldNodes = cNOut(:,1);
        for iNode=1:length(oldNodes)
            node = oldNodes(iNode);
            am(node,path1) =  0;
            am(path1,node) =  0;
        end
    end
    
    % all incoming paths to path2 are removed
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,path2);
    if dIn > 0
        oldNodes = cNIn(:,1);
        for iNode=1:length(oldNodes)
            node = oldNodes(iNode);
            am(node,path2) =  0;
            am(path2,node) =  0;
        end
    end
    
    % all outgoing paths connected to path2 are connected to path1
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,path2);
    if dOut > 0
        oldNodes = cNOut(:,1);
        for iNode=1:length(oldNodes)
            node = oldNodes(iNode);
            am(node,path1) =  am(node,path2);
            am(path1,node) =  am(path2,node);
            am(node,path2) =  0;
            am(path2,node) =  0;
        end
    end
    
    
    
    
else % know, path2 ends before path1 starts
    keyboard
    % all outgoing paths connected to path2 are removed
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,path2);
    if dOut > 0
        oldNodes = cNOut(:,1);
        for iNode=1:length(oldNodes)
            node = oldNodes(iNode);
            am(node,path2) =  0;
            am(path2,node) =  0;
        end
    end
    
    % all incoming paths to path1 are removed
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,path1);
    oldNodes = cNIn(:,1);
    if dIn > 0
        for iNode=1:length(oldNodes)
            node = oldNodes(iNode);
            am(node,path1) =  0;
            am(path1,node) =  0;
        end
    end
    
    
    % all outgoing paths connected to path1 are connected to path2
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,path1);
    oldNodes = cNOut(:,1);
    if dOut > 0
        for iNode=1:length(oldNodes)
            node = oldNodes(iNode);
            am(node,path2) =  am(node,path1);
            am(path2,node) =  am(path1,node);
            am(node,path1) =  0;
            am(path1,node) =  0;
        end
    end
    
end



 % then we have to "bend" all remaining connections
 % beginning at path2 to path1

%      
%  
%  
%  [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,path2);
%  if dIn >1
%      disp('what? you should check if these two paths CAN be connected!')
%      disp('i connect them....');
%  end
%      oldNodes = cNOut(:,1);
%      for iNode=1:length(oldNodes)
%          node = oldNodes(iNode);
%          am(node,path1) =  am(node,path2);
%          am(path1,node) =  am(path2,node);
%          am(node,path2) =  0;
%          am(path2,node) =  0;
%      end
%      
     [statusVector,statusInt] = getPathStatus(pm,path1);
     [pm,tLng,newStatus] = setPathStatus(tLng,pm,path1,statusInt);
 
 
 
 
 % we set the path-status to the status of path1
 % ( this is fast but not correct, use fillPathStatus
 % to be sure to get the correct status-flag)
% [v,statusInt] = getPathStatus(pm,path1);
% [pm,tLng,newStatus] = setPathStatus(tLng,pm,path2,statusInt);
 