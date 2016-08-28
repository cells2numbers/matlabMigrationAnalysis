function edges = lintreeGetEdges(lt,pos,level,node_width,varargin)
	% lintreeGetEdges collects all edges of an given lintree 
	%
	%  edges = lintreeGetEdges(lt,pos,level,node_width) 
	% 
	%
	% INPUT
	%
	%  lt           lintree
	%  pos          [time,y-position] position of the actual node
	%                (origin in the lintree-plot, not in the orig. images)
	%  level        which node-level do we have? we start in the first
	%                (this var. is needed for recursive-calls)
	%  node_width   the max. distance between the nodes on the last 
	%                (the highest/first) level
	%
	% OUTPUT
	%
	%   edges = n x 4 matrix, each row contains [ x1 y1 x2 y2] 
	%                         describing the edge [x1 y1]---[x2 y2]
	%
	%  Example:   edges = lintreeGetEdges(lt,[0,0],1,1)
	%
	%  the binary-tree could easily be plotted using a simple loop. 
	%  (MATLAB line-function expects the x-y position as vectors,
	%  see below)
	%
	% EXAMPLE:
	%
	%   edges =  lintreeGetEdges(lt,[0,0],1,1)
	%   figure();hold on;
	%	for i=1:size(edges,1)
	%	  line( [edges(i,2),edges(i,4)] ,[edges(i,1),edges(i,3)]   );
	%   end
	%
	%  THIS LOOP IS IMPLEMENTED IN lintreePlot.m. SEE HELP lintreePlot
	%  FOR MORE INFORMATION
	%  
	% Copyright t.b. 03.2009
	
	ed_son = [];
	ed_dau = [];
	edges = [];
	
	if isstruct(lt)&&(strcmp(lt.type,'linagenode'))
		
		% if we have a leaf, we return nothing
		
		if ~isempty(lt.son)
			% in pos_son the position of the son-node is stored
			%  pos_son = [time, y-position]
			%
			% we get the new position by dividing the distance to the 
			% father-node by 2. this is done by (.5)^level * node_width 
			pos_son =  [lt.son.cellcoordinates(1,1) ,  pos(2) - (.5)^level*node_width ];
			branch_son =  lintreeGetEdges(lt.son,pos_son,level+1,node_width);
			% 
			% in lt.cell and lt.son.cell we store the position  (in 
			% the images ) for current node and the end-node of our 
			% edge, pos and pos_son stores the x-y position in the 
			% lintreeplot
			ed_son = [[pos pos_son lt.sonpath] ;branch_son ];
		end	
			
		if ~isempty(lt.daughter)
			pos_dau =  [lt.daughter.cellcoordinates(1,1) ,  pos(2) + (.5)^level*node_width ];
			branch_dau =  lintreeGetEdges(lt.daughter,pos_dau,level+1,node_width);
			% in the next line we create the data! (here the cell-positions
			% are added!!!!
			ed_dau = [ [pos  pos_dau lt.daughterpath] ; branch_dau];
		end
		% now we add both edges
		edges = [ed_son;ed_dau];
	else
		disp('wrong input, collectEdges expects an lineagenode as input');
	end

