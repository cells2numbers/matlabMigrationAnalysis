function [am,pm,eList,tLng] = fillEList(tLng,varargin)
% fillElist calculates am, pm and the edge list 
%
%  [am,pm,eList,tLng] = fillEList(tLng,varargin)
%
%   optional arguments:
%
%   RecLimit           500 matlab-standard, 750 default value
%   VERBOSE            some (interesting) messages printed out
%   fillup             should not connected cells be searched 
%                      and labeled? this is the default behavior
%
%
% Be carefull: we set the max. recursion limit  from
% 500 up to 750!! you can modify it using the optional
% argument 'RecLimit', see example
%
%
% Example:
%   load manualTrackSmaller;
%   [am,pm,eList,tLng] = fillEList(tLng);
%
%   [am,pm,eList,tLng] = fillEList(tLng,'verbose',1,'RecLimit',600);
%
%   [am,pm,eList,tLng] = fillEList(tLng,'verbose',1,'fillup',0);
%
% 
%  see also setPathStatus, createGraph2, showGraph3D, showGraph
%
% t.b. 06.2009
%
% FILLUP-flag corrected 08.2009,

RecLimit = 750;
VERBOSE = 0;
FILLUP = 1;

i = 1;
% we check for all input arguments
%
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'VERBOSE',         i=i+1; VERBOSE = varargin{i};
            case 'verbose',         i=i+1; VERBOSE = varargin{i};
            case 'Verbose',         i=i+1; VERBOSE = varargin{i};
            case 'RecLimit',        i=i+1; RecLimit = varargin{i};
            case 'fillup',          i=i+1; FILLUP = varargin{i};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['fillEList.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
    end
    i = i+1;
end
set(0,'RecursionLimit',RecLimit);

% init. of needed vars
am = [];
pm = []; % this becomes an array

% we create a new path-matrix, new path
% so we delete the old paths in tLng
% (stored as status var. tLng.cell(frame).status(cell)
 tLng = resetstatus(tLng);
 
if VERBOSE; tic; end
% we fill the adjacency matrix am and the path-matrix pm
% from bottom to top
for i=1:tLng.cell(1).number
    [am,pm] = createGraph2(tLng,1, i,am,pm,'max_recursion',RecLimit-5);
    % if we have to add some single path, they are not connected,
    % we have to do it here
    if isequal(size(am,1), size(pm,1)-1)
        am(end+1,end+1) = 0;
        if VERBOSE; fprintf('\r added single path in %i \n',i); end;
    end
    if VERBOSE; fprintf('\rcell %i \n',i); end;
end

% now we fill it up from top to bottom

for i=1:tLng.cell(end).number
    
    [am,pm] = createGraph2(tLng,tLng.time_max,i,am,pm,'max_recursion',RecLimit-5,'backward');
    % if we have to add some single path, they are not connected,
    % we have to do it here
    if isequal(size(am,1), size(pm,1)-1)
        am(end+1,end+1) = 0;
        if VERBOSE; fprintf('\r added single path in %i \n',i); end;
    end
    if VERBOSE; fprintf('\r cell %i \n',i); end;
end

% now we calculate the edge list
eList = getEdgeList(am);


N = size(pm,1);

% now we write the status, first we look for beginning paths'....
for i=1:N
    if eList(i,2) == 0
        
        % we check if we have a cellpath beginning at time 1
        if pm{i,1}==1
            
            [pm, tLng] = setPathStatus(tLng,pm,i,'begin',1,'path',1) ;
            %fprintf('new path in path %i in frame 1 \n',i);
            % we check if we have a cellpath beginning at a border
        elseif nearBorder(tLng,pm{i,1},pm{i,3}(1,2),20);
            [pm, tLng] = setPathStatus(tLng,pm,i,'path',1,'borderBegin',1) ;
            %fprintf('new path %i  beginning at  "border" \n',i);
        else
            [pm, tLng] = setPathStatus(tLng,pm,i,'path',1,'lostBegin',1) ;
            %fprintf('found new path in path %i \n',i);
        end 
    else
        [pm, tLng] = setPathStatus(tLng,pm,i,'path',1) ;
    end
    
    if eList(i,1) == 0
        
        if pm{i,2}==tLng.time_max
            %         fprintf('found end path in path %i in frame 209 \n',i);
            [pm, tLng] = setPathStatus(tLng,pm,i,'end',1,'path',1) ;
            
        elseif nearBorder(tLng,pm{i,1},pm{i,3}(1,2),10);
            %          fprintf('found ending cell in path %i at border \n',i);
            [pm, tLng] = setPathStatus(tLng,pm,i,'path',1,'borderEnd',1) ;
            %            fprintf('found ending cell in path %i at border \n',i);
        else
            % fprintf('found ending cell in path %i \n',i);
            [pm, tLng] = setPathStatus(tLng,pm,i,'path',1,'lostEnd',1) ;
        end
    else
        [pm, tLng] = setPathStatus(tLng,pm,i,'path',1) ;
    end
end

%eList = getEdgeList(am);

%   or inserted cells...)
if FILLUP
    if VERBOSE
        fprintf(' now i fill up all missing cells, or better: i try...');
    end
    % now we fill up all missing cells without connectivity
    for j=1:tLng.time_max
        for i=1:tLng.cell(j).number
            
            
            if getCellStatus(tLng,pm,j,i,0)
                 
                 size1 = size(pm,1);
                [am,pm] = createGraph2(tLng,j, i,am,pm,'max_recursion',RecLimit-5);
                % if we have to add some single path (not connected)
                % we have to do it here
                if isequal(size(am,1), size(pm,1)-1)
                    am(end+1,end+1) = 0;
                end
                
                % we have to add the status flag immediately
                for iPath=size1+1:1:size(pm,1)
                    [pm,tLng] = setPathStatus(tLng,pm,iPath,...
                        'path',1,'lostBegin',1,'lostEnd',1) ;
                    if VERBOSE 
                        fprintf('\r added single path in %i %i \n',j,i); 
                    end;
                end
                                
            end
        end
    end
end

% calculate the edge list 
eList = getEdgeList(am);

if VERBOSE
    nCellsPM = 0;
    nCellsTLNG = 0;
    % cells in the path-matrix
    for i=1:size(pm,1)
        nCellsPM = size(pm{i,3},1)+ nCellsPM;
    end
    
    % cells in the timeline
    for i=1:tLng.time_max
        nCellsTLNG = tLng.cell(i).number + nCellsTLNG;
    end
    
    % some (debug) information
    if VERBOSE
        fprintf(' filled in %5.2f percent of the cells \n',100 * nCellsPM / nCellsTLNG);
        fprintf(' ( %i cells ) \n',nCellsPM);
        fprintf(' the calculation took %5.2f seconds \n',toc);
    end
end


  