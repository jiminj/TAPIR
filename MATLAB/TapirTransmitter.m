
function varargout = TapirTransmitter(varargin)
%TAPIRTRANSMITTER M-file for TapirTransmitter.fig
%      TAPIRTRANSMITTER, by itself, creates a new TAPIRTRANSMITTER or raises the existing
%      singleton*.
%
%      H = TAPIRTRANSMITTER returns the handle to a new TAPIRTRANSMITTER or the handle to
%      the existing singleton*.
%
%      TAPIRTRANSMITTER('Property','Value',...) creates a new TAPIRTRANSMITTER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to TapirTransmitter_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      TAPIRTRANSMITTER('CALLBACK') and TAPIRTRANSMITTER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in TAPIRTRANSMITTER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TapirTransmitter

% Last Modified by GUIDE v2.5 24-Aug-2013 17:12:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TapirTransmitter_OpeningFcn, ...
                   'gui_OutputFcn',  @TapirTransmitter_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before TapirTransmitter is made visible.
function TapirTransmitter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for TapirTransmitter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global Fs;
global Fc;

Fs = 44100;
Fc = 20000;

% UIWAIT makes TapirTransmitter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TapirTransmitter_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function tbMsg_Callback(hObject, eventdata, handles)
% hObject    handle to tbMsg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbMsg as text
%        str2double(get(hObject,'String')) returns contents of tbMsg as a double


% --- Executes during object creation, after setting all properties.
function tbMsg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbMsg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnPlay.
function btnPlay_Callback(hObject, eventdata, handles)
    
    
    % hObject    handle to btnPlay (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
	global Fs;
    global Fc;
    global audioData;
    
    saveFlag = get(handles.chkSave, 'Value');
    TapirConf;
    
    switch Fc
        case 18000
            txBpf = txBpf18k;
        case 20000
            txBpf = txBpf20k;
        case 10000
            txBpf = txBpf10k;
    end
    
    txLpf = txrxLpfRC;
    txLpfDelay = txLpf.order / 2;
    
    txBpfDelay = ceil(txBpf.order / 2);
    
    msg = get(handles.tbMsg,'String');
    binData = dec2bin(msg, 8)' - 48;
    genAudioData = generateAudioData(binData);
    extendedAudioData = zeros(size(genAudioData,1) + cPreLength + cPostLength, size(genAudioData,2));
  
    for idx=1:size(extendedAudioData, 2)
        lpfAudioData = [genAudioData(:,idx); zeros(txLpfDelay,1)];
        lpfAudioData = filter(txLpf, lpfAudioData);
        lpfAudioData = lpfAudioData(txLpfDelay+1:end);
        upconvAudioData = freqUpConversion(genAudioData(:,idx), Fc, Fs);    
        % Add Cyclic prefix&postfix
        extendedAudioData(1:length(extendedAudioData),idx) = [upconvAudioData(end - cPreLength + 1 : end); upconvAudioData; upconvAudioData(1:cPostLength)];
    end
    extendedAudioData = [extendedAudioData; zeros(guardInterval, size(extendedAudioData,2))];
    audioData = reshape(extendedAudioData, [], 1);
    %Prepend Preamble
    
    preambleData = generateSinPreamble(preambleBitLength, preambleBandwidth, Fs);
    preambleData = [preambleData; preambleData; zeros(txLpfDelay,1)];
    preambleData = filter(txLpf, preambleData);
    preambleData = preambleData(txLpfDelay+1:end);
    
    upconvPreamble = freqUpConversion(preambleData, Fc, Fs);
    audioData = [upconvPreamble; zeros(preambleInterval,1); audioData];
    audioData = [audioData; zeros(txBpfDelay,1)];
    audioData = filter(txBpf, audioData);  % Filtering
    audioData = [zeros(floor(Fs/5),1);audioData;zeros(floor(Fs/5),1)];

    figure();
    subplot(3,1,1); stem(reshape(binData,[],1));
    subplot(3,1,2); plot(real(audioData));
    subplot(3,1,3); pwelch(audioData, hamming(1024),[],[],Fs,'centered');
    
    if(saveFlag == 1)
        filename = get(handles.tbFilename, 'String');
        if strcmp(filename(end-3:end),'.wav') == 0
            filename = [filename, '.wav'];
        end
        filename = [pwd, '/', filename]
        
        audiowrite(filename, audioData, Fs, 'BitsPerSample', 16)
    end
    sound(audioData, Fs);
    


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function tbFilename_Callback(hObject, eventdata, handles)
% hObject    handle to tbFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbFilename as text
%        str2double(get(hObject,'String')) returns contents of tbFilename as a double


% --- Executes during object creation, after setting all properties.
function tbFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in selCarrierFreq.
function selCarrierFreq_SelectionChangeFcn(hObject, eventdata, handles)

% hObject    handle to the selected object in selCarrierFreq 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
    
    global Fc;
    
    switch hObject
        case handles.radioFc10k
            Fc = 10000;
        case handles.radioFc18k
            Fc = 18000;
        case handles.radioFc20k
            Fc = 20000;
    end
        
    


% --- Executes on button press in chkSave.
function chkSave_Callback(hObject, eventdata, handles)
% hObject    handle to chkSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkSave
