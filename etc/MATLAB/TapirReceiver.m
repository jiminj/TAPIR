function varargout = TapirReceiver(varargin)
% TAPIRRECEIVER MATLAB code for TapirReceiver.fig
%      TAPIRRECEIVER, by itself, creates a new TAPIRRECEIVER or raises the existing
%      singleton*.
%
%      H = TAPIRRECEIVER returns the handle to a new TAPIRRECEIVER or the handle to
%      the existing singleton*.
%
%      TAPIRRECEIVER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TAPIRRECEIVER.M with the given input arguments.
%
%      TAPIRRECEIVER('Property','Value',...) creates a new TAPIRRECEIVER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TapirReceiver_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TapirReceiver_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TapirReceiver

% Last Modified by GUIDE v2.5 27-Aug-2013 01:31:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TapirReceiver_OpeningFcn, ...
                   'gui_OutputFcn',  @TapirReceiver_OutputFcn, ...
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


% --- Executes just before TapirReceiver is made visible.
function TapirReceiver_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TapirReceiver (see VARARGIN)

% Choose default command line output for TapirReceiver
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global Fs;
global Fc;

Fs = 44100;

%init Value
Fc = 19000;



% UIWAIT makes TapirReceiver wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TapirReceiver_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnReceive.
function btnReceive_Callback(hObject, eventdata, handles)
% hObject    handle to btnReceive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnReceive


%     set(handles.btnReceive,'Enable','off');
%     set(handles.btnStop,'Enable','on');
    set(handles.btnLoad,'Enable','off');
%     set(handles.tbFilename, 'Enable', 'off');
    
    global Fs;
    global Fc;

    pageSize = 2048;
    pageBufCnt = 5;
    minRecogLength = 1000;
    
    textResetCnt = 5;
    dataBlk = [];
    remainedBlk = [];
    noDataCnt = 0;
    resultString = [];

    
    recFlag = 0;
    recorder = dsp.AudioRecorder(44100,4096);
    Speaker = dsp.AudioPlayer;
    SpecAnalyzer = dsp.SpectrumAnalyzer;
        
        
    if( get(hObject, 'Value') )
        disp('Start Recording');
        if(playrec('isInitialised'))
            playrec('reset');
        end
        
        pageNumList = repmat(-1, [1, pageBufCnt]);
        isFirstPage = 1;
        
%         timeFigure = figure;
%         timeAxes = axes('parent', timeFigure, 'xlimmode', 'manual', 'ylimmode', 'manual', 'xscale', 'linear', 'yscale', 'linear', 'xlim', [1 pageSize], 'ylim', [-1, 1]);
%         timeLine = line('XData', 1:pageSize,'YData', ones(1, pageSize));

        playrec('init', Fs, -1, 0, -1, 1);
 
        while( get(hObject, 'Value') )
            newPage = playrec('rec', pageSize, 1);
            if(isFirstPage)
                playrec('resetSkippedSampleCount');
                isFirstPage = 0;
            end
            playrec('block', pageNumList(1));
            
            lastRecording = playrec('getRec', pageNumList(1));
            

            
            if(pageNumList(1) ~= -1)
                [rcvDataBlk, remainedBlk] = detectDataRegion([remainedBlk; lastRecording], Fc);

                if( ~isempty(rcvDataBlk)) % Found
                    if( isempty(remainedBlk)) %continue
                        dataBlk = [dataBlk; rcvDataBlk];  
                    else %not Continue
                        dataBlk = [dataBlk; rcvDataBlk];

                        % No consideration for the case of the data block ends
                        % exactly the buffer page

                        if(length(dataBlk) > minRecogLength)
                            length(dataBlk)
                            roiData = freqDownConversion(dataBlk, Fc, Fs);
                            
                            %%%%% LPF %%%%%%%
                            lpf = txrxLpf;
                            lpfDelay = ceil(lpf.order / 2);
                            extRoiData = [roiData; zeros(lpfDelay,1)];
                            filtRoiData = filter(lpf, extRoiData);
                            filtRoiData = filtRoiData(lpfDelay+1 :end);
                            
                            analyzedData = analyzeAudioData(filtRoiData);
                            resultChar = encodeChar(analyzedData)
                            resultString = [resultString, resultChar];
                            set(handles.tbResult, 'String', resultString);
            %                 skipped = playrec('getSkippedSampleCount')

                %                         figure(2);
                %                         plot(dataBlk);
                        end
                        dataBlk = [];
                    end
                elseif( ~isempty(resultString) )
                    noDataCnt = noDataCnt+1;
                    if(noDataCnt > textResetCnt)
                        resultString = [];
                        noDataCnt = 0;
                    end
                end
            end

            
            playrec('delPage', pageNumList(1));
            pageNumList = [pageNumList(2:end), newPage];
            
            pause(0.000000001);
            
        end            
    else
        disp('Stop Recording');
        if(playrec('isInitialised'))
            playrec('delPage');
            playrec('reset');
        end        
    end
    
    


% --- Executes on button press in radioFc10k.
function radioFc10k_Callback(hObject, eventdata, handles)
% hObject    handle to radioFc10k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioFc10k


% --- Executes on button press in radioFc18k.
function radioFc18k_Callback(hObject, eventdata, handles)
% hObject    handle to radioFc18k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioFc18k



function tbResult_Callback(hObject, eventdata, handles)
% hObject    handle to tbResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbResult as text
%        str2double(get(hObject,'String')) returns contents of tbResult as a double


% --- Executes during object creation, after setting all properties.
function tbResult_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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


% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global Fc;
    global Fs;
    pageSize = 2048;
    minRecogLength = 1000;
    
    filename = get(handles.tbFilename, 'String');
    if strcmp(filename(end-3:end),'.wav') == 0
        filename = [filename, '.wav'];
    end
    filename = [pwd, '/', filename];
%     rxAudioData = wavread(filename);
    rxAudioData = audioread(filename);
    
    roiData = detectDataRegion(rxAudioData, Fc);
    data = analyzeAudioData(roiData, Fc);
    data = reshape(data,8,[])
    
    k = 1:size(data,2);
    resultString = char(size(data,2))
    resultString(k) = encodeChar(data(:,k));
    set(handles.tbResult, 'String', resultString);
    
    
%     figure();
%     plot(rxAudioData);
    
%     %%%%%%%%%%%%       
%     roiData = detectDataRegion(rxAudioData, Fc);
%     roiData = freqDownConversion(roiData, Fs, Fc);
% 
%     analyzedData = analyzeAudioData(roiData);
%     result = encodeChar(analyzedData);
%     set(handles.tbResult, 'String', result);
%     %%%%%%%%%%%%

    



% 
%     rxAudioData = [zeros(1,1); rxAudioData];
%     reshapedRx = [rxAudioData; zeros(pageSize - mod(length(rxAudioData), pageSize), 1)];
%     reshapedRx = reshape(reshapedRx,pageSize,[]);
%     textResetCnt = 5;
%     dataBlk = [];
%     remainedBlk = [];
%     noDataCnt = 0;
%     resultString = [];
%     
% %     detectDataRegion(rxAudioData,Fc);
%     
%     size(reshapedRx,2);

%     
%     for idx=1:size(reshapedRx,2)
% 
%         [rcvDataBlk, remainedBlk] = detectDataRegion([remainedBlk; reshapedRx(:,idx)], Fc);
%         
%         if( ~isempty(rcvDataBlk)) % Found
%             if( isempty(remainedBlk)) %continue
%                 dataBlk = [dataBlk; rcvDataBlk];  
%             else %not Continue
%                 dataBlk = [dataBlk; rcvDataBlk];
%                 length(dataBlk);
%                 % No consideration for the case of the data block ends
%                 % exactly the buffer page
%                 
%                 if(length(dataBlk) > minRecogLength)
%                     roiData = freqDownConversion(dataBlk, Fc, Fs);
%                     
%                     % %%%%% LPF %%%%%%%%%%% 
%                     lpf = txrxLpf;
%                     lpfDelay = ceil(lpf.order / 2);
%                     extRoiData = [roiData; zeros(lpfDelay,1)];
%                     filtRoiData = filter(lpf, extRoiData);
%                     filtRoiData = filtRoiData(lpfDelay+1 :end);
%                     
%                     analyzedData = analyzeAudioData(filtRoiData);
%                     resultChar = encodeChar(analyzedData);
%                     resultString = [resultString, resultChar];
%                     set(handles.tbResult, 'String', resultString);
% 
%                 end
%                 dataBlk = [];
%             end
%         elseif( ~isempty(resultString) )
%             noDataCnt = noDataCnt+1;
%             if(noDataCnt > textResetCnt)
%                 resultString = [];
%                 noDataCnt = 0;
%             end
%         end
%     end
    %%%%%%%%%%%%
    
    
    
    
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
        case handles.radioFc19k
            Fc = 19000;            
        case handles.radioFc20k
            Fc = 20000;
    end
    
    
% 
% % --- Executes on button press in btnStart.
% function btnStart_Callback(hObject, eventdata, handles)
% % hObject    handle to btnStart (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
%     global Fs;
%     global recFlag;
%     global recObj;
% 
%     recObj = audiorecorder(Fs,8,1);
%     recFlag = 1;
% %     while 1
%         recordblocking(recObj,1000);
% %     end
% 
% 
% 
% % --- Executes on button press in btnReceive2.
% function btnReceive2_Callback(hObject, eventdata, handles)
% % hObject    handle to btnReceive2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
%     global Fc;
%     global Fs;
%     global recObj;
%     global recFlag;
%     
%     pos = 1;
% 
%     
%     while recFlag == 1
%         while recFlag == 1 && length(getaudiodata(recObj))-pos >= Fs/10
%             samps = getaudiodata(recObj);
%             
%             startPos = pos - Fs/10 + 1;
%             if(startPos < 0) 
%                 startPos = 1;
%             end
%             
%             endPos = pos + Fs/10;
%             roiData = detectDataRegion(samps(startPos:endPos-1), Fc);
%             pos = endPos;
% 
%             
%             if(length(roiData) > 1280)
%                 length(roiData)
%                 roiData = freqDownConversion(roiData, Fs, Fc);
% 
%                 analyzedData = analyzeAudioData(roiData);
%                 result = encodeChar(analyzedData);
% 
% 
%     %             length(rcv_result)
% 
%     %             rcv_result = 'decode_output'; % Result of Decoding Function
% %                 set(handles.tbResult,'string',result);
% 
% 
%             end
% 
%         end
%     end
% 
% 
% 
% % --- Executes on button press in btnStop.
% function btnStop_Callback(hObject, eventdata, handles)
% % hObject    handle to btnStop (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
%     global recObj;
%     global recFlag;
%     recFlag = 0;
%     stop(recObj);
%     
