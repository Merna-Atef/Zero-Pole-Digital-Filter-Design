function varargout = dragTry(varargin)
% DRAGTRY MATLAB code for dragTry.fig
%      DRAGTRY, by itself, creates a new DRAGTRY or raises the existing
%      singleton*.
%
%      H = DRAGTRY returns the handle to a new DRAGTRY or the handle to
%      the existing singleton*.
%
%      DRAGTRY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRAGTRY.M with the given input arguments.
%
%      DRAGTRY('Property','Value',...) creates a new DRAGTRY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dragTry_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dragTry_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dragTry

% Last Modified by GUIDE v2.5 08-Jun-2019 13:08:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dragTry_OpeningFcn, ...
                   'gui_OutputFcn',  @dragTry_OutputFcn, ...
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

% --- Executes just before dragTry is made visible.
function dragTry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dragTry (see VARARGIN)

% Choose default command line output for dragTry

% global pcount
global imPoles
global polePos
polePos = [];
imPoles = [];

global imZeros
global zeroPos
zeroPos = [];
imZeros = [];
% pcount = 0;
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dragTry wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = dragTry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in zero.
function zero_Callback(hObject, eventdata, handles)
% hObject    handle to zero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%     global counter
    global imZeros
    global conjZero
    global conjugate
%     counter = counter + 1;
    axes(handles.unitCir)
    z = impoint(gca,[]);
    if conjugate == 1
        pos = getPosition(z);
        if pos(1,2) ~= 0
            point = impoint(gca,pos(1,1),-pos(1,2));
            conjZero = [conjZero; point];
            setColor(point,'blue');
        end
    end
    setColor(z,'b');
    imZeros = [imZeros; z];
    
 
    
% --- Executes on button press in pole.
function pole_Callback(hObject, eventdata, handles)
% hObject    handle to pole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global imPoles
    global conjPole
    global conjugate
%     global pcount
%     pcount = pcount + 1;
    axes(handles.unitCir);
    p = impoint(gca,[]);
    if conjugate == 1
        pos = getPosition(p);
        if pos(1,2)~= 0
            point = impoint(gca,pos(1,1),-pos(1,2));
            conjPole = [conjPole; point];
            setColor(point,'black');
        end
    end
    imPoles = [imPoles; p];
    setColor(p,'black');
%     position = wait(p);



% --- Executes on button press in plotResp.
function plotResp_Callback(hObject, eventdata, handles)
% hObject    handle to plotResp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imPoles
global imZeros
global polePos
global zeroPos
global conjugate
global check
global fs
s = get(handles.fsample,'String');
if isempty(s)
    msgbox('Type Fs','ERROR')
else
    if check
        polePos = [];
        zeroPos = [];
        for i = 1:numel(imPoles)
            if isvalid(imPoles(i))
               polePos = [polePos; getPosition(imPoles(i))];
            end
        end

        for i = 1:numel(imZeros)
            if isvalid(imZeros(i))
               zeroPos = [zeroPos; getPosition(imZeros(i))]
            end
        end
        if size(polePos)==0
            p = 0;
        else
            p = complex(polePos(:,1),polePos(:,2));
        end
        if size(zeroPos)==0
            z = 0;
        else
            z = complex(zeroPos(:,1),zeroPos(:,2))
        end

        if conjugate == 1
            z = [z; conj(z)];
            p = [p; conj(p)];
        end
        [b,a] = zp2tf(z, p,1);
        [h,f] = freqz(b,a,3142,fs);
        axes(handles.readyFn);
        plot(f,20*log10(abs(h)))
        axes(handles.loop);
        p = 0:0.001:pi;
        x = cos(p);
        y = sin(p);
        point = [x;y]';
        poleDist = [];
        zeroDist = [];
        pd = [];
        zd = [];
        gain = [];
        for i = 1:3142
            for j = 1:size(polePos,1)
                pd = [pd norm(point(i,:)- polePos(j,:))];
            end

            for j = 1:size(zeroPos,1)
                zd = [zd norm(point(i,:)- zeroPos(j,:))];
            end
            zeroDist = prod(zd);   
            poleDist = prod(pd);
            gain = [gain zeroDist/poleDist];
            zd = [];
            pd = [];ithu
        end
        gain(1,1:10)
        f1 = linspace(0,fs/2,3142);
        plot(f1,20*log10(gain));
        
    else
        msgbox('Type a number','ERROR')
    end
end


% --- Executes during object creation, after setting all properties.
function unitCir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unitCir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
hold on;
viscircles([0,0],1,'EdgeColor','red')
PlotAxisAtOrigin(0,0)
% Hint: place code in OpeningFcn to populate unitCir


% --- Executes on button press in btnBrowse.
function btnBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnFilter.
function btnFilter_Callback(hObject, eventdata, handles)
% hObject    handle to btnFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in conj.
function conj_Callback(hObject, eventdata, handles)
% hObject    handle to conj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global conjugate
global imPoles
global imZeros
global conjZero
global conjPole
conjugate = 1;
axes(handles.unitCir);
for i = 1:numel(imPoles)
    if isvalid(imPoles(i))
        pos = getPosition(imPoles(i));
        if pos(1,2) ~= 0
            point = impoint(gca, pos(1,1), -pos(1,2));
            conjPole = [conjPole; point ];
            setColor(point,'black');
        end
    end
end

for i = 1:numel(imZeros)
    if isvalid(imZeros(i))
        pos = getPosition(imZeros(i));
        if pos(1,2) ~= 0
            point = impoint(gca, pos(1,1), -pos(1,2));
            conjZero = [conjZero; point];
            setColor(point,'blue');
        end        
    end
end

% Hint: get(hObject,'Value') returns toggle state of conj
 

% --- Executes on button press in noConj.
function noConj_Callback(hObject, eventdata, handles)
% hObject    handle to noConj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global conjugate
global conjZero
global conjPole
conjugate = 0;
axes(handles.unitCir);
for i = 1:numel(conjZero)
    if isvalid(conjZero(i))
        delete(conjZero(i));
    end
end
for i = 1:numel(conjPole)
    if isvalid(conjPole(i))
        delete(conjPole(i));
    end
end
conjPole = [];
conjZero = [];
% Hint: get(hObject,'Value') returns toggle state of noConj



function fsample_Callback(hObject, eventdata, handles)
% hObject    handle to fsample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fs
global check
fs = str2double(get(hObject,'String'))
if ~isnan(fs)
    check = true;
else
    check = false;
    msgbox('Type a number','ERROR')
end
% Hints: get(hObject,'String') returns contents of fsample as text
%        str2double(get(hObject,'String')) returns contents of fsample as a double


% --- Executes during object creation, after setting all properties.
function fsample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fsample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
