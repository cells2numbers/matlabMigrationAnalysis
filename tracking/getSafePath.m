function [pList,threshList] = getSafePath(tLng,am,pm,varargin)
%  getSafePath returns safe paths from a path-matrix pm + timeline-struct
%
%  [pList,threshList] = getSafePath(tLng,am,pm,varargin)
%
%
%  INPUT
%    tLng   timeline-struct
%    am     adjacency matrix
%    pm     path-matrix
%     
%  OPTIONAL
%   'verbose'              int value, DEFAULT 0
%   'pathlength'           int value, DEFAULT 20
%   'threshold'            int value, DEFAULT 0.5
%
%  
%  OPUTPUT
% 
%  pList       list with all safe paths
%              (this list has on path in each row, one row 
%               can contain more than one path -> than we have
%               a connected "safe" path
%  threshList  list with min. treshold for all paths 
%
% tim becker july 2009

% some variables, todo: make them available as 
% optional input


minPathLength = 10;
minOverlap = 0.2;
pList = zeros(size(pm,1),1);
threshList = pList;
i=1;
VERBOSE = 0;
timeLim = [];

while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'VERBOSE',         i=i+1; VERBOSE = varargin{i};
            case 'verbose',         i=i+1; VERBOSE = varargin{i};
            case 'Verbose',         i=i+1; VERBOSE = varargin{i};
            case 'pathlength',      i=i+1; minPathLength = varargin{i};
            case 'threshold',       i=i+1; minOverlap = varargin{i};
            case 'time',            i=i+1; timeLim = varargin{i};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['getSafePath.m : WARNING! Ignoring invalid argument #' num2str(i+2)]);
    end
    i = i+1;
end


NPath = size(pm,1);

% loop over all path's
for iPath = 1:NPath
   cellpath = pm{iPath,3};
   LENGTHOK = size(cellpath,1) > minPathLength;
   OVERLAP = 1;
   for iCell=1:size(cellpath,1)-1
       time_a = cellpath(iCell,1);
       cell_a = cellpath(iCell,2);
       cell_b = cellpath(iCell +1,2);
       
       cellsize_a = length(tLng.cell(time_a).cells{cell_a});
       cellsize_b = length(tLng.cell(time_a+1).cells{cell_b});
       overlap = getsameIndex(tLng,cell_a,time_a,cell_b);
       
       OVERLAP = min([OVERLAP, (overlap/cellsize_a ), (overlap/cellsize_b)]);
       
   end
   THRESHOK = OVERLAP > minOverlap;
   if LENGTHOK && THRESHOK 
      pList(iPath) = iPath; 
      threshList(iPath) = OVERLAP;
   end

   if VERBOSE & ~mod(iPath,500)
       fprintf('analyzed path in %i from %i \n',iPath,NPath);
   end

end

pList = pList(pList~=0);
threshList = threshList ( threshList ~=0);

if ~isempty(timeLim)
    time_begin =  [pm{pList,1}];
    time_end = [pm{pList,2}] ;
    
    index = find(time_begin >= timeLim(1) & time_end <=timeLim(2));
    pList = pList(index);
    treshList = threshList(index);
    
end



% % we calculate the min. overlap within each path 
% % ( to determine the "safety" ) 
% overlap = ones(size(pm,1),1);  
% % we start wit zeros to determin the min.
% pathlength = zeros(size(pm,1),1);
% for iPath=1:size(pm,1)
%     cellpath = pm{iPath,3};
%     
%     for iCell=1:size(cellpath,1)-1
%         time1 = cellpath(iCell,1);
%         cell1 = cellpath(iCell,2);
%         cell2 = cellpath(iCell+1,2);
%         
%         succ = tLng.cell(time1).successor{cell1};
%         
%         overlap(iPath) = min(overlap(iPath),succ(find(succ(:,1)==cell2),2));
%     end
%      pathlength(iPath) = size(cellpath,1);
% end
% 
% 
% % we search for all paths with an min overlap > minOverlap
% for j=1:size(pm,1)
%    if overlap(j) > minOverlap  && pathlength(j) > minPathLength
%        pList(j) = j;
%    end
% end
% pList = pList(pList~=0);
% threshList = overlap(pList);
