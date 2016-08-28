function tLng = correctTimelineNG(tLng,varargin)
% correctTimelineNG checks and corrects a timeline struct at a given time
%
% tLng = correctTimelineNG(tLng,varargin)
%
%
%
%
%
% new
%  -neighbours at the given time
%  -new successors / predecessors at time +-1
%  -new overlap
%
% this program gives output if it find neighbours / successors / predecessors
% that are incorrect
%
% EXAMPLE: to check each  third frame, type
%	  tLng = correctTimelineNG(tLng,'time',1:3:99)
%
%  to simply check all frames, type
%     tLng = correctTimelineNG(tLng)
%
%
%  Optional arguments:
%
%      verbose-flag, gives more output to the console
%
%       tLng = correctTimelineNG(tLng,'verbose',1)
%
%
% t.b., corrected 23.06.2009 (added nMax to choose
%       the number of neighbours and the number of cells,
%       which should be checked for overlap)
%
% t.b.  corrected 5 jan 2010, status is not set to 0 anymore,
%       this causes some errors if status is already set

% check input
position = 0;
radius = 80;
VERBOSE = 0;
nMax = 25;
if isstruct(tLng)&&(strcmp(tLng.type,'timelineNG'))
    time = 1:tLng.time_max;
    % check optional arguments
    i = 1;
    while i<=length(varargin),
        argok = 1;
        if ischar(varargin{i}),
            switch varargin{i},
                % argument IDs
                case 'time',     i=i+1; time = varargin{i};
                case 'nMax',     i=i+1; nMax = varargin{i};
                case 'VERBOSE',  i=i+1; VERBOSE = varargin{i};
                case 'Verbose',  i=i+1; VERBOSE = varargin{i};
                case 'verbose',  i=i+1; VERBOSE = varargin{i};
                case 'position', i=i+1; position = varargin{i};
                case 'radius',   i=i+1; radius = varargin{i};
                    
                otherwise
                    argok=0;
            end
        else
            argok = 0;
        end
        if ~argok,
            disp(['correctTimelineNG.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
        end
        i = i+1;
    end
    
    % we check if we have a search position
    if position
        cells2check = {size(time)};
        for i = 1:length(time)
            iTime = time(i);
            cells2check{i} = getNearCell(tLng,iTime,position,'radius',radius);
        end
    end
    
    % we check the cell_number in all frames
    
    if VERBOSE;
        fprintf('checking number of cells....');
    end
    
    
    for i=1:length(time)
        iTime = time(i);
        cell_number = 0;
        
        % in frame on we have to correct the predecessor cells,
        % in the last frame all successor cells
        if iTime == 1
            tLng.cell(iTime).predecessor = cell(1,tLng.cell(iTime).number);
        end
        
        if iTime == tLng.time_max
            tLng.cell(iTime).successor = cell(1,tLng.cell(iTime).number);
        end
        
        % we count non-empty cells
        for j=1:length(tLng.cell(iTime).cells)
            cell_number = cell_number + ~isempty(tLng.cell(iTime).cells{j});
        end
        
        if cell_number ~=tLng.cell(iTime).number
            tLng.cell(iTime).number = cell_number;
            
            if VERBOSE;
                fprintf('wrong number of cells in frame %i, corrected to %i cells \n',iTime,cell_number);
            end
        end
        
    end
    if VERBOSE
        fprintf('done!\n');
    end
    
    
    
    
    % at last we have to correct the overlap
    if VERBOSE
        fprintf('checking all overlapping cells... \n');
        tLng = fillOverlap(tLng,'time',time,'statustext',...
            'position',position,'radius',radius);
        fprintf('done!\n');
    else
        %tLng = fillOverlap(tLng,'time',time,'statustext');
        tLng = fillOverlap(tLng,'time',time,...
            'position',position,'radius',radius);
    end
    
    
    % we create and check all successors
    if VERBOSE
        fprintf('checking all successors.... ');
    end
    
    
    for i=1:length(time)
        iTime = time(i);
        
        if position
            cell_number = cells2check{i};
        else
            cell_number =  1:length(tLng.cell(iTime).cells);
        end
        
        
        % now we collect information for each single cell
        cell_successor = tLng.cell(iTime).successor;
        for cell_a=cell_number
            % now we sort the successors from the next image
            % (we have to let out the last time)
            if iTime~=tLng.time_max  && ~isempty(tLng.cell(iTime).cells{cell_a})
                % we need the volume of our current cell
                % ( the number of pixels = length of cells{j})
                cell_vol = length(tLng.cell(iTime).cells{cell_a});
                
                % first we sort the successors by distance
                % ind stores the number (index or position) and
                % val stores the index-overlap (pixel-cell /
                % pixel-overlap)
                [val,ind] = getbestIndex(tLng, cell_a, iTime, iTime +1);
                
                nNeighbours = min(nMax,length(ind));
                
                if nNeighbours < nMax
                    ind= [ind,zeros(1,nMax-size(ind,2))];
                else
                    ind =ind(1:nMax);
                end
                % for the nMax nearest successors we calculate the overlap
                succ = zeros(nMax,2);
                % we count the number of successor cells
                iS = 0;
                for s=1:nMax;
                    % remark: getsameIndex(tLng,cell_a,time_a,cell_b,time_b)
                    if ~isempty(ind(s)) && ind(s) ~=0
                        overlap = getsameIndex(tLng,cell_a,iTime,ind(s),iTime+1);
                        if overlap~=0
                            iS = iS +1;
                            succ(iS,:) = [ind(s),overlap / cell_vol ];
                        end
                    else
                        disp('successor not found!');
                    end
                end
                
                % we store the successors
                if iS == 0
                    succ = [];
                else
                    succ = succ(1:iS,:);
                end
                cell_successor{cell_a} = succ;
            end
        end
        
        % now we modify the given timeline
        if ~isequal(cell_successor,tLng.cell(iTime).successor)&& iTime~=tLng.time_max
            
            tLng = modTimestampNG(tLng,iTime,'successor',cell_successor);
            if VERBOSE
                fprintf(' Successors in frame %i updated \n',iTime);
            end
            
        end
    end
    if VERBOSE
        fprintf('done!\n');
    end
    
    % we create an check all predecessors
    % TODO: predecessors!
    if VERBOSE
        fprintf('checking all predecessors.... ');
    end
    
    for i=1:length(time)
        iTime = time(end-i+1); % + 1 - time(i);
        
        % if position give, we only check precomputed cells
        % given in cells2check
        if position
            cell_number = cells2check{length(cells2check)-i+1};
        else
            cell_number =  1:length(tLng.cell(iTime).cells);
        end
        
        % preallocating for speedup
        cell_predecessor = tLng.cell(iTime).predecessor;
        % now we collect information for each single cell
        for cell_a=cell_number
            % now we sort the successors from the next image
            % (we have to let out the last time)
            
            if (iTime~=1)&&~isempty(tLng.cell(iTime).cells{cell_a})
                % we need the volume of our current cell
                % ( the number of pixels = length of cells{j})
                cell_vol = length(tLng.cell(iTime).cells{cell_a});
                
                % first we sort the successors by distance
                % ind stores the number (index or position) and
                % val stores the index-overlap (pixel-cell /
                % pixel-overlap)
                [val,ind] = getbestIndex(tLng, cell_a, iTime, iTime -1);
                
                nNeighbours = min(nMax,length(ind));
                
                if nNeighbours < nMax
                    ind= [ind,zeros(1,nMax-size(ind,2))];
                else
                    ind =ind(1:nMax);
                end
                % for the nMax nearest successors we calculate the overlap
                pred = [];
                for s=1:nMax
                    if ~isempty(ind(s)) && ind(s) ~=0
                        % remark: getsameIndex(tLng,cell_a,iTime,cell_b,time_b)
                        overlap = getsameIndex(tLng,cell_a,iTime,ind(s),iTime-1);
                        if overlap~=0
                            pred = [pred;[ind(s),overlap / cell_vol ]];
                        end
                    else
                        disp('predecessor not found! skipping this cell');
                    end
                end
                cell_predecessor{cell_a} = pred;
            end
        end
        % now we modify the given timeline
        
        if ~isequal(cell_predecessor,tLng.cell(iTime).predecessor)
            tLng = modTimestampNG(tLng,iTime,'predecessor',cell_predecessor);
            if VERBOSE
                fprintf(' Predecessor in frame %i updated \n',iTime);
            end
        end
        tLng = modTimestampNG(tLng,iTime,'predecessor',cell_predecessor);
    end
    if VERBOSE
        fprintf('done!\n');
    end
    
    
    
    % we create and check all neighbours--------------------------------
    if VERBOSE;
        fprintf('checking all neighbours...');
    end
    for i=1:length(time)
        iTime = time(i);
        
        cell_neighbour = tLng.cell(iTime).neighbour;
        
        if size(tLng.cell(iTime).neighbour,2) ~=nMax
            if VERBOSE;
                disp('wrong number of neighbours stored in tLng!!');
                disp('resetting all neighbours!!');
            end
            if position
                disp('it is recommended to correct the complete timeline');
                disp('resetting position for neighbour calculation');
                position = 0;
            end
            cell_neighbour = zeros(length(tLng.cell(iTime).cells),nMax);
        end
        
        % if position give, we only check precomputed cells
        % given in cells2check
        if position
            cell_number = cells2check{i};
        else
            cell_number =  1:length(tLng.cell(iTime).cells);
        end
        
        
        for j=cell_number
            % preallocate for speedup
            % first we sort the neighbours
            [val,ind] = getbestIndex(tLng, j, iTime, iTime);
            
            nNeighbours = min(nMax,length(ind));
            
            if nNeighbours < nMax
                ind= [ind,zeros(1,nMax-size(ind,2))];
            else
                ind =ind(1:nMax);
            end
            % then we store our  nearest neighbours
            cell_neighbour(j,:) = ind(1:nMax);
            
            if isequal(tLng.cell(iTime).centroid(j,:),[-100,-100])
                cell_neighbour(j,:) = zeros(1,nMax);
            end
        end
        %
        
        % status = zeros(cell_number,1);
        
        if ~isequal(tLng.cell(iTime).neighbour,cell_neighbour)
            % status will not be set to 0, changed jan. 2010 (tb)
            % tLng = modTimestampNG(tLng,iTime,'neighbour',cell_neighbour,'status',status);
            tLng = modTimestampNG(tLng,iTime,'neighbour',cell_neighbour);
            if VERBOSE;
                fprintf('\nwrong neighbours in frame %i, corrected! \n',iTime);
            end
        end
    end
    if VERBOSE;
        fprintf('done!\n');
    end
    
    
    % at last we have to correct the overlap
    %fprintf('checking all overlappipng cells...');
    %tLng = fillOverlap(tLng,'time',time,'statustext');
    %fprintf('done!\n');
else
    error('Wrong input! I expect a timelineNG-struct as input!!!');
end
end