function [nearPaths,val] = getNearPath(tLng,time,position,varargin)
% getNearPath returns all paths near a given position at a given time
% 
%   [pathlist] = getNearPath(tLng,time,position,varargin)
%
%   optional argument: 
%     'radius'               search radius (around given position)
%                            default value set to 80
%
% example 
%
%   load manualTrackSmaller
%   time = 2
%   position = [50,50];
%   radius = 100; 
%   nearPath = getNearPath(tLng,time,position,'radius',radius)
%
% t.b. jan. 2010
radius = 80;
% ok, we check for input
i = 1;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'radius',   i=i+1; radius = varargin{i};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['getbestIndex.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
    end
    i = i+1;
end
    
    
% we search get the distance for our paths
[val,ind] = getbestIndex(tLng, 'position',position,...
    'time_a',time,'time_b',time);

% we get all cells near our position
nearCells = ind(val<radius);
val = val(val<radius);

% and all paths belonging to the near cells 
nearPaths = zeros(size(nearCells));
for iCell=1:length(nearCells)
    nearPaths(iCell) =tLng.cell(time).status(nearCells(iCell));
end