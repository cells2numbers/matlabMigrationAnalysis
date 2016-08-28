function [pm,tLng,cellStatus] = setPathStatus(tLng,pm,pathNr,varargin)
% setPathStatus sets the status for a cellpath
%
% [pm,tLng,newStatus] = setPathStatus(tLng,pm,pathNr,varargin)
%
%  newStatus can be an integer or one of the follwing flags
%  (it will be added to the actual int-value if needed)
%  
%  corresponding           status-flag
%  int-value
%
%      0                      NOT SET (prior: clean)
%      1                     'path' 
%      2                     'mitosis'
%      4                     'borderBegin'
%      8                     'borderEnd'
%     16                      NOT SET (prior: lost)
%     32                     'corrected'
%     64                     'end' 
%    128                     'begin' 
%    256                     'lostBegin' 
%    512                     'lostEnd' 
%   1024                     'coupled' 
%
%
%
%  all int-values will be added to one single value
% 
%  Example: reset of all "correct" flags
%
%  
%  [correctList,correctTimes] = evaluatePathStatus(pm,32);
% 
%  for i=1:length(correctList)
%      [pm,tLng,cellStatus] = setPathStatus(tLng,pm,correctList(i),...
%                             'corrected', 0);
%  end
%
%
%
%  see also getPathStatus.m, evaluatePathStatus.m
%
% tim becker 06.2009


% we get the status of the cell, this is needed to calculate the 
% new status-value... (the new flag is added to this value)
% !!could be done much easier using dec2bin!!

statusVector = zeros(1,12);
cellStatus = pm{pathNr,4};
maxStatus = 1024;
iStatus = 11;

newStatus = 0;

while cellStatus >= 1
    statusVector(iStatus+1) = fix(cellStatus / maxStatus);
    cellStatus = rem(cellStatus,maxStatus);
    maxStatus = maxStatus /2;
    iStatus = iStatus - 1;
end


i = 1;

if length(varargin) == 1 && ~isstr(varargin{1})
    newStatus = varargin{1};
else
    while i<=length(varargin),
        argok = 1;
        if ischar(varargin{i}),
            switch varargin{i},
                % argument IDs
                case 'clean',      i=i+1;statusVector(1)  = varargin{i};
                case 'path',       i=i+1;statusVector(2)  = varargin{i};
                case 'mitosis',    i=i+1;statusVector(3)  = varargin{i};
                case 'borderBegin',i=i+1;statusVector(4)  = varargin{i};
                case 'borderEnd',  i=i+1;statusVector(5)  = varargin{i};
                case 'lost',       i=i+1;statusVector(6)  = varargin{i};
                case 'corrected',  i=i+1;statusVector(7)  = varargin{i};
                case 'end',        i=i+1;statusVector(8)  = varargin{i};
                case 'begin',      i=i+1;statusVector(9)  = varargin{i};
                case 'lostBegin',  i=i+1;statusVector(10) = varargin{i};
                case 'lostEnd',    i=i+1;statusVector(11) = varargin{i};
                case 'coupled',    i=i+1;statusVector(12) = varargin{i};
                otherwise
                    argok=0;
            end
        end
        if ~argok,
            disp(['setPathStatus.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
        end
        i = i+1;
    end
end


% if the new status is given as integer (newStatus ~=0) 
% we set it directly
if newStatus
    cellStatus = newStatus;
else 
    
    if cellStatus==0
        %fprintf('cell not tracked jet \n');
        statusVector(1) = 1;
    end
    
    % we create a vector [0,1,2,4, ... , 1024]
    tmpVector = [0,2.^(0:10)];
      
    cellStatus = sum(tmpVector .* statusVector);
end

% the new status is saved in the path-matrix
%  ( change in pm-struct august 2009 ) 

pm{pathNr,4} = cellStatus;

% we update the timeline struct 
% ( the status flag for each cell in the cellpath 
%   is set to the pathNr)
cpath = pm{pathNr,3};
for iCell = 1:size(cpath,1)
    cellNr = cpath(iCell,2);
    frameNr = cpath(iCell,1);
    tLng.cell(frameNr).status(cellNr) = pathNr;
end




