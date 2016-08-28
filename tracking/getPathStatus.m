function [statusVector,statusInt] = getPathStatus(pm,pathNr,varargin)
% getPathStatus returns the status of an cell
%
%  
% [statusVector,statusInt] = getPathStatus(pm,pathNr,varargin)
%
%  Optionale arguments:
%
%   as optional argument an integer value i can be given
%   ( allowed values see below, here we accept only 
%     2^n values) 
% 
%
%   
% 
%
%  corresponding           status-flag
%  int-value
%
%      0                      NOT SET
%      1                     'path' 
%      2                     'mitosis'
%      4                     'border begin'
%      8                     'border end'
%     16                      NOT SET 
%     32                     'corrected'
%     64                     'ending' 
%    128                     'beginning' 
%    256                     'lost begin' 
%    512                     'lost end' 
%   1024                     'coupled'  
%
%
%  the status is a sum of the numbers, for example:
%  a cell in an cellpath that is running out of the 
%  image get's the status 1 + 4 = 5. 
%
%  a cell should not belong to a path or a mitosis, this makes
%  it simple to check for mitosis status, you can check for
%  an even status ;) 
%
%
% see also getCellStatus, setPathStatus
%
%
%
% tim becker june 2009



atomStatus = -1;
if length(varargin) ==1
    atomStatus = varargin{1};
elseif length(varargin) > 1
    atomStatus = varargin{1};
    fprintf('getPathStatus: ignoring input-arguments,...\n');
end

% we check for coorect input 
%
% is asked for status 0?
if  (isnumeric(log2(atomStatus)) && atomStatus == 0)
    atomStatus = 0;
    % if not, do we have a atom status flag?
elseif  isnumeric(log2(atomStatus)) && log2(atomStatus) < 11 ...
        && atomStatus ~=-1
    atomStatus = uint32(log2(atomStatus)) +2;
elseif atomStatus ==-1
    % wrong atom input
    atomStatus = -1;
else
     % wrong atom input
    fprintf('getPathStatus: ignoring atom input-arguments,...\n');
    atomStatus = -1;
end


% we get the status
cellStatus = pm{pathNr,4};
VERBOSE = 0;

% init. ouf output var.
statusVector = zeros(1,12);
iStatus = 11;
% status message, just for verbose information
statusMessages = {'  0: NOT SET (prior: clean) ',...
    '   1: path',...
    '   2: mitosis',...
    '   4: borderBegin ',...
    '   8: borderEnd',...
    '  16: NOT SET (prior: lost) ',...
    '  32: corrected',...
    '  64: end',...
    ' 128: begin',...
    ' 256: lostBegin',...
    ' 512: lostEnd',...
    '1024: coupled',...
    };

% maxStatus set stores the value for the bigges single value,
% at the moment ist is 2^10. 
%
% this is not the biggest statusInt value, this would be 
% 1 +2 + 4 + ... + 1024 = 2047
maxStatus = 1024;

if cellStatus==0 
    %fprintf('cell not tracked yet \n');
else
    while cellStatus >= 1
        % we have to store the flag with index iStatus+1 because 
        % at position 1 we store flag 0 = 'clean'
        statusVector(iStatus+1) = fix(cellStatus / maxStatus);
        cellStatus = rem(cellStatus,maxStatus);
        maxStatus = maxStatus /2;
        iStatus = iStatus - 1;
    end
    
    % now print out the status 
    %for i=1:12
    %    if statusVector(i)
    %        disp(statusMessages{i});
    %    end
    %end
end

if  isequal(pm{pathNr,4},0)
%    ~isempty(pm{pathNr,4}) && 
    statusInt = 0;
else
    vstatus = [0,2.^(0:10)];
    statusInt =  statusVector*vstatus';
end

% are we asked to return an atom-status?
if atomStatus ~=-1
    statusInt = statusVector(atomStatus);
end