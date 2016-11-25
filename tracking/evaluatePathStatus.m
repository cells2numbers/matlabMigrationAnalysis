function [pathList,timeList] = evaluatePathStatus(pm,statusflag)
% evaluatePathStatus extracts paths with given status out of a pm
%
%    pathList = evaluatePathStatus(pm,statusflag)
% 
% simple function that returns all paths with the given flag 
% set (this functions just helps to save some lines ;) )
%
% Example:   distribution of mitotic cells
%  
%  [mList,mTimes] = evaluatePathStatus(pm,2);
%  hist(mTimes);
%
% again, a summary of the available flags:
% 
%        0                      NOT SET
%        1                     'path' 
%        2                     'mitosis'
%        4                     'border begin'
%        8                     'border end'
%       16                      NOT SET 
%       32                     'corrected'
%       64                     'ending' 
%      128                     'beginning' 
%      256                     'lost begin' 
%      512                     'lost end' 
%     1024                     'coupled'  
%  
% see also setPathStatus, getPathStatus, fillPathStatus, 
% 
% tim becker, 30 march 2010


% pathlist
pathList = zeros(length(pm),1);
timeList = zeros(length(pm),1);

% we count all mitosis ()
for iPath=1:size(pm,1)
    % get the status
    if ~isempty(pm{iPath,1})
        [newStatus,FLAG] = getPathStatus(pm,iPath,statusflag);
        % and remember each mitosis
        if FLAG
            pathList(iPath) = iPath;
            
            timeList(iPath) = pm{iPath,2};
        end
    end
end

pathList = find(pathList);
timeList = timeList(timeList~=0);