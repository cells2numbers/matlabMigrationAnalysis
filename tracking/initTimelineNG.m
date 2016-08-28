function tLng = initTimelineNG(varargin)
	% function to initialize a timeline,   % accepted parameters:
	%
	% 'names'                              % name as double  
	% 'centroid'                           % array with size [number,2]
	% 'cells'                              % cell array with length number
	% 'neighbours'                         % cell array with length number
	% 'successor', [], ...                 % possible successor-cells 
	%                                      % from next image, stored as 
	%                                      % 
	%
	% 'mother'                             % name as double (plus time?)
	% 'children'                           % name as double (plus time?)
	% 'status'                             % todo: status parameter
	% 'time_max'
	%
	% t.b. 
	
	
tLng = struct('type','timelineNG', ...   % set type
	'time_max' , [], ...                 % set number of images / max time
	'time', 1, ...                       % we are in the first frame :) 
	'cell', [], ...                      % cell-struct, see below  
    'image_size', [] );                  % image size

% the cell struct contains all information about the cells at the 
% the given time. cell is a cell arrray, each cell array contains
% 
%

tLng.cell = struct('type','cellNG', ...
	'name', [], ...                      % name as double  
	'centroid',[], ...                   % array with size [number,2]
	'cells',[], ...                      % cell array with length number
	'neighbour', [], ...                 % cell array with length number
	'successor', {}, ...                 % succ. cells from next frame
	'predecessor', {}, ...               % pred. cells from prev. frame
	'mother', [], ...                    % name as double (plus time?)
	'children', [], ...                  % name as double (plus time?)
	'number', [], ...                    % number of cells at each time 
	'status', []);                       % todo: status parameter


% we check for input arguments and set what we get
i=1;
while i<=length(varargin),
	argok = 1;
  if ischar(varargin{i}), 
	  switch varargin{i},
		  % argument IDs
		  case 'time_max',     i=i+1; tLng.time_max = varargin{i};
		  case 'number',       i=i+1; tLng.cell(1).number = varargin{i};
		  case 'name',         i=i+1; tLng.cell(1).name = varargin{i};

		  case 'centroid',     i=i+1; tLng.cell(1).centroid = varargin{i};
		  case 'cells',        i=i+1; tLng.cell(1).cells = varargin{i};
		  case 'neighbour',    i=i+1; tLng.cell(1).neighbours = varargin{i};
			  
		  case 'successor',    i=i+1; tLng.cell(1).successor = varargin{i};
		  case 'predecessor',  i=i+1; tLng.cell(1).predecessor = varargin{i};
		  case 'mother',       i=i+1; tLng.cell(1).mother = varargin{i};
		  case 'children',     i=i+1; tLng.cell(1).children = varargin{i};
			  
		  case 'status',       i=i+1; tLng.cell(1).status = varargin{i};
		  case 'image_size',   i=i+1; tLng.image_size = varargin{i};
		  otherwise
			  argok=0;
	  end
  else
	  argok = 0;
  end
  if ~argok,
	  disp(['initTimelineNG.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
  end
  i = i+1;
end

% we can set time_max to time, if not defined
if isempty(tLng.time_max)
	tLng.time_max = tLng.time;
end

