function features = getCellPathFeature(pm,fm,pathnr,BEGIN,OFFSET)
% function to return the feature of a cell path 
%
%   getCellPathFeature(pm,fm,pathnr,BEGIN,OFFSET)
%
%
% Input: 
%   pm / fm     path matrix and feature matrix 
%   pathnr      the feature of path pathnr are returned
%
% Optional Input:
%   you can specify to return only the features of a given number 
%   of time frames using the variables BEGIN and OFFSET. 
%
%   BEGIN       BEGIN = 1 returns the first, BEGIN = 0 returns
%                       the last features 
%   OFFSET      number of time frames to return 
%
%
% 
% tim becker 12.2012

% first, extract the given path
cellpath = pm{pathnr,3};

% if BEGIN and OFFSET are not given, we return the complete path
if ~exist('BEGIN','var')
    BEGIN = 1;
end

if ~exist('OFFSET','var')
    OFFSET = size(cellpath,1);
end

% with BEGIN given, we return as many frames as specified 
% in OFFSET beginning with the first one.
if BEGIN 
   cellpath = cellpath(1:OFFSET,:); 
else
    % if BEGIN is not given, we return OFFSET many frames 
    % ending with the last frame
   cellpath = cellpath((end-OFFSET+1):end,:);
end

% init output var
features = zeros(size(cellpath,1),size(fm{1},2));

% extract features from the feature matrix
for i=1:size(cellpath,1)
    features(i,:) = fm{cellpath(i,1)}(cellpath(i,2),:);
end




