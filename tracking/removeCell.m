function tLng = removeCell(tLng,time,cellnumber)
	% removeCell deletes single cell from timeline  and updates the struct 
	%
	% tLng = removeCell(tLng,time,cellNr)
	%
	%  
	%
	%
	% t.b. 05.2009 edited 01.2009 M.B.
	
	if isstruct(tLng) && (strcmp(tLng.type,'timelineNG'))
		
		if  0 < time <= tLng.time_max
            % we need the centroid as search-position (speedup in
            % correctTimelineNG)
            centroid = tLng.cell(time).centroid(cellnumber,:);
			tLng.cell(time).cells{cellnumber} = [];
			tLng.cell(time).centroid(cellnumber,:) = [1.0e+005,1.0e+005];
			tLng.cell(time).status(cellnumber) = -10;
			tLng.cell(time).successor{cellnumber} = [];
			tLng.cell(time).predecessor{cellnumber} = [];
			tLng.cell(time).neighbour(cellnumber,1:6) = zeros(1,6);
			% we have to correct the cellmask's in time-1, time and time+1
			% first we create our time-vector (with the times which have 
			% to be corrected) 
			timeVector = max(1,time-1):min(time+1,tLng.time_max);
			% then we correct them
			%tLng =  correctTimelineNG(tLng,'time',timeVector);
            tLng =  correctTimelineNG(tLng,'time',timeVector,...
                'position',centroid,'radius',40);
			% the neighbours are set to the neares to [-100,-100]
			% so we set them zero manually -> now we do this 
			% in correctTimelineNG
			%tLng.cell(time).neighbour(cellnumber,1:6) = zeros(1,6);
		else
			fprintf('cannot access frame %i \n',time);
		end
	else
		error('Wrong input! I expect an timelineNG-struct as input!!!');
	end
	
end