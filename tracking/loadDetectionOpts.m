function detectionOpts = loadDetectionOpts(file)
%
% Load the detection paramaters for the segmentation from a file
% into a cell array.
%

% load parameters into struct
try
    paramstruct = load(file);
catch err
    disp(err.message)
    throw err
end

% init the cell array with default values
detectionOpts = {'imInfos',0,...
                 'hsizeI',[60,60],...
                 'sigmaI',30,...
                 'hsizeII', [2 2],...
                 'sigmaII', 0.5,...
                 'carea', 50,...
                 'levelfactor', 1,...
                 'stretchPara', 0,...
                 'maxcarea',1000,...
                 'inverse',1,...
                 'const',0};

% check individual fields
if isfield(paramstruct,'imInfos'),
    detectionOpts{1,2} = paramstruct.imInfos;
else
    error('Could not find imInfos in the provided file')
end

if isfield(paramstruct,'hsizeI'),
    detectionOpts{1,4} = paramstruct.hsizeI;
end

if isfield(paramstruct,'sigmaI'),
    detectionOpts{1,6} = paramstruct.sigmaI;
end

if isfield(paramstruct,'hsizeII'),
    detectionOpts{1,8} = paramstruct.hsizeII;
end

if isfield(paramstruct,'sigmaII'),
    detectionOpts{1,10} = paramstruct.sigmaII;
end

if isfield(paramstruct,'carea'),
    detectionOpts{1,12} = paramstruct.carea;
end

if isfield(paramstruct,'levelfactor'),
    detectionOpts{1,14} = paramstruct.levelfactor;
end

if isfield(paramstruct,'stretchPara'),
    detectionOpts{1,16} = paramstruct.stretchPara;
end

if isfield(paramstruct,'maxcarea'),
    detectionOpts{1,18} = paramstruct.maxcarea;
end

if isfield(paramstruct,'inverse'),
    detectionOpts{1,20} = paramstruct.inverseFlag;
end

if isfield(paramstruct,'const'),
    detectionOpts{1,22} = paramstruct.const;
end  

        
end