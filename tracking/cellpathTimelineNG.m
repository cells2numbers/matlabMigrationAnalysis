function path = cellpathTimelineNG(tLng,cell,varargin)
%   path = cellpathTimelineNG(tLng,time,cell,varargin)
%
% cellpath returns the path for a specific
% cell at a given time as a two-dim vector [time,cell]
%
% accepted/optional paramters:
%
% threshold / threshold_f   double in 0-1    set the forward-threshold
% threshold_b               double in 0-1    set the backward-threshold
% time                      int              time / frame
% backward                                   direction to search
% forward                                    direction to search
% both                                       should we care about the
%                                            past and the future?
% singlecell                 int
%
%
% TODO:
% add parameter to check if we have only one successor / predecessor
%
%
% EXAMPLE:
% to return the the path for the first cell in the first frame, use
% (it returns the cellpath in forward direction, not using the overlap
% from frame i+1 to i)
%
%   path = cellpath(tLng,1)
%
% to create a backward path beginning with cell 10 at frame 100 using
% past and future information with two threshold values, type
%
%  path =
%  cellpath(tLng,10 ,'time',100 ,'backward','both',...
%  'threshold_f',0.7,'threshold_b',0.8)
%
% t.b. 03.2009

if isstruct(tLng)&&(strcmp(tLng.type,'timelineNG'))
    threshold = 0;
    threshold_b = 0;
    backward = 0;
    forward =1;
    both = 0;
    time = 0;
    singleCell = 0;
    % check a threshold is given
    i = 1;
    while i<=length(varargin),
        argok = 1;
        if ischar(varargin{i}),
            switch varargin{i},
                % argument IDs
                case 'threshold',     i=i+1; threshold = varargin{i};
                case 'time',          i=i+1; time = varargin{i};
                case 'backward',      backward = 1; forward = 0;
                case 'forward',       backward = 0; forward  = 1;
                case 'both',          both = 1;
                case 'threshold_b',   i=i+1; threshold_b = varargin{i};
                case 'threshold_f',   i=i+1; threshold = varargin{i};
                case 'singlecell',    i=i+1; singleCell = varargin{i};
                otherwise
                    argok=0;
            end
        else
            argok = 0;
        end
        if ~argok,
            disp(['cellpathTimelineNG.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
            
        end
        i = i+1;
    end
    % we have two different thresholds, one for backward direction, one
    % for forward direction. the optional arguments threshold and
    % threshold_f are both input-variables for one internal threshold
    
    % check if backward is set without a time, then we have to set time
    % to time_max
    if backward&& time==0
        time=tLng.time_max;
    elseif time==0
        time = 1;
    end
    
    
    % OLD VERSION OF PARAMETER INPUT
    %
    %		if length(varargin) == 1
    %			threshold = varargin{1};
    %		elseif length(varargin) == 1
    %			threshold = varargin{1};
    %			backward = varargin{2};
    %		end
    
    % to check if keep on following the path, we have to chek
    % the predecessor / successors. for easier handle, some
    % bool-def's
  
    
    
    % get values for successors
    % the second dimension returns the same pixels
    % as an  value between 0,..,1
    
    % the first node in the path is the given cell
    path = [time,cell];
    
    % check if we run throug the timeline backwards...
    %
    % ---------------------------backward------------------------------
    if backward&&~both
        pred = tLng.cell(time).predecessor{cell};
        % timewarp :)
        time = time - 1;
        
        % until we lose our cell we keep on tracking
        % the cell need's a overlap > threshold
        
        %while ~isempty(prep)&&( max(prep(:,2))>threshold_b )
        %  prepOK =  ~isempty(prep)&&...
        %( max(prep(:,2))>threshold_b );

        while spOK(pred,threshold,singleCell)
            % from all successors we choose the one with the
            % biggest overlap...
            %
            % TODO TRACKING: here we have to find mitoses...
            %
            % get values for predecessors
            % the second dimension returns the same pixels
            % as an  value between 0,..,1, so we choose prep(:,2)
            [val,pos] = max(pred(:,2));
            % set new path-node
            path(size(path,1)+1,:) = [time,pred(pos,1)];
            % get next successor
            pred = tLng.cell(time).predecessor{pred(pos,1)};
            % time-warping around.... again ;)
            time = time - 1;
            % update status-bool
          
        end
        %------------------------------------------------------------------
        % -----------------------------------forward-----------------------
    elseif forward&&~both
        % if not backward, we run forward
        % read all successors (precalculated)
        succ = tLng.cell(time).successor{cell};
        
        % timewarp :)
        time = time +1;
        
        % until we lose our cell we keep on tracking
        % the cell need's a overlap > threshold
        %while ~isempty(succ)&&( max(succ(:,2))>threshold )
        while spOK(succ,threshold,singleCell)
            % from all successors we choose the one with the
            % biggest overlap...
            %
            % TODO TRACKING: here we have to find mitoses...
            %
            
            [val,pos] = max(succ(:,2));
            % set new path-node
            path(size(path,1)+1,:) = [time,succ(pos,1)];
            % get next successor
            succ = tLng.cell(time).successor{succ(pos,1)};
            time = time + 1;
          
        end
        %------------------------------------------------------------------
        %-----------------forward using both directions--------------------
    elseif both && forward
        
        % we run forward, but take a look in the mirror (we look one
        % frame back)
        succ = tLng.cell(time).successor{cell};
        % so we collect all predecessors from all successors
        %
        %-------this code can be ported to a mitose-tracker----------
        %--------------------- (i guess)-----------------------------
        % (hmm, but it seem's to be less usefull at the moment....)
        pred = [];
        for i=1:size(succ,1)
            pred = [pred;tLng.cell(time+1).predecessor{succ(i,1)}];
        end
        % but wait: we have to abort, if we have 
        % another predecessor cell than our current cell if singlecell
        % option is given, that is checked in spOK
      
        %  now a timewarp :) and we can start
        time = time +1;
    
        while spOK(succ,threshold,singleCell) && spOK(pred,threshold_b,singleCell)
            % problem: now we can have predecessors with successors other then
            % our current cell....
            if ~isempty(pred)
                pred = pred(pred(:,1)==cell,:);
            end
            % problem fixed ;), now a timewarp :) and we can start
            % get cell with max. overlap
            [val,pos] = max(succ(:,2));
            % look for the
            pred = tLng.cell(time).predecessor{succ(pos,1)};
            [val_p,pos_p] = max(pred(:,2));
            
            
            % now we check the overlap, if it's smaller then our
            % threshold_b, we add a path
            if (val_p > threshold_b )
                path(size(path,1)+1,:) = [time,succ(pos,1)];
            else % if not, we abort the loop
                threshold_b = 1;
            end
            % get next successor
          
            succ = tLng.cell(time).successor{succ(pos,1)};
            pred = [];
            for i=1:size(succ,1)
                pred = [pred;tLng.cell(time+1).predecessor{succ(i,1)}];
            end
            %				pred = pred(pred(:,1)==succ(pos,1),:);
            
            time = time +1;
           
        end
        %------------------------------------------------------------------
        %-------------------------------forward using both directions------
    elseif both && backward
        
        % we run forward, but take a look in the mirror (we look one
        % frame back)
        pred = tLng.cell(time).predecessor{cell};
        % so we collect all predecessors from all successors
        %
        %-------this code can be ported to a mitose-tracker----------
        %--------------------- (i guess)-----------------------------
        % (hmm, but it seem's to be less usefull at the moment....)
        succ = [];
        for i=1:size(pred,1)
            succ = [succ;tLng.cell(time-1).successor{pred(i,1)}];
        end
       
        % problem fixed ;), now a timewarp :) and we can start
        time = time -1;
        %while  ~isempty(succ)&&( max(succ(:,2))>threshold )&& ~isempty(pred)&&( max(pred(:,2))>threshold_b )
        
        while spOK(succ,threshold,singleCell) && spOK(pred,threshold_b,singleCell)
             % problem: now we can have predecessors with successors other then
             % our current cell....
             if ~isempty(succ)
                 succ = succ(succ(:,1)==cell,:);
             end
            % get cell with max. overlap
            [val,pos] = max(pred(:,2));
            % look for the
            succ = tLng.cell(time).successor{pred(pos,1)};
            [val_p,pos_p] = max(succ(:,2));
            
            
            % now we check the overlap, if it's smaller then our
            % threshold_b, we add a path
            if (val_p > threshold)
                path(size(path,1)+1,:) = [time,pred(pos,1)];
            else % if not, we abort the loop
                threshold_b = 1;
            end
            % get next successor
            pred = tLng.cell(time).predecessor{pred(pos,1)};
            succ = [];
            for i=1:size(pred,1)
                succ = [succ;tLng.cell(time-1).successor{pred(i,1)}];
            end
            %				pred = pred(pred(:,1)==succ(pos,1),:);
            
            time = time -1;
           
        end
        
    else
        disp('error, which method should i use? foward, backward,... tell me!' );
    end
else % if we have no tLng-struct
    error('Wrong input! I expect an timelineNG-struct as input!!!');
end
end

% try it as an helper function
    function checkOK = spOK(sp, threshold_b, singleCell)
    if singleCell
        checkOK = ~isempty(sp)&&( max(sp(:,2))>threshold_b ) && ...
             size(sp,1) == 1;
    else
        checkOK = ~isempty(sp)&&( max(sp(:,2))>threshold_b );
    end
      
    end