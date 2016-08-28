function [tLng,cellInsert] = addCell(tLng,time,cells,varargin)
	% addCell add's a single cell to a timeline  and updates the struct 
	%
	% tLng = addCell(tLng,time,cells,varargin)
	%
	%  this functions inserts a new cell into a timeline
	%  the cell has to be given as an index-vector
	%  (see the timeline-struct for more information)
    %
    %  added consisteny check jan. 2010, a cell is not inserted
    %  if it overlaps with one already inserted cell, 
    %
    %  the program has one additional flag to force inserting
    %  a cell (even if it overlaps with another cell, this flag
    %  just skips the test for overlap) 
    %  
    %  Optional Flags:
    %
    %    force                   forces the insert of a cell
    %                            (skips overlap check)
    %    radius                  radius in which cells are 
    %                            updated after inclusion
    % 
	% 
	%  Example 
    %  (for a given timeline tLng)
	%
	%   t = removeCell(tLng,5,23);
	%   cells = tLng.cell(5).cells{23};
	%   t = addCell(t,5,cells)
	% 
    %  Example (it shows how to use the force flag, 
    %           keep in mind that this is dangerous 
    %           and can result in several errors)
    %           this example adds a fake cell, so 
    %           do not wonder about the index-vector
    %
    %   t = addCell(tLng,5,1:100,'force',1)
    %
    %   See also fillTimelineNG.m
	% 
    %  t.b. 05.2009
    % 
    % added position based correction of the timeline jan. 2010  tb
    % added check for overlapping cells at the end of jan. 2010  tb
	
    radius = 100;
    FORCE = 0;
    INSERT = 1;
    i = 1;
    while i<=length(varargin),
        argok = 1;
        if ischar(varargin{i}),
            switch varargin{i},
                % argument IDs
                case 'force',         i=i+1; FORCE = varargin{i};
                case 'radius',        i=i+1; radius = varargin{i};
                otherwise
                    argok=0;
            end
        else
            argok = 0;
        end
        if ~argok,
            disp(['addCell.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
        end
        i = i+1;
    end

    
    
	if isstruct(tLng) && (strcmp(tLng.type,'timelineNG'))
		
		if  0 < time <= tLng.time_max
			% we need the cell-number to insert the new cell 
			cellInsert =  length(tLng.cell(time).cells) +1;
			% do we have a deleted cell? then we add the new cell to the 
			% old position 
            for iCell=1:length(tLng.cell(time).cells)
                if isempty(tLng.cell(time).cells{iCell})
                    cellInsert = iCell;
                end
            end
            
            % we need the centroid of the cell 
            %   ( to check for overlapping cells 
            %     and later to insert the cell)
                A = zeros(tLng.image_size);
                A(cells) = 1;
                [i,j] = find(A == 1);
                centroid  = mean([i,j]);
            % here we check if we have overlapping cells 
            
            if ~FORCE
                % we find the nearest cells and check if the
                % index-vectors of each cells intersects with
                % the new cell. 
                nearCell = getNearCell(tLng,time,centroid,'radius',radius);
                sameIndex = zeros(size(nearCell));
                
                for iCell=1:length(nearCell)
                    sameIndex(iCell) = ~isempty(intersect(cells,tLng.cell(time).cells{nearCell(iCell)}));
                end
                
                INSERT = sum(sameIndex) == 0;
                
            end          
            
            
            % if it is save (or forced) to insert the cell, we 
            % go on.... 
            if INSERT || FORCE
               
                
                fprintf('inserting cell %i in frame %i \n',cellInsert,time);
                % we add the given cells
                tLng.cell(time).cells{cellInsert} = cells;
                tLng.cell(time).centroid(cellInsert,:) = centroid;
                tLng.cell(time).status(cellInsert) = 0;
                tLng.cell(time).successor{cellInsert} = [];
                tLng.cell(time).predecessor{cellInsert} = [];
                tLng.cell(time).neighbour(cellInsert,:) = 0;
                tLng.cell(time).number = tLng.cell(time).number +1;
                % we have to correct the cellmask's in time-1, time and time+1
                % first we create our time-vector (with the times which have
                % to be corrected)
                timeVector = max(1,time-1):min(time+1,tLng.time_max);
                
                % then we minimally correct the timeline
                tLng =  correctTimelineNG(tLng,'time',timeVector,...
                    'position',centroid,'radius',radius);
            else 
                fprintf('Cell is overlapping with another cell, aborting\n');
                cellInsert = -10;
            end
            
		else
			fprintf('cannot access frame %i \n',time);
		end
	else
		error('Wrong input! I expect an timelineNG-struct as input!!!');
	end
	
end