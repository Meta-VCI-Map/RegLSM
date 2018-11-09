function varargout = RegLSM(varargin)
% RegLSM MATLAB code for RegLSM.fig
%      RegLSM, by itself, creates a new RegLSM or raises the existing
%      singleton*.
%
%      H = RegLSM returns the handle to a new RegLSM or the handle to
%      the existing singleton*.
%
%      RegLSM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RegLSM.M with the given input arguments.
%
%      RegLSM('Property','Value',...) creates a new RegLSM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegLSM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegLSM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegLSM

% Last Modified by GUIDE v2.5 28-Mar-2017 10:51:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegLSM_OpeningFcn, ...
                   'gui_OutputFcn',  @RegLSM_OutputFcn, ...
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


% --- Executes just before RegLSM is made visible.
function RegLSM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegLSM (see VARARGIN)

% Choose default command line output for RegLSM
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RegLSM wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RegLSM_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function RegMode_Callback(hObject, eventdata, handles)
% hObject    handle to RegMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function TestMode_Callback(hObject, eventdata, handles)
% hObject    handle to TestMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RegLSM_test


% --------------------------------------------------------------------
function BatchMode_Callback(hObject, eventdata, handles)
% hObject    handle to BatchMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RegLSM_batch


% --------------------------------------------------------------------
function OpenManual_Callback(hObject, eventdata, handles)
% hObject    handle to OpenManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentFolder=pwd;
dir_manual=strcat(currentFolder,'\Manual\RegLSM Manual.pdf');
winopen(dir_manual);

% --------------------------------------------------------------------
function About_Callback(hObject, eventdata, handles)
% hObject    handle to About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function CheckReg_Callback(hObject, eventdata, handles)
% hObject    handle to CheckReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SingleCheck_Callback(hObject, eventdata, handles)
% hObject    handle to SingleCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RegLSM_SingleCheck

% --------------------------------------------------------------------
function GroupCheck_Callback(hObject, eventdata, handles)
% hObject    handle to GroupCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RegLSM_GroupCheck
