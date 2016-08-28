function imInfos =  openImageseries(varargin)
% function to decompose filenames for an image timeseries
%  
%  imInfos = openImageseries(varargin)
%
% 
% a regular expression is used to decompose image names with the structure
%
%   cellimage001.jpg 
%   name + number +.extension
%
%   
%  optional input:
%  dirname     directory name of the image folder 
%  filename    image names 
%
%
% Example I  chose image series manually
% imInfos = openImageseries()
%
% Example II  open image 
%
%  % find image directory of refdataA in the path
%  dirInfo = what('refdataA');
%  dirname = dirInfo.path;
%
%  % extract the first image name
%  filename = dir([dirname filesep '*jpg']);
%  filename = filename(1).name
% 
%  % create imInfos struct
%  imInfos = openImageseries(dirname,filename)
% 
%  % show first image 
%  imagesc(imread(getFilename2(imInfos,1)))
%  colormap gray
%
%
% tb 2009, modified 2012 (documentation added)

imInfos=[];

% check for optional input 
if (nargin==0)
  [filename, pathname, filterindex] = uigetfile( ...
      {'*.*',  'All Files (*.*)';...
      '*.png','PNG-images (*.png)'; ...
       '*.PNG','PNG-images (*.PNG)';...
       '*.jpg','JPEG-images (*.jpg)';...
       '*.JPG','JPEG-images (*.JPG)';...
       '*.txt','txt-files (csv)'},...
      'Choose startimage', 'untitled.png');
elseif nargin==2
  pathname=varargin{1};
  if ~isequal(pathname(end),filesep)
     pathname(end+1) = filesep; 
  end
  filename=varargin{2};
else
  warning('openImageseries.m : ignoring input arguments')  
end

% decompose filename into three subparts
pat = '(?<first>(\w*\D*)*\D+)(?<number>\d+).(?<type>\w+)';
if pathname
    imInfos = regexp(filename, pat,'names');
    imInfos.path=pathname;
end
