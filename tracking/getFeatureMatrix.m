function fm = getFeatureMatrix(tLng,imInfos,varargin)
% getFeatureMatrix calculates a complete feature matrix for a timeline
%
%   fm = getFeatureMatrix(tLng,imInfos)
%
%
%   output: 
%
%    fm      cell-matrix fm with
%            tLng.time_max cell's. 
%            size(fm) = tLng.time_max x 1 
%
%
%   The following features are calculated:
%
%   1.  x-position 
%   2.  y-position 
%   3.  area          as sum of pixels 
%   4.  brightness    mean brigthness of the cell area in the raw image
%   5.  length        of the major axis
%   6.  compactness   as (4 pi Area) / Perimeter^2 
%   7.  orientation   between -90 and 90
%
%
% Example I  calculate the feature matrix
%  fm = getFeatureMatrix(tLng,imInfos);
%
% Example II  plot histogram of all values 
%
% f = [];
% labels = {'xpos','ypos','area','bright.','length','compact.','orient.'}
%
% for i=1:size(fm,1)
%     f = [f;fm{i}];
% end
%
% for i= 1:size(f,2) 
%     figure();
%     hist(f(:,i),100);
%     title(labels{i});
% end
%           
% tb 08.2009, modified 07.2012

if ~isempty(varargin)
    warning('function call getFeatureMatrix(tLng,imInfos), ignoring optional input');
end

% preallocate the cell array
fm = cell(tLng.time_max,1);

% for each frame we get the features
for iFrame=1:tLng.time_max
%     if ~mod(iFrame,20)
%         fprintf('feature for cells in frame %i from %i...',...
%             iFrame,tLng.time_max);
%     end
    % number of cells
    NCell = length(tLng.cell(iFrame).status);
    % read image corresponding to the frame (needed to calculate the
    % brightness)
    I = imread(getFilename2(imInfos,iFrame));
    % create binary mask
    cellmask = imageTimelineNG(tLng,iFrame);
    
    % calculate morphological parameters using the binary mask given
    % in cellmask
    maskProp =  regionprops(cellmask,'Area','Centroid','Perimeter',...
        'Orientation','EquivDiameter','MajorAxisLength');
    f_vector = zeros(NCell,7);
    
    for iCell = 1:NCell
        if tLng.cell(iFrame).status(iCell) >= 0
            % mean brightness of each cell
            f_bright = mean(I(tLng.cell(iFrame).cells{iCell}));
            
            %
            f_vector(iCell,:) = [maskProp(iCell).Centroid(end:-1:1), ...
                maskProp(iCell).Area, ...
                f_bright, ...
                maskProp(iCell).MajorAxisLength,...
                (4*pi*maskProp(iCell).Area)/(maskProp(iCell).Perimeter)^2,... % compactness
                maskProp(iCell).Orientation];        
        end
    end
    
    
    fm{iFrame} =  f_vector;
    if ~mod(iFrame,20)
        %fprintf('done!\n');
        fprintf('.');
    end
end
