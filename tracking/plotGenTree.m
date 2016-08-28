function h = plotGenTree(number,varargin)
%
%    h = plotGenTree(number,varargin)
%
%
% number = [1,1:2,1:2^2,1:2^3,1:2^4,1:2^5,1:2^6,1:2^7];
%
%
% each path i has two adjacent paths 2*i and 2*i + 1 
% tis gives us the numbers that we have to plot in each generation
%
%
%
%  Optional Input
%
%   width 
%   start
%   dist 
%   figure
%   timepoint
%
%
% Example 1: plot the biggest tree from refdataB
% 
% 
%load refdata
% load refdataB_complete;
% 
% % extract all trees 
% [treeList,treeRelationList,lm,treeLength] = getLineages(am,pm);
% 
% %% we write the trees to a lintree struct struct  (old data structure)
% for i=1:length(treeList)
%     [lt,pmlt,ltLength] =  pm2lintree(tLng,am,pm,treeList{i});
%    
%     [val,ind] = max(ltLength);
%     treeStruct{i} = lt{ind};
%     
%     if ~mod(i,10)
%         fprintf('finished tree %i \n',i);
%     end
%         
% end
% 
% %
% [valSorted,idxSorted] = sort(treeLength);
% 
% 
% %% write the biggest lineage to a tree list 
% treeList = lintreeCreateBinaryList(treeStruct{idxSorted(end)},1,1);
% 
% h = figure();
% plotGenTree(treeList,'figure',h)

% tim becker 01.2013


DIST = 1;
ANGLE_WIDTH = 2*pi;
ANGLE_START =-pi/2;

% optional figure handel
h = [];
timepoints = [];

% evaluate (optional) input arguments
i=1;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'width',       i=i+1; ANGLE_WIDTH = varargin{i};
            case 'start',       i=i+1; ANGLE_START = varargin{i};
            case 'dist',        i=i+1; DIST = varargin{i};
            case 'figure',      i=i+1; h = varargin{i};
            case 'timepoints',  i=i+1; timepoints = varargin{i};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    
    if ~argok,
        disp(['plotGenTree : WARNING! Ignoring invalid argument #' num2str(i)]);
    end
    i = i+1;
end



origin = [0,1];

% define  rotation matrix
R = @(a)([cos(a) -sin(a);sin(a),cos(a)]);

% get the number of generations 
NGeneration = floor(log2(size(number,2)));

if isempty(h)
    h = figure();
else
    figure(h);
end
    hold on 

    
    
    for iGen = 0 : (NGeneration-1);
        currentGenAngle = ANGLE_WIDTH / 2^iGen;
        nextGenAngle = ANGLE_WIDTH / 2^(iGen+1);
        
        for currentIndice=1:2^(iGen)
            % index for the "mother"
            jIndex = 2^(iGen)-1  +currentIndice;
            % index for both children
            jIndexSon = 2^(iGen+1)-1  +2*currentIndice-1;
            jIndexDaughter =  2^(iGen+1)-1  +2*currentIndice;
            
            if ~isempty(timepoints)
                origin(2) = timepoints(jIndex);
                x1 =  origin * R(number(jIndex)*currentGenAngle - nextGenAngle + ANGLE_START);
            else
                x1 = (iGen+1)^DIST * origin * R(number(jIndex)*currentGenAngle - nextGenAngle + ANGLE_START);
            end
            
            if iGen==0
                line([x1(1) 0],[x1(2) 0]);
            end
            
            if number(jIndex) ~=0 && number(jIndexSon) ~=0
                %  fprintf('plot here %i %i (gen. %i) \n',number(jIndex),number(jIndexSon),iGen);
                if ~isempty(timepoints)
                    origin(2) = timepoints(jIndexSon);
                    x2 =  origin * R(number(jIndexSon)*nextGenAngle  - nextGenAngle/2 + ANGLE_START);
                else
                    x2 = (iGen+2)^DIST * origin * R(number(jIndexSon)*nextGenAngle  - nextGenAngle/2 + ANGLE_START);
                end
                line([x1(1) x2(1)],[x1(2) x2(2)]);
            end
            
            if number(jIndex) ~=0 && number(jIndexDaughter) ~=0
                %  fprintf('plot here %i %i  (gen %i)  \n',number(jIndex),number(jIndexDaughter),iGen);
                
                %  fprintf('plot here %i %i (gen. %i) \n',number(jIndex),number(jIndexSon),iGen);
                if ~isempty(timepoints)
                    origin(2) = timepoints(jIndexDaughter);
                       x2 = origin * R(number(jIndexDaughter)*nextGenAngle  - nextGenAngle/2 + ANGLE_START);
                else
                x2 = (iGen+2)^DIST * origin * R(number(jIndexDaughter)*nextGenAngle  - nextGenAngle/2 + ANGLE_START);
                end
                line([x1(1) x2(1)],[x1(2) x2(2)]);
            end
            
        end
    end
    axis equal