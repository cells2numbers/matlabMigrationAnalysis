function [am] = amAddEdge(tLng,am,pm,path1,path2,varargin)
% amAddEdge add's an edge into an adjacenc-matrix
%
%  [am] = amAddEdge(tLng,am,pm,path1,path2,varargin)
%
%  INPUT
%  am       adjacency matrix, if empty, it will be created
%           ( is returnded as an sparse-matrix to safe memory)
%  pm       path matrix (containing the path's path1 and path2
%  path1    connected nodes (this is a little weired, cause we 
%  path2    store a path in our node.... )
%
%  OPTIONAL ARGUMENTS
%  weight_f        weight for the connection path1 -> path2
%  weight_b        weight for the connection path2 -> path1
%
% 
%  for the weights you can use what you want, here we give one 
%  way to store  the information as implemented in createGraph
% 
%    sign rec.thresh
%
%
%    +/-  sign   = forward (+) or backward (-) path
%    int  rec    = recursion-depth
% double  thresh = threshold from pathx -> pathy 
%
% Example: 
%   +5.23 
% this is a forward path on the fifth recursion level
% with a threshold (or overlapp) with 23%
%
%
% t.b. 05.2009

% we check for optional input argument trehs 
% ( the edge-weights)

% we set a default value for weights

weight_f = 1;
weight_b = 1;

% we check for input arguments and set what we get
i=1;
while i<=length(varargin),
	argok = 1;
  if ischar(varargin{i}), 
	  switch varargin{i},
		  % argument IDs
		  case 'weight_f',   i=i+1; weight_f = varargin{i};
		  case 'weight_b',   i=i+1; weight_b = varargin{i};
          otherwise, argok=0;
	  end
  else
	  argok = 0;
  end
  if ~argok,
	  disp(['amAddEdge : WARNING! Ignoring invalid argument #' num2str(i+2)]);
  end
  i = i+1;
end

% we get both paths from the pathmatrix pm
p1 = pm{path1,3};
p2 = pm{path2,3};

% now we check which path is comes first ( in temporal order)
% and calculate the overlap, so first we init the overlaps
overlappP1P2 = 0;
overlappP2P1 = 0;
 
 

% check temporal order
if p1(end,1) + 1  ==  p2(1,1)
    % for better handling we copy the times and cellnumbers
    timep1 = p1(end,1);
    cellp1 = p1(end,2);
    timep2 = p2(1,1);
    cellp2 = p2(1,2);
    % we need the overlap from p1 to p2 
    succ = tLng.cell(timep1).successor{cellp1};
    
    % if we have more then one successor cell, we have to 
    % find the cell with number p2(1,2)
    posP = find(succ(:,1) == cellp2); 
    overlappP1P2 = succ(posP,2);

    % same vice versa with overlap from p2 to p1
    pred = tLng.cell(timep2).predecessor{cellp2};
    
    if isempty(pred)
      overlappP2P1  = 0;
    else
        posS = find(pred(:,1) == cellp1);
        overlappP2P1 = pred(posS,2);
    end
    weight_f =  overlappP1P2;
    weight_b = -overlappP2P1; 
    
elseif p2(end,1) + 1 == p1(1,1)
    timep1 = p1(1,1);
    cellp1 = p1(1,2);
    timep2 = p2(end,1);
    cellp2 = p2(end,2);
    % we need the overlap from p1 to p2
    succ = tLng.cell(timep2).successor{cellp2};
    
    if ~isempty(succ)
    
    % if we have more then one successor cell, we have to 
    % find the cell with number p2(1,2)
  
    posP = find(succ(:,1) == cellp1);
    overlappP2P1 = succ(posP,2);

    % same vice versa with overlap from p2 to p1
    pred = tLng.cell(timep1).predecessor{cellp1};
    posS = pred(:,1) == cellp2;
    overlappP1P2 = pred(posS,2);

    weight_f = -overlappP1P2;
    weight_b =  overlappP2P1;
    else 
        fprintf('error inserting edge  from %i to  %i \n',path1,path2);
        fprintf('wrong successor / predecessor? you could \n');
        fprintf('raise nMax in correctTimelineNG \n');
    end
  else
   disp('error');
   %weight_f = 0;
   %weight_b = 0;
end 
%
% we have to check the weights to handle some errors caused by missing 
% and / or wrong overlaps stored in the timeline-struct
%
wbOK = size(weight_b) == 1;
wfOK = size(weight_f) == 1;

if wbOK
    if wfOK
        am(path1,path2) = weight_f;
        am(path2,path1) = weight_b;
    else
        fprintf('error in amAddEdge at frame %i in cell %i. ',timep1,cellp1)
        fprintf('cannnot calculate the weights. wrong overlap in the timeline?\n');
        weight_f = 1;
        
    end
else
    fprintf('error in amAddEdge at frame %i in cell %i. ',timep2,cellp2);
    fprintf('cannnot calculate the weights. wrong overlap in the timeline?\n');
    weight_b = 1;
    
end
am(path1,path2) = weight_f;
am(path2,path1) = weight_b;
am = sparse(am);