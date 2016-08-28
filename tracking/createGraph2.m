function [am,pm] = createGraph2(tLng,time,cell,am,pm,varargin)
% createGraph creates a graph from one single cell
%
% [am,pm] = createGraph2(tLng,time,cell,am,pm,varargin)
%
%  tLng = timelineNG struct
%  time = int value (frame number / time where to start)
%  cell = cell number for the beginning of the graph
%  am   = adajcency matrix
%  pm   = path-matrix, each row correspondeses with the entries from am
%         so if path 2 is connected with path 4 we get two entries:
%         -one in (2,4) weighted with the overlap from the last cell in
%          in path 2 with the first cell in path 4
%         -one in (4,2) weighted with the overlap from the first cell in
%          in path 4 with the last cell in path 2
%
%         (for other weight-function amAddEdge.m has to be modified)
%
%  this code uses the functions cellpathTimelineNG.m and
%  amAddEdge.m
%
%
% Optional arguments:
%
%   lastCell             the last node (this denotes a path, we store
%                        the paths as nodes.. a bit weitd, i know, will
%                        change it soon)
%   recursion            the actual rec. depth
%   max_recursion        rec. depth to abort the  recursions
%   cellpathoption       cell-array with arguments for the cellpath
%                        a good choice for this options is given in
%                        in Example I
%   Default values for cellpathoptions are:
% cellpathoption =  {'singlecell',1,'threshold',0,'threshold_b',0,'both'};
%
%Example I
%
%   am = [];
%   pm = [];
%   cpOptions =  {'singlecell',1,'threshold',0,'threshold_b',0,'both'};
%
%   [am,pm] = createGraph2(tLng,1,2,am,pm,...
%               'max_recursion',80,'cellpathoption',cpOptions)
%


% we set default values for the cellpathoptions
cellpathoption =  {'singlecell',1,'threshold',0,'threshold_b',0,'both'};
lastCellNr = [];
recursion = 0;
max_recursion = 100;
i = 1;
DEBUG = 0;
% we check for all input arguments
%
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'lastCell',         i=i+1; lastCellNr = varargin{i};
            case 'recursion',        i=i+1; recursion  = varargin{i};
            case 'max_recursion',    i=i+1; max_recursion = varargin{i};
            case 'cellpathoption',   i=i+1; cellpathoption = varargin{i};
            case 'backward',         i=i+1; cellpathoption{end+1} = 'backward';
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['createGraph.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
    end
    i = i+1;
end

% First  we check if we reached the last recursion , than we abort an
% return am and pm as given in the input
if max_recursion > recursion
    
    % we create a cellpath using the cellpathoption
    path = cellpathTimelineNG(tLng,cell,'time',time,cellpathoption{:}); 
    
    % nPath stores the number of paths in pm, we need to check if
    % the actual path was inserted before
    nPath = size(pm,1);
    
    % insert the path
    [pm,pathnr] = pmAddPath(pm,path);
    % we check if the path was inserted before, (than the size of pm
    % changes and the new path ist the last path. if the path was inserted
    % before, the pathnr. is returned by pmAddPath if so, we abort this
    % loop
    %if pathnr > nPath
        
        % for the first path we have no lastCellNr and we cannot add
        % a node
        if ~isempty(lastCellNr)
            am = amAddEdge(tLng,am,pm,lastCellNr,pathnr);
        end
     if pathnr > nPath   
        % the next 'last' cell
        lastCellTime = path(end,1);
        lastCellNr   = path(end,2);
        
        % and the first cell
        firstCellTime = path(1,1);
        firstCellNr   = path(1,2);
        
        % we have to check if we have a forward path
        FORWARD = 1;
        for iCO=1:length(cellpathoption)
            % seek and destroy :)
            if isequal(cellpathoption{iCO},'backward')
                FORWARD = 0;
                % if 'backward' option is found, we delete it out, so
                % it's easier to handle the direction
                cellpathoption(iCO:end-1) =  cellpathoption(iCO+1:end) ;
                cellpathoption = cellpathoption(1:end-1);
            end
        end
        
        % i think the following code could be shortened by tourning 
        % firstCell / lastCell around.... but it still works fine, so 
        %  at first i donnot care)
        %
        
        % have we reached the end of the timeline? (in case of FORWARD)
        if FORWARD && (lastCellTime < tLng.time_max)
            
            % we need the number of successor-cells
            nSucc = size(tLng.cell(lastCellTime).successor{lastCellNr},1);
            
            % the new time
            isCellTime = lastCellTime +1;
            
            % we have to rec. call all success.
            for iSucc = 1:nSucc
                % isCellNr stores the nr of the successor cell
                isCellNr = tLng.cell(lastCellTime).successor{lastCellNr}(iSucc,1);
                % rec. call
                [am,pm] =  createGraph2(tLng,isCellTime,isCellNr,am,pm,...
                    'lastCell',pathnr,'recursion',recursion+1,...
                    'max_recursion',max_recursion,'cellpathoption',cellpathoption );
                
            end
            
            % same procedure vice versa, first the predecessors, than
            % for all pred. all succs
            
            nPred = size(tLng.cell(firstCellTime).predecessor{firstCellNr},1);
            ipCellTime = firstCellTime -1;
            
            for iPred = 1:nPred
                ipCellNr = tLng.cell(firstCellTime).predecessor{firstCellNr}(iPred,1);
                [am,pm] =  createGraph2(tLng,ipCellTime,ipCellNr,am,pm,...
                    'lastCell',pathnr,'recursion',recursion+1,...
                    'max_recursion',max_recursion,...
                    'cellpathoption',{cellpathoption{:},'backward'} );
                
            end
            
            % have we reached the beginning of the timeline? if not FORWARD
            %
            % !!! we donnot need to check if we reached the first frame,
            % we only loose some cells here... so we skip this check
        elseif ~FORWARD %&& (lastCellTime > 1)
            
            % same procedure vice versa, first the predecessors, than
            % for all pred. all succs
            nPred = size(tLng.cell(lastCellTime).predecessor{lastCellNr},1);
            iCellTime = lastCellTime -1;
            
            for iPred = 1:nPred
                ipCellNr = tLng.cell(lastCellTime).predecessor{lastCellNr}(iPred,1);
                [am,pm] =  createGraph2(tLng,iCellTime,ipCellNr,am,pm,...
                    'lastCell',pathnr,'recursion',recursion+1,...
                    'max_recursion',max_recursion,...
                    'cellpathoption',{cellpathoption{:},'backward'} );
            end
            
            
            
            % we need the number of successor-cells
            nSucc = size(tLng.cell(firstCellTime).successor{firstCellNr},1);
            
            % the new time
            isCellTime = firstCellTime +1;
            
            % we have to rec. call all success.
            for iSucc = 1:nSucc
                % isCellNr stores the nr of the successor cell
                isCellNr = tLng.cell(firstCellTime).successor{firstCellNr}(iSucc,1);
                % rec. call
                [am,pm] =  createGraph2(tLng,isCellTime,isCellNr,am,pm,...
                    'lastCell',pathnr,'recursion',recursion+1,...
                    'max_recursion',max_recursion,'cellpathoption',cellpathoption );
                
            end
            
            % at last we throw out some debug messages (if DEBUG is set)
        elseif DEBUG
            fprintf('end / beginning of the timeline, rec. %i! \n',....
                recursion);
        end
    elseif DEBUG
        fprintf('path already inserted... we step over to the next one. \n');
    end
elseif DEBUG
    fprintf('max. recursion-level /depth is reached at time %i, cell %i! \n',...
        time,cell);
end

