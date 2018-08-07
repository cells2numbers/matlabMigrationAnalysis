function varargout = migrationAnalysis(varargin)
% MIGRATIONANALYSIS MATLAB code for migrationAnalysis.fig
%      MIGRATIONANALYSIS, by itself, creates a new MIGRATIONANALYSIS or raises the existing
%      singleton*.
%
%      H = MIGRATIONANALYSIS returns the handle to a new MIGRATIONANALYSIS or the handle to
%      the existing singleton*.
%
%      MIGRATIONANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIGRATIONANALYSIS.M with the given input arguments.
%
%      MIGRATIONANALYSIS('Property','Value',...) creates a new MIGRATIONANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before migrationAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to migrationAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help migrationAnalysis

% Last Modified by GUIDE v2.5 19-May-2015 19:21:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @migrationAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @migrationAnalysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before migrationAnalysis is made visible.
function migrationAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to migrationAnalysis (see VARARGIN)

% Choose default command line output for migrationAnalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes migrationAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = migrationAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbutton_detection_parameter.
function pushbutton_detection_parameter_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_detection_parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% path to the image data, images are stored as image_001.png,
% image002.png
experiment_path = get(handles.pushbutton_load_experiment,'UserData');
cd([experiment_path filesep 'images']);

if (exist([experiment_path filesep 'images' filesep 'image_0001.png'],'file'))     
    I = imread([experiment_path filesep 'images' filesep 'image_0001.png']);

elseif (exist([experiment_path filesep 'images' filesep 'image_0001.png'],'file'))     
    I = imread([experiment_path filesep 'images' filesep 'image_0001.png']);   
end
% we use an old GUI to select appropiate parameters for image segmentation

detection_method =  get(handles.popupmenu_detection_parameter,'Value');

switch detection_method
    
    case 1
        h = findCellsParaGUI(I,experiment_path,'image_0001.png');
        waitfor(h);
    case 2
        h = findCellsRFParaGUI(I,experiment_path);
        waitfor(h); 
    
end

update_migrationAnalysis(handles);

% --- Executes on button press in pushbutton_perform_tracking.
function pushbutton_perform_tracking_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_perform_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


t = tic; 
radius = 45;
frameRadius = 3;

experiment_path = get(handles.pushbutton_load_experiment,'UserData');
detection_method =  get(handles.popupmenu_detection_parameter,'Value');

performTracking(experiment_path,'image_0001.png',...
    detection_method,radius,frameRadius,1);

% update figure (activate Analyse push buttobn 

fprintf('Finished in %6.1f seconds \n',toc(t));
update_migrationAnalysis(handles)

function update_migrationAnalysis(handles)
% not sure if I will use this function... just an idea
% ok, i use it.
%
%

experiment_path = get(handles.pushbutton_load_experiment,'UserData');

if exist([experiment_path filesep 'expInfo.mat'],'file')
    set(handles.pushbutton_detection_parameter,'Enable','on');
    set(handles.popupmenu_detection_parameter,'Enable','on');
else
    set(handles.pushbutton_detection_parameter,'Enable','off');
    set(handles.popupmenu_detection_parameter,'Enable','off');
end

if exist([experiment_path filesep 'images' filesep 'image_parameters.mat'],'file')
    set(handles.pushbutton_perform_tracking,'Enable','on');
    set(handles.pushbutton_batch_tracking,'Enable','on');
else
    set(handles.pushbutton_perform_tracking,'Enable','off');
    set(handles.pushbutton_batch_tracking,'Enable','off');
end


%if exist(['images' filesep 'image_tLng.mat'],'file')
if exist([experiment_path filesep 'results' filesep 'image_tLng.mat'],'file')
    set(handles.pushbutton_analyse,'Enable','on');
    set(handles.pushbutton_batch_analyse,'Enable','on');
else
    set(handles.pushbutton_batch_analyse,'Enable','off');
end



% --- Executes on button press in pushbutton_load_experiment.
function pushbutton_load_experiment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load folder containing the image sequence. This is the central folder
% storing all data.

experiment_path = uigetdir();
set(handles.pushbutton_load_experiment,'UserData',experiment_path);
if ~isempty(experiment_path)
    cd(experiment_path);
end

update_migrationAnalysis(handles);


% --- Executes on button press in pushbutton_analyse.
function pushbutton_analyse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_analyse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PLOTMORE = 1;
minPathLength = 20;

expPath = get(handles.pushbutton_load_experiment,'UserData');
performMigrationAnalysis(expPath,PLOTMORE,minPathLength);


% --- Executes on button press in pushbutton_new_experiment.
function pushbutton_new_experiment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_new_experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% for each new experiment a new folder is created. This folder contains
% all information (images, parameter files etc)

% select image sequence
[filename, pathname] = uigetfile( ...
    {'*.tif';'*.tiff';'*.*'},...
    'Load image sequence');


if ~isempty(filename) && ~isequal(filename,0)
    % remove file extension and create subfolders for the
    % image sequence, detection and tracking parameters and the
    % results
    
    experiment_path = [pathname filesep filename(1:(end-4))];
    set(handles.pushbutton_load_experiment,'UserData',experiment_path);
    
    
    % create folder and subfolder
    mkdir(experiment_path);
    mkdir([experiment_path filesep 'images']);
    %mkdir([experiment_path filesep 'parameters']);
    mkdir([experiment_path filesep 'results']);
    
    
    % open image sequence using the image formats tools and extract data
    % The image sequence is stored as multiple files to speed up
    % calculation and reduce needed amount of RAM / CPU to handle big
    % image sequences)
    I = bfopen([pathname filesep filename]);
    cd([experiment_path filesep 'images']);
    
    h_waitbar = waitbar(0,'Extracting images...');
    for i=1:size(I{1},1)
        filename = sprintf('image_%03i.png',i');
        imwrite(I{1}{i},filename,'png');
        
        waitbar(i/size(I{1},1),h_waitbar)
    end
    fprintf('\n done! \n');
    close(h_waitbar);
    
    % create expInfo.mat in the root experiment path  and store date of
    % exp. creation and the number of images
    cd(experiment_path);
    date_created =  datestr(now);
    number_of_images = size(I{1},1);
    save('expInfo.mat','date_created','number_of_images','experiment_path');
    
else
    fprintf('no image sequence selected. Aborting \n');
end

update_migrationAnalysis(handles);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_detection_parameter.
function popupmenu_detection_parameter_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_detection_parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_detection_parameter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_detection_parameter


% --- Executes during object creation, after setting all properties.
function popupmenu_detection_parameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_detection_parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_batch_tracking.
function pushbutton_batch_tracking_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_batch_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

expPath = uigetdir();
OVERWRITE = 0;

if isequal(expPath,0)
    warning('no path selected, aborting');
else
    performBatchTracking(expPath,OVERWRITE)
end

% --- Executes on button press in pushbutton_batch_analyse.
function pushbutton_batch_analyse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_batch_analyse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

OVERWRITE = 0;

expPath = uigetdir();
if isequal(expPath,0)
   warning('No directory loaded! Please select valid dir'); 
else
    performBatchMigrationAnalysis(expPath,OVERWRITE)
end
    


% --- Executes on button press in pushbutton_publish_analysis.
function pushbutton_publish_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_publish_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


expPath = uigetdir();
performPublishAnalysis(expPath)
