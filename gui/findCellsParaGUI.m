function varargout = findCellsParaGUI(varargin)
% findCellsParaGUI creates a parameter-file for the 
% detection.
%
% findCellsParaGUI();
%
%
% You can load a picture from a imageseries, set 
% the detection-parameters (hsizeI, ..., levelfactor)
% and press 'detect'. You can change the parameters until 
% you are happy with what is detected. Optimally, you 
% load a picture from the beginning (001.png), choose some
% parameters, load one from the middle, adjust them, load 
% one from the end, adjust again, and check with the first 
% image again. Then press 'Save'. This saves the chosen parameters
% in a folder created for the detection (later, the tLng will be 
% stored in that folder, too, as well as the graphs of populationDensity).
% 
% 
% 
%
% See also: folderCreator, masterscriptDetection
%
% created:      june 09, 2010; j.a.
% modified:     jan. 31, 2011; j.a.


% Edit the above text to modify the response to help findCellsParaGUI

% Last Modified by GUIDE v2.5 12-May-2015 12:46:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @findCellsParaGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @findCellsParaGUI_OutputFcn, ...
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


% --- Executes just before findCellsParaGUI is made visible.
function findCellsParaGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to findCellsParaGUI (see VARARGIN)

% Choose default command line output for findCellsParaGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if ~isempty(varargin)
    imagepath = varargin{2};
    imagename = varargin{3};
    userdata = get(handles.openbutton,'UserData'); % {}
    
    I = varargin{1};
    if size(I,3) > 1
        I = rgb2gray(I);
    end
    
    % check, if figure is already open
    if isempty(userdata)
        peter = figure();
        imagesc(I);
        set(hObject,'UserData',{imagepath,imagename,peter,I});
    else
        % if there is a figure, update the info for the newly loaded picture
        userdata{1} = imagepath;
        userdata{2} = imagename;
        userdata{4} = I;
        
    end
    
   % userdata = get(hObject,'Userdata');
    
    % plot the picture into the figure
    % don't open a new one!
    %peter = userdata{3};
    figure(peter);
    imagesc(I);
    colormap gray
    set(handles.openbutton,'UserData',{imagepath,imagename,peter,I});
    
    % as there is a new picture, cell-counts from before don't count anymore
    set(handles.cellstext,'String','---');
    
    set(handles.meanareatext,'String','---');
    
    %empty cellmask-field for storing the cellmask in
    cellmask_field = [];
    % hand data over to singleframe-cellmask-Button
    set(handles.switchbutton,'Userdata',{imagepath,imagename,peter,I,cellmask_field});
    set(handles.switchbutton,'Value',0);
    
    set(handles.savebutton,'Userdata',{});
end



% UIWAIT makes findCellsParaGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = findCellsParaGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in openbutton.
function openbutton_Callback(hObject, eventdata, handles)
% hObject    handle to openbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get name and path of the loaded picture
[imagename, imagepath] = ...
	uigetfile({'*.*';'*.png';'*.jpg'},'File Selector');

% if not cancelled
if imagepath
    % update the gui, setting the filename
    set(handles.filetext,'String',imagename);
    
    % cd to the imagepath
    cd(imagepath);
    
    userdata = get(hObject,'Userdata');
    % load the picture
    I = imread([imagepath imagename]);
    
    % if the picture is coloured, transform it into black/white
    if size(I,3) > 1
        I = rgb2gray(I);
    end
    
    % check, if figure is already open
    % if not, open it (ITS NAME IS PETER!!!) and plot the picture
    if isempty(userdata)
        peter = figure();
        imagesc(I);
        set(hObject,'UserData',{imagepath,imagename,peter,I});
    else
        % if there is a figure, update the info for the newly loaded picture
        userdata{1} = imagepath;
        userdata{2} = imagename;
        userdata{4} = I;
    end
    
    userdata = get(hObject,'Userdata');
    
    % plot the picture into the figure
    % don't open a new one!
    peter = userdata{3};
    figure(peter);
    imagesc(I);
    colormap gray
    set(hObject,'UserData',{imagepath,imagename,peter,I});
    
    % as there is a new picture, cell-counts from before don't count anymore
    set(handles.cellstext,'String','---');
    
    set(handles.meanareatext,'String','---');
    
    %empty cellmask-field for storing the cellmask in
    cellmask_field = [];
    % hand data over to singleframe-cellmask-Button
    set(handles.switchbutton,'Userdata',{imagepath,imagename,peter,I,cellmask_field});
    set(handles.switchbutton,'Value',0);
    
    set(handles.savebutton,'Userdata',{});
end



% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load an existing Parameter-File to see the set parameters and/ or change
% and save them. 

% choose the mat-File
[fname pname] = uigetfile('*.mat','select mat-file with detection parameters');

% if this function is called from the evaluateZellscanner.m 
if ~exist('imInfos','var')
    if exist([pwd filesep 'hologram_raw_001.png'],'file')
        imInfos = openImageseries(pwd,'hologram_detection_001.png');
    end
end
    
if pname
        
    % cd to the path of the parameter-file
    cd(pname);
    
    % check if an windows with a cell image exists already (figure called
    % "peter" )
    userdata = get(handles.openbutton,'UserData');
    if ~isempty(userdata) && length(userdata) > 3 && ishandle(userdata{3})
        peter = userdata{3};
    end
    
    % load the variables
    load([pname fname]);
    set(handles.filetext,'String',fname);
    
    % if they exist, set them into the userdata and display them in the gui
    if exist('imInfos','var')
        if ~exist(getFilename2(imInfos,1),'file')
            warndlg('No images found! Where did you hide them???','Image Error!');
            pause(1);
            imInfos = openImageseries();
        end
        
        userdata{1} = imInfos;
        imagepath = imInfos.path;
        imagename = [imInfos.first imInfos.number '.' imInfos.type];
        set(handles.filetext,'String',imagename);
        
        I = imread([imagepath imagename]);
        if ~exist('peter','var')
            peter = figure();
        end
        
        set(handles.openbutton,'Userdata',{imagepath,imagename,peter,I});
        figure(peter);
        imagesc(I);
        colormap gray
    else
        warndlg('No image-infos are set! What you gonna do now?!?!?','Image-Info Error!');
    end
    
    if exist('hsizeI','var')
        userdata{2} = hsizeI;
        if isequal(size(hsizeI),[2,1])
            text1 = sprintf('%i %i',hsizeI(1),hsizeI(2));
        else
            text1 = sprintf('%i',hsizeI);
        end
        set(handles.hsizeItext,'String',text1);
    else
        set(handles.hsizeItext,'String','60 60');
    end
    
    if exist('sigmaI','var')
        userdata{3} = sigmaI;
        set(handles.sigmaItext,'String',sigmaI);
    else
        set(handles.sigmaItext,'String','30');
    end
    
    if exist('hsizeII','var')
        userdata{4} = hsizeII;
        if isequal(size(hsizeII),[2,1])
            text2 = sprintf('%i %i',hsizeII(1),hsizeII(2));
        else
            text2 = sprintf('%i',hsizeII);
        end
        set(handles.hsizeIItext,'String',text2);
    else
        set(handles.hsizeIItext,'String','2 2');
    end
    
    if exist('sigmaII','var')
        userdata{5} = sigmaII;
        set(handles.sigmaIItext,'String',sigmaII);
    else
        set(handles.sigmaIItext,'String','0.5');
    end
    
    if exist('carea','var')
        userdata{6} = carea;
        set(handles.careatext,'String',carea);
    else
        set(handles.careatext,'String','50');
    end
    
    if exist('maxcarea','var')
        userdata{11} = maxcarea;
        set(handles.maxcareatext,'String',maxcarea);
    else
        set(handles.maxcareatext,'String','1000');
    end
    
    if exist('levelfactor','var')
        userdata{7} = levelfactor;
        set(handles.levelfactortext,'String',levelfactor);
    else
        set(handles.levelfactortext,'String','1');
    end
    
    if exist('stretchPara','var') && isequal(size(stretchPara),[2,1])
        userdata{8} = stretchPara;
        string_paras = sprintf('%6.4f   %6.4f',stretchPara(1),stretchPara(2));
        set(handles.stretchParatext,'String',string_paras);
    else
        userdata{8} = '';
        set(handles.stretchParatext,'String','');
        set(handles.calcStretchParatext,'String','---   ---');
    end
    
    if exist('inverseFlag','var') 
       userdata{12}=inverseFlag;
       set(handles.inverseCheckbox2,'value',inverseFlag);
    end
    
    if exist('const','var')
        userdata{13} = const;
        set(handles.edit_const,'String',const);
    else
        set(handles.edit_const,'String','0');
        userdata{13} = 0;
        set(handles.edit_const,'String',0);
    end


    set(handles.cellstext,'String','---');
    set(handles.meanareatext,'String','---');
    
    set(handles.savebutton,'Userdata',{});
end




% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% THIS IS CRAP THAT URGENTLY NEEDS TO BE CHANGED INTO SOMETHING USEFUL!!!!
% IT'S STILL WORKING, THOUGH

% CHANGED THAT (USEFUL) CRAP INTO SOMETHING THAT IS USEFUL *AND* NICE!!!
% 08.06.10, j.a. (anmerkung tim: no, not nice, not even close)


userdata = get(hObject,'Userdata');

if isempty(userdata)
   warndlg('No data to save. Have you loaded a picture and detected the cells, yet? If yes, contact the programmer, if not, then why are you busy reading this message and not ALREADY DOING IT?!?!?');
else
    imagepath = userdata{1};
    imagename = userdata{2};
    
    imInfos = openImageseries(imagepath,imagename);
    
    hsizeI = userdata{4};
    sigmaI = userdata{5};
    hsizeII = userdata{6};
    sigmaII = userdata{7};
    carea = userdata{8};
    levelfactor = userdata{9};
    
    
%     text3 = get(handles.stretchParatext,'string');
%     stretchPara = sscanf(text3,'%f %f');
%     if isequal(size(stretchPara),[2,1])

    stretchPara = userdata{10};
    maxcarea = userdata{11};
    inverseFlag = userdata{12};
    const = userdata{13};
    %     end
   
    
    
    %we check, if we are in a detection struct

    % this function sucks -> it strongly depends on 
    % on the given directory structure... 
    %
    % -> SHOULD BE REWRITTEN, tb
    %
    % we have to check, if we have a valid detection folder
    %
    
    % this is the path where all our image are stored,
    % this one is valid and exist
    pathname = imInfos.path;
    
    % if this folder belongs to a correct dir-struct, there exist
    % a readme-file at the root level of the dir-structure.
    %
    % to check this, we have to look in the parent of the parent
    % as the root folder contains /001/ph1
    %
    
    % we find the position of each filesep
    [s,n] = regexp(pathname, filesep, 'split');
    
    % now, we delete the last two directory names
    readmepath = pathname(1:n(end-2));
    
    % next, we can check if the readme exists,
    % 
    % added by tb
    
    if exist([readmepath filesep 'readme.mat'],'file')==2
        
        folder = ['timeline' filesep 'detection'];
        savepath = makeSavePath(imInfos.path,folder,'uplevel',1,'numbering',1);
        
        [s,n] = regexp(savepath, filesep, 'split');
        ExpPath = savepath(1:n(end-3));
        
        % if we dont have a detection struct given, we save
        % the file in the image folder
        
        
        imInfos2 = checkImInfos2(ExpPath,imInfos);
        
        
        detParaPath = [savepath  imInfos.first 'parameters.mat'];
        
        if ~isempty(imInfos2)
            save(detParaPath,'imInfos','imInfos2',...
                'hsizeI','sigmaI','hsizeII','sigmaII','carea',...
                'levelfactor','stretchPara','maxcarea','inverseFlag',...
                'const');
        else
            save(detParaPath,'imInfos',...
                'hsizeI','sigmaI','hsizeII','sigmaII','carea',...
                'levelfactor','stretchPara','maxcarea','inverseFlag',...
                'const');
        end
        
        
        checkPaths('ExpPath',ExpPath,'verbose',0);
        
        message = sprintf('Saved the .mat-File in \n\n%s \n\ncontaining EVERY bit of information for your timeline!!',detParaPath);
        msgbox(message,'Saved!');
        
    else % we are not in a detection directory (no readme given)
        % -> we store the file in the image folder
        fprintf('no detection directory found (no readme), storing files');
        fprintf('in the image directory\n');
        savename = [imInfos.path  imInfos.first 'parameters.mat'];
        save(savename,'imInfos',...
            'hsizeI','sigmaI','hsizeII','sigmaII','carea',...
            'levelfactor','stretchPara','maxcarea','inverseFlag','const');
    end
    
end


% --- Executes on button press in detectbutton.
function detectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to detectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata = get(handles.openbutton,'UserData');


% read the parameters for the detection
% and catching empty parameters!

hsizeI =  sscanf(get(handles.hsizeItext,'string'),'%i %i');
if isempty(hsizeI) 
    hsizeI = [60;60];
    warndlg('hsizeI was not set! Using Standard-Value ([60;60])!');
%     set(handles.hsizeItext,'string','60 60');
end
set(handles.hsizeItext,'string',num2str(hsizeI'));


sigmaI = str2double(get(handles.sigmaItext,'string'));
if isnan(sigmaI)
    sigmaI = 30;
    warndlg('sigmaI was not set! Using Standard-Value ([30])!');
    set(handles.sigmaItext,'string','30');
end


hsizeII = sscanf(get(handles.hsizeIItext,'string'),'%i %i');
if isempty(hsizeII)
    hsizeII = [2;2];
    warndlg('hsizeII was not set! Using Standard-Value ([2;2])!');
%     set(handles.hsizeIItext,'string','2 2');
end
set(handles.hsizeIItext,'string',num2str(hsizeII'));

sigmaII = str2double(get(handles.sigmaIItext,'string'));
if isnan(sigmaII)
    sigmaII = 0.5;
    warndlg('sigmaII was not set! Using Standard-Value ([0.5])!');
    set(handles.sigmaIItext,'string','0.5');
end


carea = str2double(get(handles.careatext,'string'));
if isnan(carea)
    carea = 50;
    warndlg('carea was not set! Using Standard-Value ([50])!');
    set(handles.careatext,'string','50');
end

maxcarea = str2double(get(handles.maxcareatext,'string'));
if isnan(maxcarea)
    maxcarea = 1000;
    warndlg('carea was not set! Using Standard-Value ([1000])!');
    set(handles.careatext,'string','1000');
end


levelfactor = str2double(get(handles.levelfactortext,'string'));
if isnan(levelfactor)
    levelfactor = 1;
    warndlg('levelfactor was not set! Using Standard-Value ([1])!');
    set(handles.levelfactortext,'string','1');
end

inverseFlag = get(handles.inverseCheckbox2,'value');
if isnan(inverseFlag)
    inverseFlag = 0;
    warndlg('inverseFlag was not set! Using Standard-Value ([0])!');
    set(handles.inverseCheckbox2,'value',0);
end

const = str2double(get(handles.edit_const,'String'));
if isnan(const)
    const = 0;
    warndlg('const was not set! Using Standard-Value ([0])!');
    set(handles.edit_const,'String','0');
end



% added 07.06.10 by t.b and j.a., adjusting the detection by setting the
% limits for imadjust manually 
text3 = get(handles.stretchParatext,'string');
stretchPara = sscanf(text3,'%f %f');


if ~isempty(userdata)
    % if a picture is loaded, do the following:
    imagepath = userdata{1};
    imagename = userdata{2};

    I = userdata{4};
    
    % for debugging purpose: you 
    BP = 0;
    
    if isequal(size(stretchPara),[2,1])
        % calculate the cellmask
        [cm Image stretchPara2]= findCells4(I,'hsizeI',hsizeI,'sigmaI',sigmaI,...
            'hsizeII',hsizeII,'sigmaII',sigmaII, ...
            'carea',carea,'levelfactor',levelfactor,...
            'stretchPara',stretchPara,'maxcarea',maxcarea,...
            'inverse',inverseFlag,'breakpoint',BP,'const',const);
        userdata{5} = cm;
    else
        % calculate the cellmask
        [cm Image stretchPara2]= findCells4(I,'hsizeI',hsizeI,'sigmaI',sigmaI,...
            'hsizeII',hsizeII,'sigmaII',sigmaII, ...
            'carea',carea,'levelfactor',levelfactor,...
            'maxcarea',maxcarea,'inverse',inverseFlag,...
            'breakpoint',BP,'const',const);
        userdata{5} = cm;
    end
    string_paras = sprintf('%6.4f   %6.4f',stretchPara2(1),stretchPara2(2));
    set(handles.calcStretchParatext,'String',string_paras);
    
    set(handles.switchbutton,'Value',1);
    set(handles.switchbutton,'Userdata',userdata);

    % calculating the cellnumber
    area_props = regionprops(cm,'Area');
    cell_count = length(area_props);
    areasizes = [area_props.Area];
    
    %calculate the mean areasize
    mean_areasize = mean(areasizes);
    
    %set the value into the corresponding info-box
    set(handles.meanareatext,'String',round(mean_areasize));

    % update the number into the info-panel
    set(handles.cellstext,'String',cell_count);
    
    if ~isempty(userdata{3})
        % activate the figure to plot the picture in
        figure(userdata{3});
        ax = axis();
        imagesc(im2bw(cm));
        axis(ax);
        colormap(gray);
    end
    
    % if no stretchPara is set by the user, we do not want to save the
    % local one from findCellsParaGUI. THAT is just to display for the loaded
    % picture which limits are best to use!!!
    % We want it actually to stay empty, so when loaded to detect the
    % cells (e.g. by createTimelineStruct which calls findCells4), it
    % signals that the Paras have to be calculated for each picture again!
    % In the other case, of course, if the user wants to have fixed
    % stretchParas, he sets them, they are saved and handed to findCells4
    % as fixed limits.
    if isequal(size(stretchPara),[2,1])
        tempUserdata = {imagepath,imagename,cm,...
            hsizeI,sigmaI,hsizeII,sigmaII,carea,levelfactor,stretchPara2,maxcarea,inverseFlag,const};
        set(handles.savebutton,'Userdata',tempUserdata);
    else
        if isempty(stretchPara)
            tempUserdata = {imagepath,imagename,cm,...
                hsizeI,sigmaI,hsizeII,sigmaII,carea,levelfactor,stretchPara,maxcarea,inverseFlag,const};
            set(handles.savebutton,'Userdata',tempUserdata);
        else
            warndlg('Wrong input at stretchPara-field! Check dat aut!','Input Error');
        end
    end
else
    warndlg('Please load a picture!','Data Error');
end




% --- Executes on button press in switchbutton.
function switchbutton_Callback(hObject, eventdata, handles)
% hObject    handle to switchbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata = get(hObject,'Userdata');

% switches from the original picture to the calculated cellmask and back!
if isempty(userdata)
    warndlg('Warning! No Picture loaded or no cells detected, yet! Cannot switch from nothing to nothing, what did you think?');
    set(hObject, 'Value',0);
else
    if ~get(hObject,'Value')
        figure(userdata{3});
        ax = axis;
        imagesc(userdata{4});
        axis(ax);
    end
    
    if get(hObject,'Value') && isempty(userdata{5})
        warndlg('Calculate Cellmask first!','Cellmask Error');
        set(hObject,'Value',0);
    end
    
    if get(hObject,'Value') && ~isempty(userdata{5})
        cm = userdata{5};
        figure(userdata{3});
        ax = axis;
        imagesc(im2bw(cm));
        axis(ax);
    end
end


function hsizeItext_Callback(hObject, eventdata, handles)
% hObject    handle to hsizeItext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hsizeItext as text
%        str2double(get(hObject,'String')) returns contents of hsizeItext as a double


% --- Executes during object creation, after setting all properties.
function hsizeItext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hsizeItext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigmaItext_Callback(hObject, eventdata, handles)
% hObject    handle to sigmaItext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigmaItext as text
%        str2double(get(hObject,'String')) returns contents of sigmaItext as a double


% --- Executes during object creation, after setting all properties.
function sigmaItext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigmaItext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hsizeIItext_Callback(hObject, eventdata, handles)
% hObject    handle to hsizeIItext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hsizeIItext as text
%        str2double(get(hObject,'String')) returns contents of hsizeIItext as a double


% --- Executes during object creation, after setting all properties.
function hsizeIItext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hsizeIItext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigmaIItext_Callback(hObject, eventdata, handles)
% hObject    handle to sigmaIItext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigmaIItext as text
%        str2double(get(hObject,'String')) returns contents of sigmaIItext as a double


% --- Executes during object creation, after setting all properties.
function sigmaIItext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigmaIItext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function careatext_Callback(hObject, eventdata, handles)
% hObject    handle to careatext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of careatext as text
%        str2double(get(hObject,'String')) returns contents of careatext as a double


% --- Executes during object creation, after setting all properties.
function careatext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to careatext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function levelfactortext_Callback(hObject, eventdata, handles)
% hObject    handle to levelfactortext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of levelfactortext as text
%        str2double(get(hObject,'String')) returns contents of levelfactortext as a double


% --- Executes during object creation, after setting all properties.
function levelfactortext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to levelfactortext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function emblogo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emblogo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate emblogo
axes(hObject);
logo = which('emblogo_xs.png');
I = imread(logo);
imshow(I);



function stretchParatext_Callback(hObject, eventdata, handles)
% hObject    handle to stretchParatext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stretchParatext as text
%        str2double(get(hObject,'String')) returns contents of stretchParatext as a double


% --- Executes during object creation, after setting all properties.
function stretchParatext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stretchParatext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







function maxcareatext_Callback(hObject, eventdata, handles)
% hObject    handle to maxcareatext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxcareatext as text
%        str2double(get(hObject,'String')) returns contents of maxcareatext as a double


% --- Executes during object creation, after setting all properties.
function maxcareatext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxcareatext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function savebutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on key press with focus on careatext and none of its controls.
function careatext_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to careatext (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function sigmaItext_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to sigmaItext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over sigmaItext.
function sigmaItext_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to sigmaItext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on sigmaItext and none of its controls.
function sigmaItext_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to sigmaItext (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in inverseCheckbox.
function inverseCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to inverseCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of inverseCheckbox


% --- Executes on button press in inverseCheckbox2.
function inverseCheckbox2_Callback(hObject, eventdata, handles)
% hObject    handle to inverseCheckbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of inverseCheckbox2


% --- Executes when uipanel1 is resized.
function uipanel1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_const_Callback(hObject, eventdata, handles)
% hObject    handle to edit_const (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_const as text
%        str2double(get(hObject,'String')) returns contents of edit_const as a double


% --- Executes during object creation, after setting all properties.
function edit_const_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_const (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
