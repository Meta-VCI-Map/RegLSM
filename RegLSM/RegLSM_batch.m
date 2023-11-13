function varargout = RegLSM_batch(varargin)
% REGLSM_BATCH MATLAB code for RegLSM_batch.fig
%      REGLSM_BATCH, by itself, creates a new REGLSM_BATCH or raises the existing
%      singleton*.
%
%      H = REGLSM_BATCH returns the handle to a new REGLSM_BATCH or the handle to
%      the existing singleton*.
%
%      REGLSM_BATCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGLSM_BATCH.M with the given input arguments.
%
%      REGLSM_BATCH('Property','Value',...) creates a new REGLSM_BATCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegLSM_batch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegLSM_batch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegLSM_batch

% Last Modified by GUIDE v2.5 25-Sep-2023 16:26:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegLSM_batch_OpeningFcn, ...
                   'gui_OutputFcn',  @RegLSM_batch_OutputFcn, ...
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


% --- Executes just before RegLSM_batch is made visible.
function RegLSM_batch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegLSM_batch (see VARARGIN)

% Choose default command line output for RegLSM_batch
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RegLSM_batch wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RegLSM_batch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in OpenFolder.
function OpenFolder_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the global folder directory 
Dir = uigetdir;
if isempty(Dir)||length(Dir)<=1
    return;
end
set(handles.Dir,'String',Dir);
% Get the subject folders (excluding files that are not folders)
guidata(hObject, handles);
[subfolders,~]=doc_name(Dir);
notFolder=[];
t=1;
for i=1:length(subfolders)
    if ~isdir(strcat(Dir,'\',subfolders{i}))
        notFolder(t)=i;
        t=t+1;
    end
end
subfolders(notFolder)=[];

if isempty(subfolders)
    errordlg('No subfolders found in the specified folder: images should be put in seperate folders for each patient.');
        return;
end
handles.subjects=subfolders;
guidata(hObject, handles);


% --- Executes on selection change in RegScheme.
function RegScheme_Callback(hObject, eventdata, handles)
% hObject    handle to RegScheme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RegScheme contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RegScheme
contents = cellstr(get(hObject,'String'));
handles.scheme=contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function RegScheme_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RegScheme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StartReg.
function StartReg_Callback(~, ~, handles)
% hObject    handle to StartReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Dir=handles.Dir.String;
if isfield(handles,'scheme')
   scheme=handles.scheme;
else scheme=[];
end
copyLesionGeometry = handles.copyLesionGeometry.Value;
% Start registration
Registration_elastix_batch(Dir, scheme, copyLesionGeometry);


% --- Executes on selection change in Dir.
function Dir_Callback(hObject, eventdata, handles)
% hObject    handle to Dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Dir contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Dir


% --- Executes on button press in copyLesionGeometry.
function copyLesionGeometry_Callback(hObject, eventdata, handles)
% hObject    handle to copyLesionGeometry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of copyLesionGeometry
