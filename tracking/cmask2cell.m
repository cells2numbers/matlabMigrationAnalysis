function[cmask_cell,cmask_cent] = cmask2cell(cmask)
	% cmask2cell stores a cmask-structure (matrix, see )
	% as many single cells in cell representation
	% 
	% INPUT: 
	%   cmask (NxM matrix containing L cells)
	% 
	% OUTPUT: 
	%   cmask_cell ( cell array with index vectors [i,j] (unit16) )
	%
	% t.b. 
	%
	
	% first we need the number of cells
	% because the fucking numeration is not correct, we have
	% to do it again... first we "guess"
	% because the number are too high, we cann set:
	cell_number = max(max(cmask));
	real_cell_number =0;
	
	% init output variable as cell-vektor
	cmask_cell = cell(1);
	cmask_cent = zeros(1,2);
	
	% store only index-vectors for each cell, not the whole matrix
	for number=1:cell_number
		% first we check if we find a cell with 
		% numeration 'number' 
		if ~isempty(find(cmask == number))
			% update counter  for real cell number
			real_cell_number = real_cell_number +1;
			[i,j] = find(cmask == number);       % find pixel for cell number
			cmask_cell{real_cell_number} = uint32(find(cmask == number));
			cmask_cent(real_cell_number,:) = mean([i,j]);
		end
	end
	
end