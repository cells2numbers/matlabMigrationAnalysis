function tLng = fillOverlap(tLng,varargin)
	%  function to calculate the cell-overlap (for each cell) with 
	%  cells in the next image. the information is stored in the
	%  tLng-struct
	%
	%  
	%  optional arguments: 
	%     'statusbar'     with value 1/0 for use in guis
	%     'statustext'    with value 1/0
	%     'time'          vector with time-stamps that 
    %                     should be checked / corrected
    %     'position'      timeline is only corrected at the given
    %                     position = [x,y]
    %     'radius'        radius araound the position, 
    %                     default value = 80;
	%  (default values are 0 (=false)
	%
	%
    %
    %   Example
    %
    %  tLng = fillOverlap(tLng,'statustext',1);
    %
    %  tLng = fillOverlap(tLng,'statustext','time',5:10);
    %
	%  t.b. 02.09, corrected 08.2009: small correction in the 
    %                                 second loop
    %
    %  t.b. jan. 2010   added position based search (for speedup)
	
	
    % number of neighbours we want to check 
    % for overlapp (6 is not enough, 10 should 
    % be, optimized june 2009)
    maxN = 10;
	
    % optional input argument, if given, we search 
    % only at / around the given position 
    position = 0;
    radius = 80;
    % we search in a distance "radius" around the 
    % given position
    
	if isstruct(tLng)&&(strcmp(tLng.type,'timelineNG'))
		
		% default parameters (to show information)
		status_bar = 0;
		status_text = 0;
		time = 1:tLng.time_max;
		% check for input
		i = 1;
		while i<=length(varargin),
			argok = 1;
			if ischar(varargin{i}),
				switch varargin{i},
					% argument IDs
					case 'statusbar',     status_bar  = 1;
					case 'statustext',    status_text = 1;
					case 'time',          i = i+1; time = varargin{i};
                    case 'position',      i = i+1; position = varargin{i};
                    case 'radius',        i = i+1; radius = varargin{i};
					otherwise
						argok=0;
				end
			else
				argok = 0;
			end
			if ~argok,
				disp(['fillOverlap.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
			end
			i = i+1;
        end
		
        % if a search position is given, first we look for 
        % cells to check
        if position
            cells2check = {size(time)};
            for i = 1:length(time)
                iTime = time(i);
                cells2check{i} = getNearCell(tLng,iTime,position,'radius',radius);
            end
        end
        
		% for easier handle.... 
		time_max = tLng.time_max;
		
		% some time information?
		tic
		
		for i=1:length(time)
			time_a = time(i);
            
            % if we search at a given position "position", 
            % we only look for cells near our position
            % ( with max. distance radius, see above for calculation) 
            if position
                cell_number = cells2check{i};
            else
                cell_number =  1:length(tLng.cell(time_a).cells);
            end
			
			% preallocating for speedup
			
			cell_successor = tLng.cell(time_a).successor;
            
			% now we collect information for each single cell
			for cell_a=cell_number
				% now we sort the successors from the next image
				% (we have to let out the last time)
                
                cell_successor = tLng.cell(time_a).successor;
				if (time_a~=time_max)&&~isempty(tLng.cell(time_a).cells{cell_a})
					% we need the volume of our current cell
					% ( the number of pixels = length of cells{j})
					cell_vol = length(tLng.cell(time_a).cells{cell_a});

					% first we sort the successors by distance
					% ind stores the number (index or position) and 
					% val stores the index-overlap (pixel-cell /
                    % pixel-overlap)
                    [val,ind] = getbestIndex(tLng, cell_a, time_a, time_a +1);
                    
                    nNeighbours = min(maxN,length(ind));
                    
                    if nNeighbours < maxN
                        ind= [ind,zeros(1,maxN-size(ind,2))];
                    else
                        ind =ind(1:maxN);
                    end
                    
					% for the six nearest successors we calculate the overlap
					succ = [];
                    for s=1:maxN
                        % remark: getsameIndex(tLng,cell_a,time_a,cell_b,time_b)
                        if ind(s) % we have to avoid the case, that we have 
                                  % less than maxN neighbours, than we have 
                                  % zeros inserted!!! 
                            overlap = getsameIndex(tLng,cell_a,time_a,ind(s),time_a+1);
                            if overlap~=0
                                succ = [succ;[ind(s),overlap / cell_vol ]];
                            end
                        end
                    end
                    
					cell_successor{cell_a} = succ;
				end
			end
			% now we modify the given timeline
			tLng = modTimestampNG(tLng,time_a,'successor',cell_successor);
			%----------------------------------------------------------------------------
			% just some information... 
			
			% text
			tmax = length(time);
            if status_text && ~mod(i,25)
				textOut = sprintf(' %3.2f%% done (%i from %i images, turn 1 of 2) , time elapsed: %i min %i seconds ', ...
					100* i / tmax,i,tmax, floor(toc/60),floor(mod(toc,60)) );
                disp(textOut);
			end
			
			% and for gui-use 
			if status_bar
				sb = statusbar('Calculating overlap %d of %d frames (%.1f%%), run 1 of 2...',i,tmax,100*i/tmax);
				set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',tmax, 'Value',i);
			end
			
			
			
		
		end
		
		for i=length(time):-1:1
			time_a = time(i);
            
            % if position give, we only check precomputed cells 
            % given in cells2check
            if position
                cell_number = cells2check{i};
            else
                cell_number =  1:length(tLng.cell(time_a).cells);
            end
			% preallocating for speedup
			cell_predecessor = tLng.cell(time_a).predecessor;
			
			% now we collect information for each single cell
			for cell_a=cell_number
				% now we sort the successors from the next image
				% (we have to let out the last time)
				if (time_a~=1)&&~isempty(tLng.cell(time_a).cells{cell_a})
					% we need the volume of our current cell
					% ( the number of pixels = length of cells{j})
					cell_vol = length(tLng.cell(time_a).cells{cell_a});

					% first we sort the successors by distance
					% ind stores the number (index or position) and 
					% val stores the index-overlap (pixel-cell /
					% pixel-overlap) 
					[val,ind] = getbestIndex(tLng, cell_a, time_a, time_a -1);
					% pixel-overlap)
                                       
                    nNeighbours = min(maxN,length(ind));
                    
                    if nNeighbours < maxN
                        ind= [ind,zeros(1,maxN-size(ind,2))];
                    else
                        ind =ind(1:maxN);
                    end
                    
					% for the maN nearest successors we calculate the overlap
					pred = [];
                    for s=1:maxN
                        if ind(s) % some as above!
                            % remark: getsameIndex(tLng,cell_a,time_a,cell_b,time_b)
                            overlap = getsameIndex(tLng,cell_a,time_a,ind(s),time_a-1);
                            if overlap~=0
                                pred = [pred;[ind(s),overlap / cell_vol ]];
                            end
                        end
                    end
					cell_predecessor{cell_a} = pred;
				end
			end
			% now we modify the given timeline
			tLng = modTimestampNG(tLng,time_a,'predecessor',cell_predecessor);
			%----------------------------------------------------------------------------
			% just some information... 
			
			% text
						
			tmax = length(time);
            
            if status_text && ~mod(tmax,25)
                textOut = 	sprintf('%3.2f%% done (%i from %i images, run 2 of 2)  time elapsed: %i min %i seconds ',...
                    100* (tmax - i+1) / tmax,tmax - i+1,tmax, floor(toc/60),floor(mod(toc,60)) );
                disp(textOut);
            end
            
			% and for gui-use 
			if status_bar
				sb = statusbar('Calculating overlap %d of %d frames (%.1f%%), run 2 of 2...',1+tmax - i,tmax,100*(1 + tmax- i)/tmax);
				set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',tmax, 'Value',1 + tmax - i);
			end
			

		end
		
	else
		error('Wrong input! I expect an timelineNG-struct as input!!!');
    end
    fprintf('\n');
end