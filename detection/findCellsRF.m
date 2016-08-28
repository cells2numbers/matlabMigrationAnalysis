function[BWFINAL,Irf] = findCellsRF(I,detPara)
%
%
%
%

if ~exist('detPara','var')
    detPara.area_max = 500;
    detPara.area_min = 40;
    detPara.ecc_max = 0.95;
    detPara.se_size = 3;
    detPara.verbose = 0;
end

if isfield(detPara,'verbose')
    VERBOSE = 1;
else 
    VERBOSE = 0;
end



% perform image segmentation using rangefilter 
se = strel('disk', double(detPara.se_size));
Irf = rangefilt(I,getnhood(se));

% otsu's adaptive threshold 
level = graythresh(Irf);
RFBW = im2bw(Irf,level);


% postprocessing 
RFBW1 = imfill(RFBW,'holes');
RFBW1 = bwmorph(RFBW1,'spur');
RFBW1 = bwmorph(RFBW1,'fill');
RFBW1 = bwmorph(RFBW1,'thicken');
RFBW1 = bwmorph(RFBW1,'close');

% remove small objects 
RFBW1 = bwlabel(RFBW1);
props = regionprops(RFBW1,'Area');
RFBW1 = ismember(RFBW1, find([props.Area] >= detPara.area_min));

% remove big objects 
RFBW1 = bwlabel(RFBW1);
props = regionprops(RFBW1,'Area');
RFBW1 = ismember(RFBW1, find([props.Area] < detPara.area_max));

%remove long objects  
RFBW1 = bwlabel(RFBW1);
props = regionprops(RFBW1,'Eccentricity');
BWFINAL = ismember(RFBW1, find([props.Eccentricity] <= detPara.ecc_max));


if VERBOSE
    figure()
    subplot(2,2,1);
    imshow(Irf);
    subplot(2,2,2);
    imshow(RFBW);
    subplot(2,2,3);
    imshow(RFBW1);
    
    
    BWFINAL = bwlabel(BWFINAL);
    Lrgb = label2rgb(BWFINAL, 'jet', 'w', 'shuffle');
    
    subplot(2,2,4);
    imshow(I);hold on;
    j = imshow(Lrgb);
    alpha(j,0.4)
    
    figure();imshow(I);hold on;
    j = imshow(Lrgb);
    alpha(j,0.4)
end

BWFINAL = bwlabel(BWFINAL);
