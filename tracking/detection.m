function[tLng,am,pm,fm,mu,sigma] = detection(varargin)
%
% Run segmentation and detection with the provided parameters
%
%

% initialize return values
tLng = initTimelineNG;
am = [];
pm = {};

% unpack varaible list
varargin = varargin{1};

% default parameters
hsizeI = [60,60];
sigmaI = 30;

hsizeII = [2,2];   % default value as used by fspecial
sigmaII = 0.5;     %

carea = 50;
maxcarea = 1000;
levelfactor = 1;

CONST = 0;
INV = 1;

stretchPara = 0;
detect_method = 1;
% check for input
i=1;

while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            case 'imInfos',        i=i+1; imInfos = varargin{i};
            case 'detect_method',  i=i+1; detect_method = varargin{i};
            case 'maxTime',        i=i+1; maxTime = varargin{i};
            case 'hsizeI',         i=i+1; hsizeI = varargin{i};
            case 'sigmaI',         i=i+1; sigmaI = varargin{i};
            case 'hsizeII',        i=i+1; hsizeII = varargin{i};
            case 'sigmaII',        i=i+1; sigmaII = varargin{i};
            case 'carea',          i=i+1; carea = varargin{i};
            case 'maxcarea',       i=i+1; maxcarea = varargin{i};
            case 'levelfactor',    i=i+1; levelfactor = varargin{i};
            case 'processImage',   i=i+1; PROCESSIMAGE = varargin{i};
            case 'stretchPara',    i=i+1; stretchPara= varargin{i} ;
            case 'inverse',        i=i+1; INV = varargin{i};
            case 'const',          i=i+1; CONST = varargin{i};  
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['fillTimelineNG.m : WARNING! Ignoring invalid argument #' num2str(i)]);
        disp(varargin{i})
    end
    i = i+1;
end

% for more information see fillTimelineNG,
% various options can be changed using 'detect_method' 1
 tLng = fillTimelineNG(imInfos,'detect_method',detect_method,...
        'hsizeI',hsizeI,'sigmaI',sigmaI,...
        'hsizeII',hsizeII,'sigmaII',sigmaII, ...
        'carea',carea,'maxcarea',maxcarea,'levelfactor',levelfactor,...
        'processImage',1,'stretchPara',stretchPara,'inverse',INV,...
        'const',CONST);
        
 % we calculate the feature matrix
 fm = getFeatureMatrix(tLng,imInfos);
        
        
 % we begin the initial tracking
 % the next step creates neighbours, successors, predecessor....
 tLng = correctTimelineNG(tLng,'verbose',0);
            
% we create our initial path-matrix, adjacency matrix....
[am,pm,~,tLng] = fillEList(tLng,'verbose',0,'fillup',1);
            
% we fill the path-status ( do not get confused here:
% the timelinestruct stores the path as status -> the value
% of the status is stored in the timeline struct
[tLng,pm] = fillPathStatus(tLng,am,pm);
            
% and mean values and covariance matrix
[mu,sigma] = getMuSigma(tLng,am,pm,fm);

end