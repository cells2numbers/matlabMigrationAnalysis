function validPath = getValidPath(pm,varargin)
% getValidPath searches for good (valid) paths in an path-matrix pm
%
%  validPath = getValidPath(pm,varargin)
% 
%  -using default parameters, no threshold is used, the default 
%   path-length is set to 10 
%
%  -you can use a threshold (calculated using the feature-matrix)
%   a path is valid, if the smalles feature-diff in the complete 
%   path is bigger then the given threshold ( yea, something like
%  
%
%
%  as optional argument you can set   
%
%   length                min. path length
%   thresh                min. feature-diff for the path
%   fm                    feature matrix belonging to pm
%   mu                    mean-value for fm
%   sigma                 covariance matrix for fm
%  
% 
%  EXAMPLE 
%   1) simple calculation using only the length
%    validPath = getValidPath(pm)
%
%   2) same calculation using different length and an threshold  
%   validPath = getValidPath(pm,'length',5,'thresh',...
%       .0000001,'fm',fm,'mu',mu,'sigma',sigma);
%
%  TODO: -add verbose-messages, this could be helpfull if you run this 
%         programm with a big path-matrix 
%        -add mitosis detection, 
%
%
%
%
%
% tb nov. 2009


% init. output var.
validPath = [];

% PARAMETER for valid-paths 
validLength = 10;


% feature parameter:  we first set default values, they SHOULD
% be overwritten using optional input arguments. if not, we set them 
% to 0 / eye-matrix!!!! see details below 
fm = [];
validThresh = 0;
mu = [];
sigma = [];
VERBOSE = 0;

i = 1;
% we check for all input arguments
%
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            % argument IDs
            case 'length',            i=i+1; validLength = varargin{i};
            case 'thresh',            i=i+1; validThresh = varargin{i};
            case 'fm',                i=i+1; fm = varargin{i};
            case 'mu',                i=i+1; mu = varargin{i};
            case 'sigma',             i=i+1; sigma = varargin{i};
            case 'VERBOSE',           i=i+1; VERBOSE = varargin{i};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['getValidPath.m : WARNING! Ignoring invalid argument #',...
            num2str(i+2)]);
    end
    i = i+1;
end




if isempty(fm)
    % in this case, we set a path valid, if it has the correct length
    for iPath=1:size(pm,1)
        if ~isempty(pm{iPath,1})  % we check if we have an deltetd path
            LENGTHOK =  pm{iPath,2} - pm{iPath,1} > validLength;
            if LENGTHOK
                % if the length is ok, we can add the path
                validPath = [validPath,iPath];
            end
        end
    end
else % now we also check for the min threshold in the path
    % the first thing we have to do: check / set mu sigma
    fLength = size(fm{1},2);  % number of feature-values
    
    % we check if mu/sigma are given, if not we set them to zero / eye
    % (so we have not good, but valid parameters...)
    if isempty(mu)
        mu = zeros(1,fLength);
        fprintf('ATTENTIONe: mu not given, set all mean-values to 0!\n');
    end
    % we check if sigma is given
    if isempty(sigma)
        sigma = eye(fLength,fLength);
        fprintf('ATTENTIONe: sigma not given, set eye-matrix for cov-matrix !\n');
    end
    
    % same loop as above, we only add the feature-thing ;) 
    for iPath=1:size(pm,1)
        if ~isempty(pm{iPath,1})
            LENGTHOK =  pm{iPath,2} - pm{iPath,1} > validLength;
            if LENGTHOK 
                % if the length is valid, we check the feature-threshold
                featureVektor =  mvnpdf(getFeaturePathDiff(pm,fm,iPath),mu,sigma);
                % we look for the minimum thresh, something like 
                % the maximum / minimum norm 
                if min(featureVektor ) > validThresh
                    validPath = [validPath,iPath];
                end
            end
        end
    end
end

% if the user is an DAU we should tell him
if validThresh >0 && isempty(fm)
    fprintf('ERROR: threshold given WITHOUT feature-matrix FM!\n');
    fprintf('see help getValidPath.m for more info \n');
    fprintf('calculated without threshold \n');
end