function [lt,pm] = lintreeAddEdge(lt,pm,cellcoordinates,path,varargin)
% function to insert a node/path in a given lintree
%
% [lt,pm] = lintreeAddEdge(lt,pm,cellcoordinates,path)
%
% INPUT:
% lt        lintree-struct
% pm        pathmatrix with all the paths in the lintree
% cellcoordinates
% path
%
% OUTPUT:
% lt        lintree-struct
% pm        pathmatrix with all the paths in the lintree
%
%
%
%  M.B. 04.2009, modified by t.b. in june 2010: added verbose messaging
%
%

VERBOSE  = 0;
i=1;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            case 'verbose',    i=i+1;  VERBOSE = varargin{i};
            otherwise
                argok=0;
        end
    else 
        argok=0;
    end
    if ~argok,
        disp(['lintreeAddEdge.m: WARNING! Ignoring invalid argument #' num2str(i)]);
        
    end
    i = i+1;
end

% first we check, if we have a linagenode and if the path isn't empty
isRightStruct = isstruct(lt)&&(strcmp(lt.type,'linagenode'));
isRightPath = ~isempty(path) && (size(path,1)>0);

if isRightStruct&&isRightPath
    % first we check, if we have an empty tree
    if isempty(lt.father)&&isempty(lt.son)&&isempty(lt.daughter)
        % assuming to be at the first frame / time
        [pm,pathNumber] = pmAddPath(pm,path);
        lt.cellcoordinates = cellcoordinates;
        lt.sonpath = pathNumber;
        % create new son-node
        lt.son = struct('type', 'linagenode', ...
            'name', [], ...
            'infos', [], ...
            'status', 1, ...
            'cellcoordinates', path(end,:), ...
            'mitosis', [], ...
            'father', lt, ...
            'son', [], ...
            'sonpath', [], ...
            'daughter', [], ...
            'daughterpath', []);
        if VERBOSE 
            fprintf('new son at time: %i \n',cellcoordinates(1));
        end
        
    elseif isequal(lt.cellcoordinates,cellcoordinates)
        % check if our path ends in this cell and the cell is empty
        % first we insert the son
        if  isempty(lt.sonpath)&&isempty(lt.daughterpath)
            [pm,pathNumber] = pmAddPath(pm,path);
            lt.sonpath = pathNumber;
            % create new son-node
            lt.son = struct('type', 'linagenode', ...
                'name', [], ...
                'infos', [], ...
                'status', 1, ...
                'cellcoordinates', path(end,:), ...
                'mitosis', [], ...
                'father', lt, ...
                'son', [], ...
                'sonpath', [], ...
                'daughter', [], ...
                'daughterpath', []);
            if VERBOSE 
                fprintf('new son at time: %i \n',cellcoordinates(1));
            end
            % if we have a son, we have to insert a daughter-node
        elseif isempty(lt.daughter) && ~isequal(pm{lt.sonpath,3},path)
            [pm,pathNumber] = pmAddPath(pm,path);
            lt.daughterpath = pathNumber;
            % create new daughter-node
            lt.daughter = struct('type', 'linagenode', ...
                'name', [], ...
                'infos', [], ...
                'status', -1, ...
                'cellcoordinates', path(end,:), ...
                'mitosis', [], ...
                'son', [], ...
                'sonpath', [], ...
                'father', lt, ...
                'daughter', [], ...
                'daughterpath', []);
            if VERBOSE 
                fprintf('new daughter at time: %i \n',cellcoordinates(1));
            end
            
        else
            fprintf('lintreeAddEdge: failure, I  want two children, not more, not less, but please: no twins... time: %i  \n',cellcoordinates(1));
        end
        
    elseif lt.cellcoordinates(1) <= cellcoordinates(1)
        % check if we have a son and / or daughter to follow
        if ~isempty(lt.son)
            [lt.son,pm] =  lintreeAddEdge(lt.son,pm,cellcoordinates,path,...
                'verbose',VERBOSE);
        end
        
        if ~isempty(lt.daughter)
            [lt.daughter,pm] =  lintreeAddEdge(lt.daughter,pm,cellcoordinates,path,...
                'verbose',VERBOSE);
        end
    else
        % disp('error in lintreeAddEdge.m: what should i do? ( I ran out of time or cannot find my mitosis....)');
        
    end
else
    disp('wrong input, lintreeAddEdge expects an lineagenode and a path longer than 1 as input');
end