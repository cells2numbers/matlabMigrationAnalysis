function tLng = fillTimelineNG(imInfos,varargin)
%  function to create and fill an timelineng-struct
%
%
% USAGE:
%  timeline = fillTimelineNG(imInfos)
%
%  optional arguments:
%     'statusbar'  with value 1/0 for use in guis
%     'statustext' with value 1/0
%     'detect_method'        int
%             with values  0   =   old method
%                          1   =   own method
%
%     'maxTime'   timeline is only filled up to given value
%     (default values are 0 (=false)
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
%
%  processImage    if this flag is set ( 0 / 1), the preprocessed
%                  image is stored
%
%
%
% INPUT: filename, pathname to the first picture
% of on image-series
%
%
% See Also correctTimelineNG.m, imageTimelineNG.m
%
%
% EXAMPLE:
%
%  to create a timeline using image path/file
%
%  imInfos = openImageseries();
%  tLng = fillTimelineNG(imInfos,'statustext',1)
%


% ATTENTION: here we choose the default method!
% for testing we choose the new method
% can be specified as input argument
detect_method = 1;

status_bar  = 0;
status_text = 1;
PROCESSIMAGE = 0;
% some paramters
hsizeI = [60,60];
sigmaI = 30;

hsizeII = [2,2];   % default value as used by fspecial
sigmaII = 0.5;     %

carea = 50;
maxcarea = 1000;
levelfactor = 1;

CONST = 0;
INV = 1;

stretchPara = 0;  % added 07.06.10, j.a.
% and also adjusted the findCells4-Calls;
% now stretchParas are handed, too.


detection_para.area_max = 40;
detection_para.area_min = 500;
detection_para.ecc_max = 0.95;
detection_para.se_size = 3;

% check for input
i=1;
maxTime = 0;
while i<=length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch varargin{i},
            case 'statusbar',       status_bar  = 1;
            case 'statustext',      status_text = 1;
            case 'maxTime',         i=i+1;maxTime = varargin{i};
            case 'hsizeI',          i=i+1; hsizeI = varargin{i};
            case 'sigmaI',          i=i+1; sigmaI = varargin{i};
            case 'hsizeII',         i=i+1; hsizeII = varargin{i};
            case 'sigmaII',         i=i+1; sigmaII = varargin{i};
            case 'carea',           i=i+1; carea = varargin{i};
            case 'maxcarea',        i=i+1; maxcarea = varargin{i};
            case 'levelfactor',     i=i+1; levelfactor = varargin{i};
            case 'processImage',    i=i+1; PROCESSIMAGE = varargin{i};
            case 'stretchPara',     i=i+1; stretchPara= varargin{i} ;
            case 'inverse',         i=i+1; INV = varargin{i};
            case 'const',           i=i+1; CONST = varargin{i};
            case 'detection',       i=i+1; detect_method = varargin{i};
            case 'detection_method',i=i+1; detect_method = varargin{i};
            case 'detect_method',   i=i+1; detect_method = varargin{i};
            case 'detection_para',  i=i+1; detection_para = varargin{i};
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


% optionally: store preprocessed images 

imInfosPre = imInfos;
if PROCESSIMAGE && ~exist([imInfos.path 'preProImages'],'dir')
    
    mkdir([imInfos.path 'preProImages']);
    pause(1);
end
imInfosPre.path = [imInfos.path 'preProImages' filesep];
imInfosPre.first = [imInfosPre.first '_pre_'];
imInfosPre.type = 'png';


% check how long  the timeline will be...
tic;

if maxTime
    time_max = maxTime;
else
    time_max = 1;
    
    while exist(getFilename2(imInfos, time_max + 1),'file')
        time_max = time_max +1;
        % disp(getFilename2(imInfos, time_max))
    end
end

if status_bar
    sb = statusbar('cells detected in %d of %d frames(%.1f%%)...',0,time_max,100*0/time_max);
    set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',time_max, 'Value',0);
end


fprintf('found %03d images, start cellfinder\n',time_max);

% read the first image and convert to bw image
image_c = imread(getFilename2(imInfos, 1));


% %Zeile nur zum testen, J.A. 04.06.10
% s = getFilename2(imInfos, 1);
% fprintf('\nFrame %s',s(end-6:end-4));
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (size(image_c,3)==3)
    image_bw = rgb2gray(image_c);
else
    image_bw = image_c;
end

% get the image-size
image_size = size(image_bw);

% calculate the cellmask
% detect cells

if detect_method == 0
    cellmask = findCells3(image_bw);
elseif detect_method == 1
    [cellmask,preProImage] = findCells4(image_bw,'hsizeI',hsizeI,'sigmaI',sigmaI,'hsizeII',hsizeII, ...
        'sigmaII',sigmaII,'carea',carea,'levelfactor',levelfactor,'stretchPara',stretchPara,...
        'maxcarea',maxcarea,'inverse',INV,'const',CONST);
elseif  detect_method == 2
    [cellmask,preProImage] = findCellsRF(image_bw,detection_para);
else
    fprintf('what detect method should i use? falling back to the old one...\n');
    cellmask = findCells3(image_bw);
end

% we have the option to store the preprocessed image
%
if PROCESSIMAGE && detect_method ==1
    saveName = getFilename2(imInfosPre,1);
    imwrite(preProImage,saveName,'png');
end
%imshow(cellmask);
%drawnow;


% convert to cellng structure (needed for timelineng, this saves some
% memory )
[cellng,centroid] = cmask2cell(cellmask);
cell_number = length(cellng);

% status vector
status = zeros(cell_number,1);


tLng = initTimelineNG('time_max',time_max,'cells',cellng, ...
    'centroid',centroid,'number',cell_number,'image_size',image_size,'status',status);




cell_neighbour = zeros(cell_number,6);
% 	%
% 	for j=1:cell_number
% 		% first we sort the neighbours
% 		[val,ind] = getbestIndex(tLng, j, 1, 1);
%
% 		% then we store the six nearest neighbours
%         nNeighbours = min(6,length(ind));
% 		cell_neighbour(j,:) = ind(1:nNeighbours);
%
% 	end
tLng = modTimestampNG(tLng,1,'neighbour',cell_neighbour,'status',status);


if status_bar
    sb = statusbar('cells detected in %d of %d frames(%.1f%%)...',1,time_max,100*1/time_max);
    set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',time_max, 'Value',1);
end

if status_text
    fprintf('%3.2f%% done (%i from %i images), time elapsed: %i min %i seconds \n', ...
        100* tLng.time / tLng.time_max,1,time_max, floor(toc/60),floor(mod(toc,60)) );
end

for i=2:time_max
    % read image and convert to rgb
    image_c = imread(getFilename2(imInfos, i));
    
    if (size(image_c,3)==3)
        image_bw = rgb2gray(image_c);
    else
        image_bw = image_c;
    end
    
    % old version, without bw-jpg support....
    %		image_bw = rgb2gray(imread(getFilename2(imInfos, i)));
    
    % detect cells
    if detect_method == 0
        cellmask = findCells3(image_bw);
    elseif detect_method == 1
        
        [cellmask,preProImage] = findCells4(image_bw,'hsizeI',hsizeI,'sigmaI',sigmaI,'hsizeII',hsizeII, ...
            'sigmaII',sigmaII,'carea',carea,'levelfactor',levelfactor,'stretchPara',stretchPara,...
            'maxcarea',maxcarea,'inverse',INV,'const',CONST);
        
    elseif  detect_method == 2
        [cellmask,preProImage] = findCellsRF(image_bw,detection_para);
        
    else
        fprintf('what detect method should i use? falling back to the old one...\n');
        cellmask = findCells3(image_bw);
    end
    
    
    % optionally: store preprocessed images
    %
    if PROCESSIMAGE && detect_method ==1
        saveName = getFilename2(imInfosPre,i);
        imwrite(preProImage,saveName,'png');
    end
    
    [cellng,centroid] = cmask2cell(cellmask);
    
    % get number of detected cells
    cell_number = length(cellng);
    
    % now we collect information for each single cell
    cell_neighbour = zeros(cell_number,6);
    
    status = zeros(1,cell_number);
    
    tLng = modTimestampNG(tLng,i,'neighbour',cell_neighbour,'status',status,...
        'cells',cellng,'centroid',centroid,'number',cell_number);
    
    if status_text && ~mod(i,10)
        
        fprintf('%3.2f%% done (%i from %i images), time elapsed: %i min %i seconds \n', ...
            100* i / time_max,i,time_max, floor(toc/60),floor(mod(toc,60)) );
    end
    
    if status_bar
        sb = statusbar('cells detected in frame %d of %d (%.1f%%), elapsed time: %i min %i sec',...
            i,time_max,100*i/time_max,floor(toc/60),floor(mod(toc,60)));
        set(sb.ProgressBar, 'Visible','on', 'Minimum',0, 'Maximum',time_max, 'Value',i);
    end
end
% now we can calculate the overlap (we have to do it after
% the first loop because we need information from the next
% frame
end
