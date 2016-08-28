function [pm,pathNumber] = pmAddPath(pm,path)
% pmAddPath inserts a path into a path-matrix (pm)
%
% this function is for use with lineage-trees (lintrees)
% and it's data-structure.
%
%  [pm,pathNumber] = pmAddPath(pm,path)
%
%  ( helper function for lintreeAddEdge,
%    needed to insert a path in the pathmatrix pm)
%
% INPUT:
% pm            pathmatrix
% path          cellpath [frame ...]
%
% OUTPUT:
% pm            edited pathmatrix
% pathNumber    pathnumber of the added path
%
% Example: [pm,pathNumber] = pmAddPath(pm,[1 23;2 33])
% Adds a path of length two to the given pm.
%
%
% Copyright 04.2009 t.b.
pathNumber = 0;

m = size(pm,1);

% if we have a reversed path (running back in time ;) )
% we flip it (so we won't get the same path twice, on
% normal, one reverted)
if path(1,1) > path(end,1)
   path =  path(end:-1:1,:);
end

% first we check if the path is already
% inserted
for i=1:m
    if isequal(pm{i,3},path)
        pathNumber = i;
    end
end

% we check if we have an empty pathmatrix
if pathNumber==0 && isempty(pm)
    pm = {path(1,1),path(end,1),path,0};
    pathNumber = 1;
    
elseif pathNumber==0
    % if it is not empty, we add the path at the end
    pm{m+1,1} = path(1,1);
    pm{m+1,2} = path(end,1);
    pm{m+1,3} = path;
    pm{m+1,4} = 0;
    pathNumber = size(pm,1);
end
end