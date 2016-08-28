function [ltList,pmltList,ltLength] =  pm2lintree(tLng,am,pm,pathlist,varargin)
% pm2lintree creates as much lintrees from pm as possible using pffm
%
%
%
%  [lt,pmlt,ltLength] =  pm2lintree(tLng,am,pm,pathlist)
%
%
%  Example I 
%
%   [lt,pmlt,ltLength] =  pm2lintree(tLng,am,pm,1:length(pm))
%   fig = figure();
%   for i=1:length(lt)
%      lintreePlot3D(lt{i},pmlt{i},'figure',fig);
%   end
% 
%
%
%
%
%   linlength = zeros(length(pmlt),1);
%   for i=1:length(pmlt)
%      linlength(i) = size(pmlt{i},1);
%   end
%
%   [npaths,lineageNr] = max(linlength)
%   lintreePlot3D(lt{lineageNr},pmlt{lineageNr})
%    
% tim becker sept. 2009
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

ltLength = [];

% mitoses list
mList = zeros(length(pm),1);


% we count all mitosis ()
for iPath=1:length(pm)
    % get the status
    [newStatus,MITOSIS] = getPathStatus(pm,iPath,2);
    % and remember each mitosis
    mList(iPath) =  MITOSIS;
end
mList = find(mList);

% path connection list: for each mitotic path we store both 
% children, format: [mother, child1, child2]

pathConList  = zeros(length(mList),3);

for iPath = 1:length(mList)
    
    
    pathNr = mList(iPath);
 
    
    [dIn,dOut,cNIn,cNOut] = getNodeInfo(am,pathNr);
    cCells =  cNOut(:,1)';
    
    % in the reference data, we allow mitotic cells 
    % with only one successor cell 
    % (border problem)
    if length(cCells) == 1 
        cCells = [cCells 0];
    end
    
    if length(cCells) > 1
        pathConList(iPath,:) = [pathNr,cCells];
    else
        pathConList(iPath,:) = 0;
    end
end

pffm = pathConList;

PLOT = 0;

ltList = [];
pmltList = [];
NPath = 0;
for iPath=1:length(pathlist)
    si = pm{iPath,1} == 1;
        
    if ~isempty(pm{pathlist(iPath),3})
       NPath = NPath + 1;
       lt =  lintreeInit();
       pmlt = [];
       candidateList = pathlist(iPath);
       candPath = candidateList(1);
       candCoord = pathToCoord(tLng,pm,candPath);
       [lt,pmlt] = lintreeAddEdge(lt,pmlt,candCoord(1,:),candCoord,...
           'verbose',VERBOSE);
       
       while ~isempty(candidateList)
           candPath = candidateList(1);
           candidateList(1) = [];
           candCoord = pathToCoord(tLng,pm,candPath);
           insertCoord = candCoord(end,:);
           
           kids =  pffm(pffm(:,1) == candPath,2:3);
           for iKid = 1:length(kids)
               % in the ref data we allow mitosis with just one 
               % daughter
               if kids(iKid) ~=0
                   coordKid =  pathToCoord(tLng,pm,kids(iKid));
                   [lt,pmlt] = lintreeAddEdge(lt,pmlt,insertCoord,coordKid,...
                       'verbose',VERBOSE);
                   candidateList = [candidateList,kids(iKid)];
               end
           end
                      
           
       end
       
       if ~isempty(pmlt);
       ltList{end+1} = lt;    
       pmltList{end+1} = pmlt;
       end
    end
end

for iTree = 1:length(pmltList)
    ltLength(iTree) = size(pmltList{iTree},1);
end

if PLOT
    fig = figure();
    for i=1:length(lt);
        lintreePlot3D(ltList{i},pmltList{i},'figure',fig);
    end
end