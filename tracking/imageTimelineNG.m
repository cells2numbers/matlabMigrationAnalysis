function cmask = imageTimelineNG(tLng, varargin)
	%  imageTimelineNG calculates the matrix 'cmask'
	%  from timeline tLng for a given time t
	%
	%  all cell's are numbered, optional argument [boolean]
	%  returns a binary 0-1 mask 	%
	%
	%
	%  cmask = imageTimelineNG(timeline, time, [boolean])
	%
	% INPUT:
	%           timeline     timelineNG struct
	%           time         time as int-value
	%
	% optional: boolean      0 or 1  
	%
	% OUTPUT:
	%           cmask        matrix with size timeline.size
	%
	% t.b. 02.2009
	%if isstruct(tLng)&&(strcmp(tLng.type,'timelineNG'))
		
        % binary image?
		BIN = 0;

		if nargin == 2
			time = varargin{1};
		elseif nargin == 3
			time = varargin{1};
			BIN = varargin{2};
		end
		
		
		cmask = zeros(tLng.image_size);
		
		% write each single cell to the cellmask
		% if bin is set, the cellmask is  returned as an binary image 
		for i=1:length(tLng.cell(time).cells)
			if BIN
				cmask(tLng.cell(time).cells{i}) = 1;
			else
				cmask(tLng.cell(time).cells{i}) = i;
			end
				
		end
% 	else
% 			%error('Wrong input! I expect a timelineNG-struct as input!!!');
%             warndlg('Have no cm to show! Are you sure you calculated them?','CM-Error');
%	end
end