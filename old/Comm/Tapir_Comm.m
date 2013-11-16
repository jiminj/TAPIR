function varargout = Tapir_Comm(varargin)
% TAPIR_COMM M-file for Tapir_Comm.fig
%      TAPIR_COMM, by itself, creates a new TAPIR_COMM or raises the existing
%      singleton*.
%
%      H = TAPIR_COMM returns the handle to a new TAPIR_COMM or the handle to
%      the existing singleton*.
%
%      TAPIR_COMM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TAPIR_COMM.M with the given input arguments.
%
%      TAPIR_COMM('Property','Value',...) creates a new TAPIR_COMM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Tapir_Comm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Tapir_Comm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Tapir_Comm

% Last Modified by GUIDE v2.5 09-Nov-2012 23:53:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Tapir_Comm_OpeningFcn, ...
                   'gui_OutputFcn',  @Tapir_Comm_OutputFcn, ...
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

% --- Executes just before Tapir_Comm is made visible.
function Tapir_Comm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Tapir_Comm (see VARARGIN)
global file_name
global freq
global freqLabel
% Choose default command line output for Tapir_Comm
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Tapir_Comm wait for user response (see UIRESUME)
% uiwait(handles.figure1);

file_name = get(handles.edit1,'String');

freq = 396.9;

% --- Outputs from this function are returned to the command line.
function varargout = Tapir_Comm_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global file_name
global Sound_results
global freq

file_name = get(handles.edit1,'String');
tmp = get(handles.checkbox1,'Value');
if(tmp == 1)
    x = wavread(file_name);
else
    x = zeros(2000000,1);
end
freq
tmp3 = get(handles.edit3,'string');
tmp3 = tmp3 - 'a' + 1;

Sound_results = SoundGenerate(x,freq,tmp3);


sound(Sound_results,44100);

end_msg = 'END';
end_msg

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hRadio1.
function hRadio1_Callback(hObject, eventdata, handles)
% hObject    handle to hRadio1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hRadio1


% --- Executes on button press in hRadio2.
function hRadio2_Callback(hObject, eventdata, handles)
% hObject    handle to hRadio2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hRadio2


% --- Executes on button press in hRadio3.
function hRadio3_Callback(hObject, eventdata, handles)
% hObject    handle to hRadio3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hRadio3


% --- Executes on button press in hRadio4.
function hRadio4_Callback(hObject, eventdata, handles)
% hObject    handle to hRadio4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hRadio4

% --- Executes on button press in hRadio9.
function hRadio9_Callback(hObject, eventdata, handles)
% hObject    handle to hRadio9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global freq
global freqLabel
switch hObject

    case handles.hRadio2
        freq = 793.8;
        freqLabel = '800';
    case handles.hRadio3
        freq = 1984.5;
        freqLabel = '2k';
    case handles.hRadio4
        freq = 4983.3;
        freqLabel = '5k';
    case handles.hRadio5
        freq = 9922.5;
        freqLabel = '10k';
    case handles.hRadio6
        freq = 11907;
        freqLabel = '12k';
    case handles.hRadio7
        freq = 14001.75;
        freqLabel = '14k';
    case handles.hRadio8
        freq = 15016.05;
        freqLabel = '15k';
    case handles.hRadio9
        freq = 16008.3;
        freqLabel = '16k';
    case handles.hRadio10
        freq = 17000.55;
        freqLabel = '17k';
    case handles.hRadio11
        freq = 17640;
        freqLabel = '18k';
    case handles.hRadio12
        freq = 19999.35;
        freqLabel = '20k';
end
             


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global file_name
global Sound_results
global freq
global freqLabel

file_name = get(handles.edit1,'String');
tmp = get(handles.checkbox1,'Value');
if(tmp == 1)
    x = wavread(file_name);
else
    x = zeros(2000000,1);
end
freq
tmp3 = get(handles.edit3,'string');
tmp3 = tmp3 - 'a' + 1;

Sound_results = SoundGenerate(x,freq,tmp3);

freqLabel
file_string = strcat('Tapir_Comm (',freqLabel,'Hz)','.wav');
file_string
%wavwrite(Sound_results,44100,);
wavwrite(Sound_results,44100,file_string);
end_msg = 'END';
end_msg

