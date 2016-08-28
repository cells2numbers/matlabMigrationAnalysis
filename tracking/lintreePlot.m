function [edges] = lintreePlot(lt,scalefactor)
% The function lintreePlot plots a lintree as an bintree.
%
% [edges] = lintreePlot(lt)
%
% INPUT:
% lt        lintree-struct
%
% OUTPUT:
% edges     the edges of the tree
%
% EXAMPLE:
%  [edges] = lintreePlot(lt)
%
% Copyright t.b. 04.2009
%

if ~exist('scalefactor','var')
    scalefactor = 1;
end

% first we check, if we have a linagenode and if the path isn't empty

if isstruct(lt)&&(strcmp(lt.type,'linagenode'))
	edges = lintreeGetEdges(lt,[0,0],1,4);
	%[m,n] = size(edges);
	
    % we need to find the root-edge starting in (x,0)
    if isequal(edges(1,2),0)
       edges(1,2) = edges(1,4); 
    end
    
    edges = edges.*scalefactor;
    
    
	line( [edges(1,2),edges(1,4)] ,[ edges(1,1),edges(1,3)]   );
	hold on;
	for i=1:size(edges,1)
		line( [edges(i,2),edges(i,4)] ,[edges(i,1),edges(i,3)]   );
	end
	hold off;
	
else
	disp('wrong input, lintreeAddEdge expects an lineagenode as input');
end