function[tLng,imInfos,am,pm,fm] = performTracking(exp_path,imageName,detection_method,radius,frameRadius,SAVE)
% 
%
%
%
%
% 05.2015 Tim Becker 


% create imInfos struct for easier file handle 
imInfos = openImageseries([exp_path filesep 'images'],imageName);

% image image detection parameters (they can contain different parameters 
% depending on the detection method) 
load([exp_path filesep 'images' filesep 'image_parameters.mat']);

fprintf('peforming cell detection... ');
switch detection_method 
    case 1
        disp('using findCells4...');
        tLng = fillTimelineNG(imInfos,'hsizeI',hsizeI,'sigmaI',sigmaI,'hsizeII',hsizeII, ...
            'sigmaII',sigmaII,'carea',carea,'levelfactor',levelfactor,'stretchPara',stretchPara,...
            'maxcarea',maxcarea,'inverse',inverseFlag);
    case 2
        disp('using findCellsRF...');
        tLng = fillTimelineNG(imInfos,'detect_method',2,'detection_para',detPara);
end
fprintf('done! \n');

% we begin the initial tracking
fprintf('performing tracking... ');
tLng = correctTimelineNG(tLng,'verbose',0);

% create initial path-matrix and adjacency matrix
[am,pm,eList,tLng] = fillEList(tLng,'verbose',0,'fillup',1);

% we fill the path-status ( donnot get confused here:
% the timelinestruct stores the path as status -> the value
% of the status is stored in the timeline struct
[tLng,pm] = fillPathStatus(tLng,am,pm);
fprintf('done! \n');

fprintf('calculating morphological feature...');
fm = getFeatureMatrix(tLng,imInfos);
fprintf('done! \n');

size_pm = size(pm,1);

fprintf('Connecting broken paths...');
verbose = 1;
[tLng,am,pm] = connectLostEndsLostBeginsSpatial(tLng,am,pm,radius,verbose);
[tLng,am,pm] = connectLostEndsLostBeginsTemporal(tLng,am,pm,radius,frameRadius,verbose);
size_pm_connected = size(pm,1);
fprintf('done!  ');
fprintf('connected %i paths \n',size_pm - size_pm_connected);

if SAVE
    fprintf('saving data... ');
    save([exp_path filesep 'results' filesep 'image_tLng.mat'],'tLng','imInfos','am','pm','fm');
    fprintf('done. ');
end

