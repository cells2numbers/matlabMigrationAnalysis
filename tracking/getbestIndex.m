function [val,ind] = getbestIndex(tLng, varargin)
% bestIndex looks for the next neighbour of cell_a
% given in image time_a in image time_b. it returns
% the index-vector
%
%  [val,ind] = getbestIndex(tLng, cell_a, time_a, time_b)
%
% INPUT:
%   tLng     timelineNG struct
%   cell_a   int
%   time_a   int
%   time_b   int
%
% t.b.
%
%
%
%   another input was added january 2010, input can given 
%   optional argument
%
%
%
%   load manualTrackSmaller
%
%   [val,ind] = getbestIndex(tLng, 'position',[0,0],...
%               'time_a',1,'time_b',1);
%
%   nearCells = ind(val<50);
%   nearPaths = [];
%   
%   for iCell=nearCells
%      nearPaths = [nearPaths,tLng.cell(1).status(iCell)];
%   end
%
%   extendedWatchmenGui(tLng,imInfos,am,pm,fm,'pathlist',nearPaths)
%

position  = 0;
time_a = 0;
time_b = 0;

if isempty(varargin)
    error('what? no input?, what a DAU');
end


% for compability with the first version we first
% check for old input format
%
%  getbestIndex(tLng, cell_a, time_a, time_b) or
%  getbestIndex(tLng, cell_a, time_a)
%

if length(varargin) == 3 && isfloat(varargin{1}) &&...
        isfloat(varargin{2}) && isfloat(varargin{3})
    
    cell_a = varargin{1};
    time_a = varargin{2};
    time_b = varargin{3};
elseif length(varargin) == 2 && isfloat(varargin{1}) &&...
        isfloat(varargin{2})
    %  getbestIndex(tLng, cell_a, time_a)
    cell_a = varargin{1};
    time_a = varargin{2};
    time_b = time_a + 1;
else
    i = 1;
    while i<=length(varargin),
        argok = 1;
        if ischar(varargin{i}),
            switch varargin{i},
                % argument IDs
                case 'cell_a',   i=i+1; cell_a = varargin{i};
                case 'time_a',   i=i+1; time_a = varargin{i};
                case 'time_b',   i=i+1; time_b = varargin{i};
                case 'position', i=i+1; position = varargin{i};
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
end

if time_b == 0
    time_b = time_a + 1;
end

if isstruct(tLng)&&(strcmp(tLng.type,'timelineNG'))
    
    % for the difference vector we need the center many many times :)
    if isequal(position,0)
        cells = repmat(tLng.cell(time_a).centroid(cell_a,:), length(tLng.cell(time_b).cells),1);
    else
        cells = repmat(position, length(tLng.cell(time_b).cells),1);
    end
    
    % now we can calculate the distance (difference) vector
    cell_diff =  tLng.cell(time_b).centroid - cells;
    
    cell_dist = sqrt( sum( cell_diff.^2') );
    %
    % here we could use norm(cell_diff,2)
    %
    % 
    % and we sort the distances and return the permutations
    [val,ind] = sort(cell_dist);
    
else
    
    error('Wrong input! I expect an timelineNG-struct as input!!!');
end
end

