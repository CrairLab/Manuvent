function varargout = Manuvent_threshold(varargin)
% MANUVENT_THRESHOLD MATLAB code for Manuvent_threshold.fig
%      MANUVENT_THRESHOLD, by itself, creates a new MANUVENT_THRESHOLD or raises the existing
%      singleton*.
%
%      H = MANUVENT_THRESHOLD returns the handle to a new MANUVENT_THRESHOLD or the handle to
%      the existing singleton*.
%
%      MANUVENT_THRESHOLD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUVENT_THRESHOLD.M with the given input arguments.
%
%      MANUVENT_THRESHOLD('Property','Value',...) creates a new MANUVENT_THRESHOLD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Manuvent_threshold_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Manuvent_threshold_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Manuvent_threshold

% Last Modified by GUIDE v2.5 20-Feb-2020 12:56:42

% Version 0.0.6 02/02/2020 yixiang.wang@yale.edu

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Manuvent_threshold_OpeningFcn, ...
                   'gui_OutputFcn',  @Manuvent_threshold_OutputFcn, ...
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

% --- Executes just before Manuvent_threshold is made visible.
function Manuvent_threshold_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Manuvent_threshold (see VARARGIN)

% Choose default command line output for Manuvent_threshold
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Manuvent_threshold wait for user response (see UIRESUME)
% uiwait(handles.Manuvent_threshold);


% --- Outputs from this function are returned to the command line.
function varargout = Manuvent_threshold_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_movie.
function Load_movie_Callback(hObject, eventdata, handles)
% hObject    handle to Load_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Detect whether data acuqired from the last run was saved
if isfield(hObject.UserData, 'filename')&& ~isempty(handles.listbox.UserData.allROI_info)
    filename = hObject.UserData.filename;
    savename = [filename(1:end-4) '_allROI_info.mat'];
    if ~exist(savename,'file')
        selection = questdlg('Did you save the previous data?','Confirm save','Save','Yes, I did.','Save');
        switch selection
            case 'Save'
                allROI_info = handles.listbox.UserData.allROI_info;
                allROI = handles.listbox.UserData.allROI;
                %save all ROI(events) info as a .mat file
                uisave({'allROI_info', 'allROI'}, [filename(1:end-4) '_allROI.mat']);
        end
    end
end

%Clean previous data if existed
handles.listbox.String = {};
handles.listbox.UserData.allROI = {};
handles.listbox.UserData.allROI_info = [];
handles.listbox.Value = 1;
handles.Background_noise.UserData = [];
handles.Line_scan.UserData = [];
handles.Rotate_rectangle.UserData = [];
handles.Save_cropped.UserData = [];
handles.Load_noise.UserData = [];

%Show loading progress
set(handles.Text_load, 'Visible', 'On')
set(handles.Text_load, 'String', 'Loading...')
set(handles.Text_playing, 'Visible', 'off')

%Load the dF/F .mat movie
[filename,path]=uigetfile('*.mat','Please load the movie (mat) file!');
LoadNewMovie(path, filename, handles);


function LoadNewMovie(path, filename, handles)
%Load new movie given path and filename, also renew the axes
    
    load(fullfile(path,filename));
    %hObject.UserData.filename = file;
    handles.Load_movie.UserData.filename = filename;

    %Show filename
    handles.Current_filename.String = filename;

    %Get specific tag
    curTag = filename(1:14);
    fileList = dir(['*' curTag '*' '.mat']);
    handles.Load_movie.UserData.fileList = fileList;

    %Get index of current movie
    for i = 1:length(fileList)
        if strcmp(filename,fileList(i).name)
            handles.Next_movie.UserData.curMovIdx = i;
            break;
        end
    end


    %Clean index information from the previous movie
    handles.play.UserData = [];
    handles.Play_control.UserData.curIdx = 1;
    handles.Frame.String = '1';

    %Store the movie into a variable curMovie
    try
        vList = whos; 
        for i = 1:size(vList,1)
            %Search for 3D matrix
            if length(vList(i).size) == 3 
                curMovie = eval(vList(i).name);
                %hObject.UserData = curMovie;
                set(handles.Text_load, 'String', 'Finished!')
                break
            end
        end  
    catch
        set(handles.Text_load, 'String', 'Error!')
        msgbox('Can not load the dF over F movie!','Error!')
        return
    end

    curMovie(curMovie == 0) = nan;

    %Save the movie and its size as an object to the UserData of the GUI
    sz = size(curMovie);
    curObj.sz = sz;
    curObj.duration = sz(3);
    curObj.curMovie = curMovie;
    set(handles.output, 'UserData', curObj);

    %Set parameters for slider1
    set(handles.slider1, 'Min', 1);
    set(handles.slider1, 'Max', sz(3));
    set(handles.slider1, 'Value', 1);
    set(handles.slider1, 'SliderStep', [1/(sz(3)-1), 0.05]);
    
    %Show the first frame
    hold off;
    im = imshow(mat2gray(curMovie(:,:,1)), 'Parent', handles.Movie_axes1);
    set(im, 'ButtonDownFcn', {@markEvents, handles});



% --- Executes on button press in Save_data.
function Save_data_Callback(hObject, eventdata, handles)
% hObject    handle to Save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = handles.Load_movie.UserData.filename;
allROI_info = handles.listbox.UserData.allROI_info;
allROI = handles.listbox.UserData.allROI;
start_frame = min(allROI_info(:,3));
end_frame = max(allROI_info(:,4));
%save all ROI(events) info as a .mat file
uisave({'allROI_info', 'allROI'}, [filename(1:end-4) ...
    '_' num2str(start_frame) '_' num2str(end_frame) '_allROI.mat']);

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



% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox

try
    curMovie = handles.output.UserData.curMovie;%Get current movie
    curVal = get(hObject,'Value'); %Get current value
    allROI = handles.listbox.UserData.allROI; %Get all ROI objects
    allROI_info = handles.listbox.UserData.allROI_info;
    roi = allROI{curVal}; %Get corresponding roi obj
    roi_info = allROI_info(curVal,:); %Get corresponding roi info

    %Get the index of the first frame
    ini_idx = roi_info(3); 

    %Show current roi
    roi.Parent = handles.Movie_axes1;
    roi.Visible = 'on';
    roi.Color = 'r';
    pause(0.5);
    roi.Color = 'g';

    %Listening to the deleting events
    addlistener(roi, 'DeletingROI', @(src,evt)deleteCallback(src,evt,handles));
    %Listening to the moving events
    addlistener(roi, 'ROIMoved', @(src,evt)movedCallback(src,evt,handles));
    %Listening to the clicking events
    addlistener(roi, 'ROIClicked', @(src,evt)clickedCallback(src,evt,handles));

    hold on;

    %Update current roi
    handles.Plot_correlation.UserData.curROI = roi;

    %Jump to the frame where the current roi was created
    im = imshow(mat2gray(curMovie(:,:,ini_idx)), 'Parent', handles.Movie_axes1);
    set(im, 'ButtonDownFcn', {@markEvents, handles});
    %Set current index to the initial index of the selected event
    handles.Play_control.UserData.curIdx = ini_idx; 
    %Reset slider value
    handles.slider1.Value = ini_idx;
    %Reset Frame editbox string
    handles.Frame.String = num2str(ini_idx);

    set(handles.Text_playing, 'String', 'First frame')
catch
    warning('Something wrong to load the listbox!')
end


% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.String = {};
hObject.UserData.allROI = {};
hObject.UserData.allROI_info = [];

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
curMovie = handles.output.UserData.curMovie; %Get current movie
curIdx = round(get(hObject, 'Value'));
im = imshow(mat2gray(curMovie(:,:,curIdx)), 'Parent', handles.Movie_axes1);
set(im, 'ButtonDownFcn', {@markEvents, handles});
handles.Play_control.UserData.curIdx = curIdx;
set(handles.Frame, 'String', num2str(curIdx));


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in FastBackward.
function FastBackward_Callback(hObject, eventdata, handles)
% hObject    handle to FastBackward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curMovie = handles.output.UserData.curMovie;
curIdx = handles.Play_control.UserData.curIdx;

if (curIdx - 10) < 1
    curIdx = 1;
else
    curIdx = curIdx - 10; %Fast backward 10 frames
end
handles.Play_control.UserData.curIdx = curIdx;
set(handles.slider1, 'Value', curIdx);
set(handles.Frame, 'String', num2str(curIdx));
im = imshow(mat2gray(curMovie(:,:,curIdx)), 'Parent', handles.Movie_axes1); %Display current frame
set(im, 'ButtonDownFcn', {@markEvents, handles});


% --- Executes on button press in FastForward.
function FastForward_Callback(hObject, eventdata, handles)
% hObject    handle to FastForward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

duration = handles.output.UserData.duration;
curMovie = handles.output.UserData.curMovie;
curIdx = handles.Play_control.UserData.curIdx;

if (curIdx + 10) > duration
    curIdx = duration;
else
    curIdx = curIdx + 10;
end
handles.Play_control.UserData.curIdx = curIdx;
set(handles.slider1, 'Value', curIdx);
set(handles.Frame, 'String', num2str(curIdx));
im = imshow(mat2gray(curMovie(:,:,curIdx)), 'Parent', handles.Movie_axes1); %Display current frame
set(im, 'ButtonDownFcn', {@markEvents, handles});


% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    %whether a new movie has been loaded
    if isempty(hObject.UserData)
        curFlag = 0; 
        hObject.UserData.IsFirstCall = 1; %First time call the callback
    else
        curFlag = ~hObject.UserData.curFlag; %Renew current flag
    end
    
    hObject.UserData.curFlag = curFlag; %Update/store the renewed flag 
    curIdx = handles.Play_control.UserData.curIdx; %Get current index
    curObj = handles.output.UserData; 
    curMovie = curObj.curMovie; %Get current movie
    duration = handles.output.UserData.duration;%Get movie duration

    if ~curFlag
        hObject.String = 'Pause';
    elseif curFlag 
        hObject.String = 'Play';
    end

    while ~curFlag %If current action was acting on 'Play'        
        if hObject.UserData.curFlag && ~hObject.UserData.IsFirstCall
            %When callback if the previous action was 'Pause' and if it is
            %not the first time the callback function being called
            handles.Play_control.UserData.curIdx = curIdx; %Update/store current frame index
            break
        end        
        
        if curIdx > duration
            hObject.String = 'Play';
            curFlag = 1;
            hObject.UserData.curFlag = curFlag; %Update/store the renewed flag 
            break;
        end
        
        set(handles.Frame, 'String', num2str(curIdx));
        set(handles.slider1, 'Value', curIdx);
        handles.Play_control.UserData.curIdx = curIdx; %Update/store current frame index
        imshow(mat2gray(curMovie(:,:,curIdx)), 'Parent', handles.Movie_axes1);
        curIdx = curIdx + 1; %Movie to the next frame
        pause(0.1);
        
    end
    
    %[x, y] = getpts(handles.Movie_axes1);
    %plot(handles.Movie_axes1, x, y, 'ro')
    %roi = drawpoint(handles.Movie_axes1);
    im = imshow(mat2gray(curMovie(:,:,curIdx)), 'Parent', handles.Movie_axes1); %Display current frame
    set(im, 'ButtonDownFcn', {@markEvents, handles});
    hObject.UserData.IsFirstCall = 0; %Now it's not the first time the callback being called
    
catch
    
    if isempty(handles.output.UserData)
        error('Please load a movie first!')
    end
end


function markEvents(h,~,handles)
%This function will allow user to mark a new event as well as store
%information of the defined roi (including the postition, the frame indices
%when the roi/event was created/initiated and deleted/ended)
%h        handle of the current image
%handles  handles of the GUI
      
    roi = drawpoint(h.Parent, 'Color', 'g'); %Drawing a new roi
    incorporateCurrentRoi(handles,roi); %Incorporate the new roi to related data structure

function incorporateCurrentRoi(handles,roi)
% This function will incorporate current roi information to existed list
% and update related data structure
% handles    handles of current GUI
% roi        current roi object
  
    allROI = handles.listbox.UserData.allROI;%Get all ROIs
    allROI_info = handles.listbox.UserData.allROI_info; %Get all ROIs' inforamtion
    curList = handles.listbox.String; %Get display string from listbox
    curIdx = handles.Play_control.UserData.curIdx; %Get current frame index

    curPos = round(roi.Position);  %Current xy coordinates
    curStr = [num2str(curIdx) ' ' num2str(curPos(1)) ' ' num2str(curPos(2))]; %New string to be listed in listbox
    curList{end+1} = curStr; %Add new string to string cell array
    set(handles.listbox,'Value',1);
    handles.listbox.String = curList; %Renew listbox (display new string)
    roi.UserData.Str = curStr; %Attach string information to the new roi
    roi.UserData.Idx = curIdx; %Attach index information to the new roi

    roiInfo = [curPos, curIdx, curIdx]; %New roi's info
    if isempty(allROI_info)
        allROI_info = roiInfo;
    else
        allROI_info(end+1,:) = roiInfo; %Add new roi's info to current info list
    end
    allROI{end+1} = roi; %Add new roi obj to current roi array
    handles.listbox.UserData.allROI_info = allROI_info; %Store renewed info list
    handles.listbox.UserData.allROI = allROI; %Store renewed roi array

    %Listening to the deleting events
    addlistener(roi, 'DeletingROI', @(src,evt)deleteCallback(src,evt,handles));
    %Listening to the moving events
    addlistener(roi, 'ROIMoved', @(src,evt)movedCallback(src,evt,handles));
    %Listening to the clicking events
    addlistener(roi, 'ROIClicked', @(src,evt)clickedCallback(src,evt,handles));
    %Hold the current position
    hold on

    %Update current roi
    handles.Plot_correlation.UserData.curROI = roi;

    
function deleteCallback(roi,~,handles)
%Actions to take when deleting the roi
%roi     the Point obj
%handles     handles of the GUI

%Get the frame index when the delte action is called
%curIdx = handles.Play_control.UserData.curIdx;
%Get the frame index when the roi was created
%iniIdx = roi.UserData.Idx;

    %Get the current string array from the listbox
    curList = handles.listbox.String;
    allROI_info = handles.listbox.UserData.allROI_info; %Get all ROIs' inforamtion
    allROI = handles.listbox.UserData.allROI; %Get all roi objects

    allROI_info(strcmp(curList,roi.UserData.Str),:) = []; %Delete the roi info
    allROI = allROI(~strcmp(curList,roi.UserData.Str)); %Delete the roi obj
    handles.listbox.UserData.allROI_info = allROI_info; %Store renewed info list
    handles.listbox.UserData.allROI = allROI; %Store renewed roi array

    curList = curList(~strcmp(curList,roi.UserData.Str)); %Delete the corresponding string
    handles.listbox.String = curList; %Renew the display


function movedCallback(roi,~,handles)
%Actions to take when moved the roi
%roi     the Point obj
%handles     handles of the GUI

    curPos = round(roi.Position);  %Current xy coordinates

    %Get the current string array from the listbox
    curList = handles.listbox.String;
    allROI_info = handles.listbox.UserData.allROI_info; %Get all ROIs' inforamtion
    allROI = handles.listbox.UserData.allROI; %Get all roi objects
    allROI_info(strcmp(curList,roi.UserData.Str),1:2) = curPos; %Renew the xy coordinates
    allROI(strcmp(curList,roi.UserData.Str)) = {roi}; %Renew the roi
    handles.listbox.UserData.allROI_info = allROI_info; %Store renewed info list
    handles.listbox.UserData.allROI = allROI; %Store renew obj array

    %New string to be listed in listbox
    curStr = [num2str(roi.UserData.Idx) ' ' num2str(curPos(1)) ' ' num2str(curPos(2))];            

    curList(strcmp(curList,roi.UserData.Str)) = {curStr}; %Renew the displayed position
    handles.listbox.String = curList; %Renew the display

    roi.UserData.Str = curStr; %Renew the string info of the roi obj
    %plot(h.Parent, xy(1), xy(2), 'ro')

function clickedCallback(roi,evt,handles)
%Actions to take when clicked the roi
%roi     the Point obj
%evt     current event
%handles     handles of the GUI

    if strcmp(evt.SelectionType,'double')
        %Get the frame index when the delte action is called
        curIdx = handles.Play_control.UserData.curIdx;
        %Get the frame index when the roi was created
        %iniIdx = roi.UserData.Idx;

        %Get the current string array from the listbox
        curList = handles.listbox.String;
        allROI_info = handles.listbox.UserData.allROI_info; %Get all ROIs' inforamtion

        %Store the current frame index (end of an event) to the roi
        allROI_info(strcmp(curList,roi.UserData.Str),4) = curIdx;
        handles.listbox.UserData.allROI_info = allROI_info; %Store the renewed info list

        %Make the current roi invisible
        roi.Visible = 'off';

    elseif strcmp(evt.SelectionType,'left')
        if roi.Color(2) == 1
            roi.Color = 'r';
        else
            roi.Color = 'g';
        end
    end



% --- Executes on button press in Stop.
function Stop_Callback(hObject, ~, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curIdx = 1; %Reset to the first frame
curMovie = handles.output.UserData.curMovie;
handles.Play_control.UserData.curIdx = curIdx;
set(handles.slider1, 'Value', curIdx);
set(handles.Frame, 'String', num2str(curIdx));
im = imshow(mat2gray(curMovie(:,:,curIdx)), 'Parent', handles.Movie_axes1); %Display current frame
set(im, 'ButtonDownFcn', {@markEvents, handles});


function Text_load_Callback(hObject, eventdata, handles)
% hObject    handle to Text_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Text_load as text
%        str2double(get(hObject,'String')) returns contents of Text_load as a double


% --- Executes during object creation, after setting all properties.
function Text_load_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Text_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function play_CreateFcn(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Play_control_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Play_control (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
hObject.UserData.curIdx = 1;



function Frame_Callback(hObject, eventdata, handles)
% hObject    handle to Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Frame as text
%        str2double(get(hObject,'String')) returns contents of Frame as a double

try
    curIdx = str2double(get(hObject, 'String'));
    handles.Play_control.UserData.curIdx = curIdx;
    curMovie = handles.output.UserData.curMovie;
    im = imshow(mat2gray(curMovie(:,:,curIdx)), 'Parent', handles.Movie_axes1);
    set(im, 'ButtonDownFcn', {@markEvents, handles});
    set(handles.slider1, 'Value', curIdx);
catch
    error('Exceed movie range!')
end


% --- Executes during object creation, after setting all properties.
function Frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over listbox.
function listbox_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on listbox and none of its controls.
function listbox_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Load_data.
function Load_data_Callback(hObject, eventdata, handles)
% hObject    handle to Load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    Load_movie_Callback(hObject, eventdata, handles)
catch
    warning('Can not load the movie!')
end

try
    %Choose the folder where _allROI.mat files are saved
    selpath = uigetdir('Please choose the folder where the ROI files are!');
    cd(selpath);
    fileList = dir('*allROI*');
    combineROI = {};
    combineROI_info = [];
    for i = 1:size(fileList,1)
        load(fileList(i).name);
        combineROI = [combineROI allROI];
        combineROI_info = [combineROI_info; allROI_info];
    end

    %Save combined data
    allROI = combineROI;
    allROI_info = combineROI_info;
    %Get the first and last frames.
    start_frame = min(allROI_info(:,3));
    end_frame = max(allROI_info(:,4));
    filename = fileList(1).name;
    filename = [filename(1: strfind(filename,'filter')-1)...
        num2str(start_frame) '_' num2str(end_frame) '_combined.mat'];

    %Calculate median duration
    all_durations = allROI_info(:,4) - allROI_info(:,3);
    all_durations = all_durations(all_durations > 1);
    mean_duration = mean(all_durations);
    median_duration = median(all_durations);

    %Calculate # of bands per minutes
    bands_per_minute = ...
        length(allROI)/(max(allROI_info(:,4)) - min(allROI_info(:,3)))*600;

    save(filename, 'allROI', 'allROI_info', 'median_duration', 'bands_per_minute', 'mean_duration')

    sz = handles.output.UserData.sz;

    if sz(3) >= max(combineROI_info(:,4))
        disp('Sanity check passed...Maximum frame of ROIs does not exceed maximum movie frame.')
    else
        msgbox('Detect mismatch between the movie and the ROI file!','Error');
    end

    %Update UserData
    handles.listbox.UserData.allROI_info = allROI_info;
    handles.listbox.UserData.allROI = allROI;

    importedList = {};
    for i = 1:size(allROI,2)
        rounded_str = num2str(round(str2num(allROI{i}.UserData.Str)));
        allROI{i}.UserData.Str = rounded_str;
        importedList{i,1} = rounded_str;
    end

    handles.listbox.String = importedList;
    
catch
    msgbox('Can not load data!','Error');
end

disp('')



function Text_playing_Callback(hObject, eventdata, handles)
% hObject    handle to Text_playing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Text_playing as text
%        str2double(get(hObject,'String')) returns contents of Text_playing as a double


% --- Executes during object creation, after setting all properties.
function Text_playing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Text_playing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in Replay.
function Replay_Callback(hObject, eventdata, handles)
% hObject    handle to Replay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curMovie = handles.output.UserData.curMovie;%Get current movie
curVal = handles.listbox.Value; %Get current value
allROI_info = handles.listbox.UserData.allROI_info; %Get all ROIs' inforamtion
allROI = handles.listbox.UserData.allROI; %Get all ROI objects
roi_info = allROI_info(curVal,:); %Get corresponding roi info

%Play the current event
ini_idx = roi_info(3); 
end_idx = roi_info(4);
%Show event progress
set(handles.Text_playing, 'Visible', 'On')
set(handles.Text_playing, 'String', 'Replaying...')
hObject.Enable = 'off';
for i = ini_idx:end_idx
    imshow(mat2gray(curMovie(:,:,i)), 'Parent', handles.Movie_axes1);
    pause(0.05)
end
set(handles.Text_playing, 'String', 'Last frame')
pause(1)
hObject.Enable = 'on';

%Jump to the frame where the current roi was created
im = imshow(mat2gray(curMovie(:,:,ini_idx)), 'Parent', handles.Movie_axes1);
set(im, 'ButtonDownFcn', {@markEvents, handles});
%Set current index to the initial index of the selected event
handles.Play_control.UserData.curIdx = ini_idx; 
%Reset slider value
handles.slider1.Value = ini_idx;
%Reset Frame editbox string
handles.Frame.String = num2str(ini_idx);

set(handles.Text_playing, 'String', 'First frame')




% --- Executes on button press in Hide_pts.
function Hide_pts_Callback(hObject, eventdata, handles)
% hObject    handle to Hide_pts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allROI = handles.listbox.UserData.allROI; %Get all ROI objects
%Turn off all ROIs' visibility
for i = 1:length(allROI)
    curPt = allROI{i};
    curPt.Visible = 'off';
end


% --- Executes on button press in Label_movie.
function Label_movie_Callback(hObject, eventdata, handles)
% hObject    handle to Label_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Text_playing, 'Visible', 'On')
set(handles.Text_playing, 'String', 'Labeling...')
disp('Running label movie function...')

%Try to load the movie and ROI info
try
    curMovie = handles.output.UserData.curMovie; %Get current movie
    allROI_info = handles.listbox.UserData.allROI_info; %Get all ROI info
catch
    msgbox('Please load a movie and its ROIs first!','Error');
    return
end

%Label all centers and save the image
median_frame = nanmedian(curMovie,3);
fh = figure('visible','on');
fh.WindowState = 'maximized';
imshow(mat2gray(median_frame))
hold on
plot(allROI_info(:,1),allROI_info(:,2),'r*')
hold off
saveas(fh,'Labeled_centers.png')

%Get the first and last frames.
start_frame = min(allROI_info(:,3));
end_frame = max(allROI_info(:,4));

try

    %Construct each frame
    parfor i = start_frame:end_frame
        %Get the list of ROIs appear on the current frame
        showList = (allROI_info(:,3) <= i).*(allROI_info(:,4) >= i);
        currCentroids = allROI_info(showList>0, 1:2);       
        h = figure('visible','off');
        imshow(mat2gray(curMovie(:,:,i)));
        hold on
        plot(currCentroids(:,1),currCentroids(:,2),'ro','MarkerSize',5,'LineWidth',2)
        hold off
        F(i) = getframe(h);
        close(h)   
        if mod(i,100) == 0
            disp(num2str(i));
        end
    end
    
    F = F(start_frame:end_frame);
    
    %Create output labeled movie name
    OutputName = ['Labeled_movie_' num2str(start_frame) '_' num2str(end_frame) '.avi'];

    % create the video writer with 25 fps
    writerObj = VideoWriter(OutputName);
    writerObj.FrameRate = 25;
    % set the seconds per image
    % open the video writer
    open(writerObj);
    % write the frames to the video
    for i=1:length(F)
        % convert the image to a frame
        frame = F(i);    
        writeVideo(writerObj, frame);
    end
    % close the writer object
    close(writerObj);
    
catch
    warning('Error happened! Probably the movie mismatches the ROIs!')
end

set(handles.Text_playing, 'Visible', 'Off')


% --- Executes on button press in Plot_correlation.
function Plot_correlation_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_correlation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.Plot_correlation.UserData)
    %Show progress
    handles.Text_playing.Visible = 'On';
    handles.Text_playing.String = 'Calculating correlation!';
    
    %Construct plotCorrObj to transfer data to PlotCorrMap GUI
    curRoi = handles.Plot_correlation.UserData.curROI;
    plotCorrObj.curPos = round(curRoi.Position);
    plotCorrObj.curMovie = handles.output.UserData.curMovie;
    plotCorrObj.reg_flag = handles.Regress_flag.Value;
    plotCorrObj.filename = handles.Load_movie.UserData.filename;
    handles.Plot_correlation.UserData.plotCorrObj = plotCorrObj;
    
    %Execute PlotCorrMap GUI
    disp('Generating the correlation map...')
    PickSeedMap('hObject');
else
    msgbox('Can not detect current roi object!', 'Error')
end



% --- Executes on button press in Regress_flag.
function Regress_flag_Callback(hObject, eventdata, handles)
% hObject    handle to Regress_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Regress_flag


% --- Executes on button press in Next_movie.
function Next_movie_Callback(hObject, ~, handles)
% hObject    handle to Next_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    %Get current movie index
    curMovIdx = hObject.UserData.curMovIdx;
    %Get file list
    fileList= handles.Load_movie.UserData.fileList;
    %Load the next movie
    Next_idx = curMovIdx + 1;
    filename = fileList(Next_idx).name;
    path = fileList(Next_idx).folder;
    LoadNewMovie(path, filename, handles);
catch
    msgbox('Unable to load the next movie!', 'Error!')
end


% --- Executes on button press in Previous_movie.
function Previous_movie_Callback(~, ~, handles)
% hObject    handle to Previous_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    %Get current movie index
    curMovIdx = handles.Next_movie.UserData.curMovIdx;
    %Get file list
    fileList= handles.Load_movie.UserData.fileList;
    %Load the next movie
    pre_idx = curMovIdx - 1;
    filename = fileList(pre_idx).name;
    path = fileList(pre_idx).folder;
    LoadNewMovie(path, filename, handles);
catch
    msgbox('Unable to load the previous movie!', 'Error!')
end


% --- Executes on button press in Renew.
function Renew_Callback(~, eventdata, handles)
% hObject    handle to Renew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clean previous data if existed
handles.listbox.String = {};
handles.listbox.UserData.allROI = {};
handles.listbox.UserData.allROI_info = [];
handles.listbox.Value = 1;

%Clean index information from the previous movie
handles.play.UserData = [];
handles.Play_control.UserData.curIdx = 1;
handles.Frame.String = '1';


% --- Executes on button press in Find_max.
function Find_max_Callback(hObject, eventdata, handles)
% hObject    handle to Find_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curMovie = handles.output.UserData.curMovie;%Get current movie
Mean_response = nanmean(curMovie(:,:,11:15),3);
[y2 ,x2] = findReccomandMax(Mean_response);

%Create a new roi object 
set(handles.Manuvent_threshold,'CurrentAxes',handles.Movie_axes1)
hold on;
roi = drawpoint(handles.Movie_axes1,'Position',[x2 y2]);
%Incorporate the new roi to related data structure
incorporateCurrentRoi(handles,roi); 

%Show the trace at this pixel
curTrace = curMovie(y2,x2,:);
curTrace = curTrace(:);
plot(handles.Regional_trace, curTrace, 'LineWidth', 2);

%Save the position and current trace;
handles.Regional_stat.UserData.regional_stat.curPos = [x2, y2];
handles.Regional_stat.UserData.regional_stat.curTrace = curTrace;



function [y2 ,x2] = findReccomandMax(corrM)
%Find the point that shows maximum correlation other than the seed given
%certain conditions

%Filter to mask out boundary artifact (due to rigid registration)
filter = ones(5);
corrM_conv = conv2(corrM,filter,'same');

%Find the maximum point
max_point = max(corrM_conv(:));
[y2 ,x2] = find(corrM_conv == max_point);
%fill([x2-2,x2-2,x2+2,x2+2],[y2-2,y2+2,y2+2,y2-2], 'm')



% --- Executes on button press in Free_crop.
function Free_crop_Callback(hObject, eventdata, handles)
% hObject    handle to Free_crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
crop_movie(1, handles);


function crop_movie(m, handles)
%Crop the current movie using roipoly or drawrectangle (m == 1 or 2)
    
    if nargin == 1
        m = 1; %Free crop
    end  
    
    %Get current movie
    curMovie = handles.output.UserData.curMovie;
    curMovie(isnan(curMovie)) = 0;
    sz = size(curMovie);
    
    %Define roi
    handles.Text_load.String = 'Drawing';
    set(handles.Manuvent_threshold,'CurrentAxes',handles.Movie_axes1);
    
    %Different ways to define rois
    switch m
        case 1 %Free crop
            BW = roipoly;
        case 2 %Rectangular crop
            h_rec = drawrectangle('Rotatable', true);
            BW = poly2mask(h_rec.Vertices(:,1),...
                h_rec.Vertices(:,2), sz(1), sz(2)); 
            %Add ROIMoved listerner to monitor movement
            addlistener(h_rec,'ROIMoved',@(src,evt)UpdateRecPos(src,evt,handles));
            %Save the current rectangular roi 
            handles.Save_cropped.UserData.h_rec = h_rec;
        case 3 %Free crop for background noise
            handles.Text_load.String = 'Define roi for extracting background noise';
            BW = roipoly;
    end
    
    %Show progress
    handles.Text_load.String = 'Defined';

    %Apply roi mask  
    BW_3D = repmat(BW, [1,1,sz(3)]);
    A_dFoF_cropped = curMovie.*BW_3D;

    %Crop nan and 0 elements
    [dim1_lower,dim1_upper,dim2_lower,dim2_upper] = ...
        getROIBoundsFromImage(A_dFoF_cropped(:,:,1)); 
    A_dFoF_cropped = ...
        A_dFoF_cropped(dim1_lower:dim1_upper,dim2_lower:dim2_upper,:); 
    A_dFoF_cropped(A_dFoF_cropped == 0) = nan;

    %Save variables
    if m < 3
        handles.Save_cropped.UserData.mask = BW;
        handles.Save_cropped.UserData.A_dFoF_cropped = A_dFoF_cropped;
    elseif m == 3
        Avg_noise = nanmean(A_dFoF_cropped,1);
        Avg_noise = nanmean(Avg_noise,2);
        Avg_noise = Avg_noise(:);
        %Save useful information
        handles.Background_noise.UserData.Avg_noise = Avg_noise;
        handles.Background_noise.UserData.BW = BW;
        handles.Save_cropped.UserData.Avg_noise = Avg_noise;
    end
    

function UpdateRecPos(h_rec,~,handles)
%Callback function to update rectangular roi after interactive adjustment
    
    %Show status
    handles.Text_playing.Visible = 'On';
    handles.Text_playing.String = [num2str(h_rec.Vertices(1)) ' ' ...
        num2str(h_rec.Vertices(3))];
    
    %Get current movie
    curMovie = handles.output.UserData.curMovie;
    curMovie(isnan(curMovie)) = 0;
    sz = size(curMovie);
    BW = poly2mask(h_rec.Vertices(:,1),...
                h_rec.Vertices(:,2), sz(1), sz(2)); 
            
    %Apply roi mask  
    BW_3D = repmat(BW, [1,1,sz(3)]);
    A_dFoF_cropped = curMovie.*BW_3D;

    %Crop nan and 0 elements
    [dim1_lower,dim1_upper,dim2_lower,dim2_upper] = ...
        getROIBoundsFromImage(A_dFoF_cropped(:,:,1)); 
    A_dFoF_cropped = ...
        A_dFoF_cropped(dim1_lower:dim1_upper,dim2_lower:dim2_upper,:); 
    A_dFoF_cropped(A_dFoF_cropped == 0) = nan;

    %Save cropped matrix/ mask/ rectangular roi object
    handles.Save_cropped.UserData.mask = BW;
    handles.Save_cropped.UserData.A_dFoF_cropped = A_dFoF_cropped;
    handles.Save_cropped.UserData.h_rec = h_rec;
    
    
   
% --- Executes on button press in Rotate_rectangle.
function Rotate_rectangle_Callback(hObject, eventdata, handles)
% hObject    handle to Rotate_rectangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    %Show progress
    handles.Text_playing.Visible = 'On';
    handles.Text_playing.String = 'Rotating rectangular roi!';
    
    %Get the current rectangular roi and cropped movie
    h_rec = handles.Save_cropped.UserData.h_rec;
    A_dFoF_cropped = handles.Save_cropped.UserData.A_dFoF_cropped;
    
    %Rotate the image volume around the z axis
    A_dFoF_cropped(isnan(A_dFoF_cropped)) = 0;%Change or NaN to 0 for rotation
    Rec_rotated = imrotate3(A_dFoF_cropped, -h_rec.RotationAngle, [0,0,1]);
    Rec_rotated(Rec_rotated == 0) = nan;
    Rec_rotated = focusOnroi(Rec_rotated);
    
    %Store the rotated rectangular movie
    hObject.UserData.Rec_rotated = Rec_rotated;
    
    %Preserve columns with >50% none-nan pixels
    R1 = sum(~isnan(Rec_rotated(:,:,1)),1);
    Preserved_idx = R1 > round(size(Rec_rotated,1)/2);
    
    %Average the rotated rectangular movie for line scanning
    Avg_line = nanmean(Rec_rotated,1);
    Avg_line = reshape(Avg_line, [size(Avg_line,2),size(Avg_line,3)]);
    Avg_line = Avg_line(Preserved_idx',:);
    Avg_line = Avg_line';
    
    %Store the averaged line movie
    hObject.UserData.Avg_line = Avg_line;
    
    %Save the rotated matrix and averaged line movie
    filename = handles.Load_movie.UserData.filename;
    try
        Avg_noise = handles.Background_noise.UserData.Avg_noise;
        uisave({'Rec_rotated', 'Avg_line', 'h_rec', 'filename', 'Avg_noise'},...
            [filename(1:end-4) '_Rotated_rec.mat']);
    catch
         msgbox('Recommend to specify noise region first!', 'Warning!')
         uisave({'Rec_rotated', 'Avg_line', 'h_rec', 'filename'}, [filename(1:end-4) '_Rotated_rec.mat']);
    end
   
    handles.Text_playing.Visible = 'Off';
    
catch
    msgbox('Please define a rectangular roi first!', 'Error!')
end
    

function A = focusOnroi(A)
%Chop the matirx to the roi part
%Inputs/Outputs:
%A     3D Matrix

    [dim1_lower,dim1_upper,dim2_lower,dim2_upper] = getROIBoundsFromImage(A(:,:,1)); 
    A = A(dim1_lower:dim1_upper,dim2_lower:dim2_upper,:); %ppA: pre-processed 
    
    

function [nZ_1_lower,nZ_1_upper,nZ_2_lower,nZ_2_upper] = getROIBoundsFromImage(cur_img)
%    This function identify the coordinates of vertex of the minimum
%    rectangle containing the roi
%
%    Inputs:
%        cur_img          A 2D image containg roi
%
%    Outputs:
%        nZ_1_lower      lower left vertex of the minimum rectangle
%        nZ_1_upper      upper left vertex of the minimum rectangle
%        nZ_2_lower      lower right vertex of the minimum rectangle
%        nZ_2_upper      upper right vertex of the minimum rectangle

    if (~any(isnan(cur_img(:)))) && (cur_img(1) == 0) && (cur_img(end) == 0)
        cur_img = ~(cur_img == 0);
    else
        cur_img = ~isnan(cur_img);
    end

    nZ_2 = find(mean(cur_img,1));
    nZ_2_upper = max(nZ_2);
    nZ_2_lower = min(nZ_2);
    nZ_1 = find(mean(cur_img,2));
    nZ_1_upper = max(nZ_1);
    nZ_1_lower = min(nZ_1);
        


% --- Executes on button press in Save_cropped.
function Save_cropped_Callback(hObject, eventdata, handles)
% hObject    handle to Save_cropped (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get cropped matrix
Cropped_strct = handles.Save_cropped.UserData;

%Save cropped matrix
filename = handles.Load_movie.UserData.filename;
uisave({'Cropped_strct'}, [filename(1:end-4) '_cropped.mat']);

%Show progress
set(handles.Text_load, 'String', 'Saved!')


% --- Executes on button press in Probe_one.
function Probe_one_Callback(hObject, eventdata, handles)
% hObject    handle to Probe_one (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Text_playing.Visible = 'On';
handles.Text_playing.String = 'Select a pixel!';

%Define roi
set(handles.Manuvent_threshold,'CurrentAxes',handles.Movie_axes1)
roi = drawpoint('Color', 'm');
incorporateCurrentRoi(handles,roi);
%Listening to the moving events
addlistener(roi, 'ROIMoved', @(src,evt)updatePlotting(src,evt,handles));
handles.Text_playing.String = 'Pixel selected!';

%Get roi position
curPos = round(roi.Position); 

%Show current trace
showTrace(curPos,handles)


    
% --- Executes on button press in Probe_region.
function Probe_region_Callback(hObject, eventdata, handles)
% hObject    handle to Probe_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Define roi
handles.Text_playing.Visible = 'On';
handles.Text_playing.String = 'Define a region!';
set(handles.Manuvent_threshold,'CurrentAxes',handles.Movie_axes1)
BW = roipoly;
handles.Text_playing.Visible = 'Off';

%Show current trace
showTrace(BW,handles)


% --- Executes on button press in Save_region.
function Save_region_Callback(hObject, eventdata, handles)
% hObject    handle to Save_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
regional_stat = handles.Regional_stat.UserData.regional_stat;
filename = handles.Load_movie.UserData.filename;
uisave({'regional_stat'}, [filename(1:end-4) '_regional_stat.mat']);
saveas(handles.Regional_trace,[filename(1:end-4) '_regional_trace.png'])





function showTrace(curRegion,handles)
%Show the fluorescent trace of a give region
%curRegion     either a single pixel or a black-n-white roi region
%handles       handles of the current GUI
    
    %Get current movie
    curMovie = handles.output.UserData.curMovie;
    
    if length(curRegion) == 2
        %Get the trace at this pixel
        curTrace = curMovie(curRegion(2),curRegion(1),:);
        curTrace = curTrace(:);
        %Show current position
        handles.Text_playing.String = [num2str(curRegion(1)) ' ' num2str(curRegion(2))];
        %Save current Position
        handles.Regional_stat.UserData.regional_stat.curPos = curRegion;
    else
        %Define curTrace as the mean trace of the defined region
        masked_movie = curMovie.*curRegion;
        masked_movie(masked_movie == 0) = nan;
        curTrace = nanmean(masked_movie,1);
        curTrace = nanmean(curTrace,2);
        curTrace = curTrace(:);
        %Save current Position
        handles.Regional_stat.UserData.regional_stat.BW = curRegion;
    end
    
    %Show the current Trace
    %hold(handles.Regional_trace, 'on')
    plot(handles.Regional_trace, curTrace, 'LineWidth', 2);
    handles.Regional_trace.XLim = [1, length(curTrace)];
    %Save the trace
    handles.Regional_stat.UserData.regional_stat.curTrace = curTrace;



function updatePlotting(roi,~,handles)
%Update Plotting based on current position
    curPos = round(roi.Position);  %Update current xy coordinates
    handles.Regional_stat.UserData.regional_stat.curPos = curPos;
    %Show the trace at this pixel
    showTrace(curPos,handles)

    
% --- Executes on button press in Clean_trace.
function Clean_trace_Callback(hObject, eventdata, handles)
% hObject    handle to Clean_trace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %hold(handles.Regional_trace, 'off')
    %If curTrace is not define, clean the axes
    cla(handles.Regional_comparison)
    %Clean the two traces 
    handles.Correlate_two.UserData.trace1 = [];
    handles.Correlate_two.UserData.trace2 = [];
    

% --- Executes on button press in Background_noise.
function Background_noise_Callback(hObject, eventdata, handles)
% hObject    handle to Background_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Text_playing, 'Visible', 'On')
set(handles.Text_playing, 'String', 'Define noise region!')
%Free crop
crop_movie(3, handles)
%Get noise region binary matrix
Noise_region = handles.Background_noise.UserData.BW;
%Show the averaged trace
showTrace(Noise_region, handles);
set(handles.Text_playing, 'Visible', 'Off')

% --- Executes on button press in Deposit_trace.
function Deposit_trace_Callback(hObject, eventdata, handles)
% hObject    handle to Deposit_trace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get the current trace
try
    curTrace = handles.Regional_stat.UserData.regional_stat.curTrace;
    plot(handles.Regional_comparison, curTrace, 'LineWidth', 1);
    handles.Regional_comparison.XLim = [1, length(curTrace)];
    hold(handles.Regional_comparison, 'on')
    
    if isempty(handles.Correlate_two.UserData.trace1)
        handles.Correlate_two.UserData.trace1 = curTrace;
        disp('Trace 1 is defined!')
    else
        handles.Correlate_two.UserData.trace2 = curTrace;
        disp('Trace 2 is defined!')
    end
    
catch
    msgbox('Please define a roi first!','Error!')
end


% --- Executes on button press in Rectangular_crop.
function Rectangular_crop_Callback(hObject, eventdata, handles)
% hObject    handle to Rectangular_crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
crop_movie(2, handles);


    

% --- Executes on button press in Line_scan.
function Line_scan_Callback(hObject, eventdata, handles)
% hObject    handle to Line_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    LineScanObj.Avg_line = handles.Rotate_rectangle.UserData.Avg_line;
    LineScanObj.Rec_rotated = handles.Rotate_rectangle.UserData.Rec_rotated;
    LineScanObj.filename = handles.Load_movie.UserData.filename;
    LineScanObj.h_rec = handles.Save_cropped.UserData.h_rec;
    try %See if background noise has been extracted
        LineScanObj.Avg_noise = handles.Background_noise.UserData.Avg_noise;
    catch
        msgbox('Did not specify background noise!', 'Warning!')
    end
    
    %Start LineMapScan GUI
    hObject.UserData.LineScanObj = LineScanObj;
    LineMapScan('hObject');
catch
    msgbox('Please rotate the rectangular roi first!', 'Error!')
end


% --- Executes on button press in Correlate_two.
function Correlate_two_Callback(hObject, eventdata, handles)
% hObject    handle to Correlate_two (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get two traces
trace1 = hObject.UserData.trace1;
trace2 = hObject.UserData.trace2;

%Determine whether they are empty
if isempty(trace1)||isempty(trace2)
    msgbox('Define two traces with button [Deposit trace].', 'Error')
    return
end

%Regress out background noise if provided
if isfield(handles.Load_noise.UserData, 'Loaded_noise')
        Avg_noise = handles.Load_noise.UserData.Loaded_noise;
        disp('Use loaded noise to compute partial correlation!')
        noise_flag = '1';
        try
            corr_two = partialcorr(trace1,trace2,Avg_noise);
        catch
            warning('Mismatrch between input traces and noise trace!')
            disp('Do not regress out provied noise!')
            corr_two = corr(trace1,trace2);
            noise_flag = '0';
        end
elseif isfield(handles.Background_noise.UserData, 'Avg_noise')
        Avg_noise = handles.Background_noise.UserData.Avg_noise;
        noise_flag = '2';
        corr_two = partialcorr(trace1,trace2,Avg_noise);
else
    corr_two = corr(trace1,trace2);
    noise_flag = '0';
    warning('Background noise is not defined!') 
end

msgbox(['The correlation between current two traces is: ' num2str(corr_two)])
disp(['The correlation between current two traces is: ' num2str(corr_two)])
save(['Correlation_' noise_flag '_2traces.mat'],'corr_two', 'trace1', 'trace2');



% --- Executes during object creation, after setting all properties.
function Correlate_two_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Correlate_two (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%Initialize two traces to be empty
hObject.UserData.trace1 = [];
hObject.UserData.trace2 = [];


% --- Executes on button press in Load_noise.
function Load_noise_Callback(hObject, eventdata, handles)
% hObject    handle to Load_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    uiopen('Please load the noise trace!');
    Loaded_noise = Avg_out_dFoF(:);
    hObject.UserData.Loaded_noise = Loaded_noise;
catch
    msgbox('Can not load noise trace!','Error!')
end
