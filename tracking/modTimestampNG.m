function tLng = modTimestampNG(tLng,time,varargin)
	% function to modify an timestamp on an timestampNG struct
	% accepted parameters:
	%
	% 'names'                              % name as double  
	% 'centroid'                           % array with size [number,2]
	% 'cells'                              % cell array with length number
	% 'neighbours'                         % cell array with length number
	% 'successor', [], ...                 % poss. succ. cells from next im.
	% 'mother'                             % name as double (plus time?)
	% 'children'                           % name as double (plus time?)
	% 'status'                             % todo: status parameter
	% 'time_max'
	%
	%
	%
	%
	
	if isstruct(tLng)&&(strcmp(tLng.type,'timelineNG'))
		
		% get current length / time to store new values at
		% correct positions
		ctime = time;
		
		% check and insert given values
		i=1;
		while i<=length(varargin),
			argok = 1;
			if ischar(varargin{i}),
				switch varargin{i},
					% argument IDs
					case 'time_max',     i=i+1; tLng.time_max = varargin{i};
					case 'name',         i=i+1; tLng.cell(ctime).name = varargin{i};
					case 'centroid',     i=i+1; tLng.cell(ctime).centroid = varargin{i};
					case 'cells',        i=i+1; tLng.cell(ctime).cells = varargin{i};
					case 'neighbour',    i=i+1; tLng.cell(ctime).neighbour = varargin{i};
					case 'predecessor',  i=i+1; tLng.cell(ctime).predecessor = varargin{i};
					case 'successor',    i=i+1; tLng.cell(ctime).successor = varargin{i};
					case 'mother',       i=i+1; tLng.cell(ctime).mother = varargin{i};
					case 'children',     i=i+1; tLng.cell(ctime).children = varargin{i};
					case 'status',       i=i+1; tLng.cell(ctime).status = varargin{i};
					case 'number',       i=i+1; tLng.cell(ctime).number = varargin{i};
					otherwise
						argok=0;
				end
			else
				argok = 0;
			end
			if ~argok,
				disp(['modTimestampNG.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
			end
			i = i+1;
		end
		
		
		% we can set time_max to time, if not defined
		if tLng.time_max < tLng.time
			tLng.time_max = tLng.time;
		end
	else
		error('Wrong input! I expect an timelineNG-struct as input!!!');
	end
end