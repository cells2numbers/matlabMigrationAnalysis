function [overlap,cells] = getsameIndex(tLng,cell_a,time_a,cell_b,varargin)
% getsameIndex returns the number of same indices (pixel) for diff. cells
%
%
%  [overlap] = getsameIndex(tLng,cell_a,time_a,cell_b)
% 
% INPUT: 
%   tLng     timelineNG struct
%   cell_a   int
%   time_a   int
%   cell_b   int  or array 
%   time_b   int  (optional, time_b = time_a + 1 if not given)
%
%
%
% EXAMPLES: 
%
%   [se] = getsameIndex(tLng,1,1,3);
%   
%   [se] = getsameIndex(tLng,1,1,1:20);
%
% t.b. 02.2009, last modified 05.05.09
	
	if isstruct(tLng)&&(strcmp(tLng.type,'timelineNG'))
		
		% we check if the second time is given as input
		% (using varargin)
		if length(varargin)==1
			time_b = varargin{1};
		else 
			% if not, we set the default value for time_b
			time_b = time_a +1;
		end

		% "ca" stores all index-values for the pixels
		%  from cell_a (in the timeline)
		ca = tLng.cell(time_a).cells{cell_a};
		
		% init output variables
		overlap = zeros(1,length(cell_b));
		
		% we check all 
		for i=1:length(cell_b)
			% get best index vectors for the current cell
			cb = tLng.cell(time_b).cells{cell_b(i)};
			
			% we calculate the number of elements using
			% the unique command
			overlap(i) = length(ca) + length(cb) - ...
				length(unique([ca;cb]));
		end
		cells = find(overlap ~= 0);
		overlap = overlap(cells);
	else
		error('Wrong input! I expect an timelineNG-struct as input!!!');
	end
end