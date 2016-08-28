function [tLng,pm] = fillPathStatus(tLng,am,pm,varargin)
% fillPathStatus searches an labels ending and beginning paths
%
%  [tLng,pm] = fillPathStatus(tLng,am,pm)
%
%  TODO: add parameter borderDistance as optional argument
%
% tim becker july 2009

%
borderDistance = 30;

% we check for beginning paths'
eList = getEdgeList(am);
%nCellsF = []; % new path in frame 1
%nCellsB = []; % new path near a border
%nCellsO = []; % other new path

% one loop to set the path flag in all paths
for iFrame=1:size(pm,1)
    if isempty(pm{iFrame,3})
        [pm,tLng] = setPathStatus(tLng,pm,iFrame,'path',0) ;
    else
        [pm,tLng] = setPathStatus(tLng,pm,iFrame,'path',1) ;
    end
end
    

for iFrame=1:size(pm,1)
        
    if eList(iFrame,2) == 0 && ~isempty(pm{iFrame,1})
        % we check if we have a cellpath beginning at time 1
        if pm{iFrame,1}==1
            [pm,tLng] = setPathStatus(tLng,pm,iFrame,'begin',1,'path',1) ;
            %nCellsF(end+1,:) = iFrame;
            % we check if we have a cellpath beginning at a border
        elseif nearBorder(tLng,pm{iFrame,1},pm{iFrame,3}(1,2),borderDistance);
            [pm,tLng] = setPathStatus(tLng,pm,iFrame,'path',1,'borderBegin',1) ;
            %nCellsB(end+1,:) = iFrame;
        else
            [pm,tLng] = setPathStatus(tLng,pm,iFrame,'path',1,'lostBegin',1) ;
            %nCellsO(end+1,:) = iFrame;
        end
    end
end

% we check for ending paths'

for iFrame=1:size(pm,1)
    if eList(iFrame,1) == 0 && ~isempty(pm{iFrame,1})
        % we check if we have a cellpath ending at the end of the timeline
        if pm{iFrame,2}==tLng.time_max
            [pm,tLng] = setPathStatus(tLng,pm,iFrame,'end',1,'path',1);
            %lCellsL(end+1,:) = iFrame;
            % we check if we have a cellpath beginning at a border
        elseif nearBorder(tLng,pm{iFrame,2},pm{iFrame,3}(end,2),borderDistance);
            [pm,tLng] = setPathStatus(tLng,pm,iFrame,'path',1,'borderEnd',1) ;
            %lCellsB(end+1,:) = iFrame;
        else   
            [pm, tLng] = setPathStatus(tLng,pm,iFrame,'path',1,'lostEnd',1) ;
            %lCellsO(end+1,:) = iFrame;
        end
    end
end

% % in the last run, we search for lost cells, i.e. cells without predecessor
% % or successor cell
% 
% for iFrame=1:length(pm)
%     [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,iFrame)
%     % first, we check for valid predecessor paths
%     if pm{iFrame,1} ~=1 && dIn == 0
%         [pm, tLng] = setPathStatus(tLng,pm,iFrame,'path',1,'lostEnd',1);
%     end
%     
%     % second, we search valid successor paths
%     if pm{iFrame,1} ~= tLng.time_max && dOut == 0
%         
%     end
%     
end

