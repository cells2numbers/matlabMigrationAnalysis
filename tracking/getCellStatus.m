function Vector = getCellStatus(tLng,pm,time,cellNr,varargin)
% getCellStatus returns the status of an cell
%
%  cellStatus = getCellStatus(tLng,time,cellNr,varargin)
% 
%  corresponding           status-flag
%  int-value
%
%      0                     'clean'
%      1                     'path' 
%      2                     'mitose'
%      4                     'borderIn'
%      8                     'borderOut'
%     16                     'lost'
%     32                     'corrected'
%     64                     'ending' 
%    128                     'beginning' 
%    256                     'xxx' 
%    512                     'xxx' 
%   1024                     'xxx' 
%
%  the status is a sum of the numbers, for example:
%  a cell in an cellpath that is running out of the 
%  image get's the status 1 + 4 = 5. 
%
%  a cell should not belong to a path or a mitosis, this makes
%  it simple to check for mitosis status, you can check for
%  an even status ;) 
%
% see also getPathStatus, setPathStatus
%
%
%
% tim becker june 2009

% we get the status

testNr = -1;
if ~isempty(varargin)
    testNr = varargin{1};
end

pathNr = tLng.cell(time).status(cellNr);
if pathNr == 0
    cellStatus = 0; 
else
   
    
    cellStatus = pm{pathNr,4};
end
statusVector = zeros(1,11);
iStatus = 11;
statusMessages = {'  0: clean ',...
    '   1: cellpath',...
    '   2: mitosis',...
    '   4: Norder In',...
    '   8: Border Out',...
    '  16: lost cell',...
    '  32: corrected',...
    '  64: ending',...
    ' 128: beginning',...
    ' 256: flag is set but not defined...',...
    ' 512: flag is set but not defined...',...
    '1024: flag is set but not defined...',...
    };

maxStatus = 1024;

if cellStatus==0
    if isequal(testNr,-1)
        fprintf('cell not tracked jet \n');
        Vector =statusVector;
    elseif isequal(testNr,0)
        
        Vector  = sum(statusVector) == statusVector(1);
    else
        
        Vector = 0;
    end
else
    while cellStatus >= 1
        % we have to store the flag with index iStatus+1 because 
        % at position 1 we store flag 0 = 'clean'
        statusVector(iStatus+1) = fix(cellStatus / maxStatus);
        cellStatus = rem(cellStatus,maxStatus);
        maxStatus = maxStatus /2;
        iStatus = iStatus - 1;
    end
     
    if isequal(testNr,-1)
    % now print out the status 
    for i=1:12
        if statusVector(i)
            disp(statusMessages{i});
        end
       Vector =  statusVector;
    end
    
    elseif isequal(testNr,0)
        
        Vector  = sum(statusVector) == statusVector(1);
    else
       
       Vector = statusVector(log2(testNr) +2);
       
    end
end

