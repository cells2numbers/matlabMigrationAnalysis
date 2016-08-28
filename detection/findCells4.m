function [cm,IBlurred2,stretchPara] = findCells4(I,varargin)
% findCells4 detects cells with more flexibility than the old methods
% 
%  
% [cm,cellImage,stretchPara] = findCells4(img) 
%
%  cm                 returns the cellmask and 
%  cellImage          the preprocessed image
%  stretchPara        and the used Parameters
%                     for adjusting the detection
%                     (to display them online in several GUIs)
%                     added 07.06.10, j.a.    
%
%  optional arguments:
%
%  hsizeI          parameters for the image normalization
%  sigmaI          (we use a gauss-blurred subtraction to 
%                   normalize the raw data(
%                  standard paramter: hsizeI = [60,60];
%                  sigmaI = 30;
%
%  hsizeII         parameters for the second gauss-filter
%  sigmaII         to get a smoother image
%                  standard paramter:hsizeII = [2,2]; 
%                  sigmaII = 0.5; 
%
%  carea           min. size that will not be detected
%                  defalt value: carea = 50;
%
%  levelfactor     factor to change image otsu-threshold
%                  default value: levelfactor = 1;   
%
%  stretchPara     parameter to modify imadjust function
%                  stretchPara = [low_level, high_level]
%                  
%
%
% 
% tim becker 06.2009
% modif. 07.06.10, j.a.

% some paramters

%% images with rgb data is converted to grayscale
if size(I,3) > 1
  I =  rgb2gray(I);
end

% max allowed size for a cell object (to deal with artefacts as border etc
% seen in the data of gyde + markus) 
maxcarea = 1000;


hsizeI = [60,60];
sigmaI = 30;

hsizeII = [2,2];   % default value as used by fspecial
sigmaII = 0.5;     %           

carea = 50;
levelfactor = 1;
BREAKPOINT = 0;

%% here we set the standard stretch parameter
% it is used to adjust the image, usefull if 
% the cell density is rapidly changing
% 
stretchPara = 0;
% stretchPara = [0 .07];
CONST = 0;
INV = 1;
i=1;

while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            case 'hsizeI',       i=i+1; hsizeI = varargin{i};
            case 'sigmaI',       i=i+1; sigmaI = varargin{i};
            case 'hsizeII',      i=i+1; hsizeII = varargin{i};
            case 'sigmaII',      i=i+1; sigmaII = varargin{i};
            case 'carea',        i=i+1; carea = varargin{i};
            case 'maxcarea',     i=i+1; maxcarea = varargin{i};
            case 'levelfactor',  i=i+1; levelfactor = varargin{i};
            case 'stretchPara',  i=i+1; stretchPara = varargin{i};
            case 'const',        i=i+1; CONST = varargin{i};     
            case 'inverse',      i=i+1; INV = varargin{i};
            case 'breakpoint',   i=i+1; BREAKPOINT = varargin{i};
            otherwise
                argok=0;
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['findCells4.m : WARNING! Ignoring invalid argument #' num2str(i+2) ': ' num2str(varargin{i})]);
    end
    i = i+1;
end
%
% idea: use adapthisteq!! at the beginning, befor first imfilter

if INV
    % to detect cell-objects on inverse contrast (some phase contrast images
    % showing fish-cells) the inverse image is computed
    I = 255 -I;
end

%I =  imadjust(I,stretchlim(I),[0,1]);



%% we create the gauss-filter and blurr the image
PSF = fspecial('gaussian',hsizeI,sigmaI);
%I = imadjust(I);
%I = imadjust(I,stretchlim(I),[0,1]);
IGauss = imfilter(I,PSF,'replicate');

% diff-image, automatic adjust
IDiff = imsubtract(I, IGauss);




% if given, we use the stretchlim parameter stretchPara
% if not, we calculate it here for each picture
if ~isequal(size(stretchPara),[2,1])
    % here we can observe the stretchlim parameters, usefull to
    % fix / set parameters...
    %if VERBOSE 
       stretchPara = stretchlim(IDiff);
%        fprintf('\nstretchlim parameter: %6.4f %6.4f \n',stretchPara(1),stretchPara(2));
    %end
   % IBlurred = imadjust(IDiff,stretchlim(IDiff), [0 1]);
%else
   
end
 IBlurred = imadjust(IDiff,stretchPara, [0 1]);


%   IBlurred = imadjust(IDiff,stretchlim(IDiff,[.1 .995]), [0 1]);
% again we do some blurring (optional, we get some smoother edges)
if sigmaII > 0
    PSF = fspecial('gaussian',hsizeII,sigmaII);
    IBlurred2 = imfilter(IBlurred,PSF);
else
    IBlurred2 =    IBlurred;
end

%background = imopen(I,strel('disk',12));
%IBlurred2 =  imadjust(imsubtract(I, background));
% here we do our detection using o'tsu method for the threshold
level = graythresh(IBlurred2);

% the threshold is modified using levelfactor, needed for test purpose
if CONST 
    BW = im2bw(IBlurred2,CONST);
%     fprintf('const'); CONST
else 
    BW = im2bw(IBlurred2,level * levelfactor);
%     fprintf('level'); level*levelfactor 
end

if BREAKPOINT
    keyboard()
end

bw = BW;
% now we label our cells
%BW = bwlabel(Ibw);

% we want to find all cells with a defined size
% minimal size is 'criticalarea'
%props = regionprops(BW,'Area');
%BW = ismember(BW, find([props.Area] >= carea));

%BW = bwareaopen(imfill(BW,'holes'),carea);
%BW = bwmorph(BW,'open');

%BW = bwmorph(BW,'spur');
%BW = bwmorph(BW,'hbreak');
%BW = bwlabel(BW);
%props = regionprops(BW,'Area');
%BW = ismember(BW, find([props.Area] >= carea));
%BW = bwmorph(BW,'erode');
BW = bwmorph(BW,'spur');
BW = bwmorph(BW,'fill');
BW = imfill(BW,'holes');
BW = bwlabel(BW);
props = regionprops(BW,'Area');
BW = ismember(BW, find([props.Area] >= carea));
BW = bwlabel(BW);

props = regionprops(BW,'Area');
BW = ismember(BW, find([props.Area] < maxcarea));
BW = bwlabel(BW);

cm = BW;




PLOT = 0;
if PLOT
 figure();
 imshow(I); title('raw data');
 figure();
 imshow(IGauss);title('gauss filtered image');
 figure();
 imshow(imadjust(IDiff)); title('Difference Image');
 figure();
 imshow(IBlurred); title('Blurred Image');
 figure();
 imshow(IBlurred); title('Blurred2 Image');
 figure();
 imshow(bw); title('cellmask');
 figure();
 imshow(BW);title('labeled cells');
end




end
