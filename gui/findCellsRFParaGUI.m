function varargout = findCellsRFParaGUI(varargin)
% FINDCELLSRFPARAGUI MATLAB code for findCellsRFParaGUI.fig
%      FINDCELLSRFPARAGUI, by itself, creates a new FINDCELLSRFPARAGUI or raises the existing
%      singleton*.
%
%      H = FINDCELLSRFPARAGUI returns the handle to a new FINDCELLSRFPARAGUI or the handle to
%      the existing singleton*.
%
%      FINDCELLSRFPARAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINDCELLSRFPARAGUI.M with the given input arguments.
%
%      FINDCELLSRFPARAGUI('Property','Value',...) creates a new FINDCELLSRFPARAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before findCellsRFParaGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to findCellsRFParaGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help findCellsRFParaGUI

% Last Modified by GUIDE v2.5 27-Aug-2016 14:24:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @findCellsRFParaGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @findCellsRFParaGUI_OutputFcn, ...
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


% --- Executes just before findCellsRFParaGUI is made visible.
function findCellsRFParaGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to findCellsRFParaGUI (see VARARGIN)

% Choose default command line output for findCellsRFParaGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes findCellsRFParaGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


if ~isempty(varargin)
    I = varargin{1};
    exp_path = varargin{2};
    set(handles.open_button,'UserData',{I,exp_path});
    filename = [exp_path filesep 'images' filesep 'image_parameters.mat'];
    if exist(filename,'file')
        try
            load(filename);
        
            set(handles.max_area,'string',sprintf('%i', detPara.area_max));
            set(handles.min_area,'string',sprintf('%i', detPara.area_min));
            set(handles.max_ecc,'string',sprintf('%1.2f', detPara.ecc_max));
            set(handles.se_size,'string',sprintf('%i',detPara.se_size));

            disp('parameters found and loaded');
        catch 
            warning('could not load parameter settings!');
        end
    end
    perform_detection(hObject, eventdata, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = findCellsRFParaGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in open_button.
function open_button_Callback(hObject, eventdata, handles)
% hObject    handle to open_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try 
    [filename, pathname] = uigetfile( {'*.png','*.jpg'},'Chose image');
     I = imread([pathname filesep filename]);
     userdata = get(handles.open_button,'UserData');
     userdata{1} = I;
     
     set(handles.open_button,'UserData',userdata);
     detect_button_Callback(hObject, eventdata, handles);
catch err 
    warning('Open Image: no image was chosen!');
end


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

detPara.area_max = str2double(get(handles.max_area,'string'));
detPara.area_min = str2double(get(handles.min_area,'string'));
detPara.ecc_max = str2double(get(handles.max_ecc,'string'));
se_size = sscanf(get(handles.se_size,'string'),'%i ');

detPara.se_size =  uint8(se_size);

userdata  = get(handles.open_button,'Userdata');
exp_path = userdata{2};
cd([exp_path filesep 'images']);

save('image_parameters.mat','detPara');


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function min_area_Callback(hObject, eventdata, handles)
% hObject    handle to min_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_area as text
%        str2double(get(hObject,'String')) returns contents of min_area as a double


% --- Executes during object creation, after setting all properties.
function min_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_area_Callback(hObject, eventdata, handles)
% hObject    handle to max_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_area as text
%        str2double(get(hObject,'String')) returns contents of max_area as a double


% --- Executes during object creation, after setting all properties.
function max_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_ecc_Callback(hObject, eventdata, handles)
% hObject    handle to max_ecc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_ecc as text
%        str2double(get(hObject,'String')) returns contents of max_ecc as a double


% --- Executes during object creation, after setting all properties.
function max_ecc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_ecc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in detect_button.
function detect_button_Callback(hObject, eventdata, handles)
% hObject    handle to detect_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 

perform_detection(hObject, eventdata, handles);

% try
%     
%     detPara.area_max = str2double(get(handles.max_area,'string'));
%     detPara.area_min = str2double(get(handles.min_area,'string'));
%     detPara.ecc_max = str2double(get(handles.max_ecc,'string'));
%     se_size = sscanf(get(handles.se_size,'string'),'%i ');
%     
%     detPara.se_size =  uint8(se_size);
%     
%     userdata  = get(handles.open_button,'Userdata');
%     I = userdata{1};
%     
%     [BWFINAL,Irf] = findCellsRF(I,detPara);
%     
%     BWFINAL = bwlabel(BWFINAL);
%     Lrgb = label2rgb(BWFINAL, 'jet', 'w', 'shuffle');
%     
%     imshow(I,'parent',handles.image_axes)
%     hold on;
%     j = imshow(Lrgb,'parent',handles.image_axes);
%     alpha(j,0.4)
%     hold off;
% catch err
%     error('could not segment image!');
% end
%   
   
    
    
    
function se_size_Callback(hObject, eventdata, handles)
% hObject    handle to se_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of se_size as text
%        str2double(get(hObject,'String')) returns contents of se_size as a double


% --- Executes during object creation, after setting all properties.
function se_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to se_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename pathname] = uigetfile();

if exist([pathname filename],'file')
    load([pathname filename]);
    set(handles.max_area,'string',num2str(detPara.area_max));
    set(handles.min_area,'string',num2str(detPara.area_min));
    set(handles.max_ecc,'string',num2str(detPara.ecc_max));
    set(handles.se_size,'string',num2str(detPara.se_size));
    perform_detection(hObject, eventdata, handles)

else
    warning('no valid file was chosen. Please select file image_parameters.mat');
end



function perform_detection(hObject, eventdata, handles)

try
    
    detPara.area_max = str2double(get(handles.max_area,'string'));
    detPara.area_min = str2double(get(handles.min_area,'string'));
    detPara.ecc_max = str2double(get(handles.max_ecc,'string'));
    se_size = sscanf(get(handles.se_size,'string'),'%i ');
    
    detPara.se_size =  uint8(se_size);
    
    userdata  = get(handles.open_button,'Userdata');
    I = userdata{1};
    
    [BWFINAL,Irf] = findCellsRF(I,detPara);
    
    BWFINAL = bwlabel(BWFINAL);
    Lrgb = label2rgb(BWFINAL, 'jet', 'w', 'shuffle');
    
    imshow(I,'parent',handles.image_axes)
    hold on;
    j = imshow(Lrgb,'parent',handles.image_axes);
    alpha(j,0.4)
    hold off;
catch err
    error('could not segment image!');
end
