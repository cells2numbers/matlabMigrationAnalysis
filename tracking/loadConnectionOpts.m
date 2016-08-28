function [radiusS,radiusT,frameRadius] = loadConnectionOpts(file)
%
% Load parameters for the automatic connection of path fragments
% temporally and spatially.
%
%

% load parameters into struct
try
    paramstruct = load(file);
catch err
    disp(err.message)
    throw err
end
    
% init the return values with default values
radiusS = 0;
radiusT = 0;
frameRadius = 0;

% check individual fields
if isfield(paramstruct,'radiusS'),
    radiusS = paramstruct.radiusS;
end

if isfield(paramstruct,'radiusT'),
    radiusT = paramstruct.radiusS;
end

if isfield(paramstruct,'frameRadius'),
    frameRadius = paramstruct.frameRadius;
end

end