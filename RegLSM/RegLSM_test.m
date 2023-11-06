function varargout = RegLSM_test(varargin)
% REGLSM_TEST MATLAB code for RegLSM_test.fig
%      REGLSM_TEST, by itself, creates a new REGLSM_TEST or raises the existing
%      singleton*.
%
%      H = REGLSM_TEST returns the handle to a new REGLSM_TEST or the handle to
%      the existing singleton*.
%
%      REGLSM_TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGLSM_TEST.M with the given input arguments.
%
%      REGLSM_TEST('Property','Value',...) creates a new REGLSM_TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegLSM_test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegLSM_test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegLSM_test

% Last Modified by GUIDE v2.5 25-Sep-2023 16:24:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegLSM_test_OpeningFcn, ...
                   'gui_OutputFcn',  @RegLSM_test_OutputFcn, ...
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


% --- Executes just before RegLSM_test is made visible.
function RegLSM_test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegLSM_test (see VARARGIN)

% Choose default command line output for RegLSM_test
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RegLSM_test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RegLSM_test_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in OpenImage.
function OpenImage_Callback(hObject, eventdata, handles)
% hObject    handle to OpenImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname, filterindex] = uigetfile( ...
{  '*.nii','nii-files (*.nii)'; }, ...
   'Pick a file', ...
   'MultiSelect', 'on');
if isempty(filename)||length(filename)<=1
    return;
end

if isa(filename, 'char') % only 1 file selected
    filename = cellstr(filename);
end

Dir=cell(length(filename),1);

for i=1:length(filename)
    Dir{i}=strcat(pathname,filename{i});
end
set(handles.Dir,'String',Dir);

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
Dir_img=handles.Dir.String;
if isfield(handles,'scheme')
   scheme=handles.scheme;
else scheme=[];
end
copyLesionGeometry = handles.copyLesionGeometry.Value;
Registration_elastix_test(Dir_img, scheme, copyLesionGeometry);




% --- Executes on button press in CheckReg.
function CheckReg_Callback(hObject, eventdata, handles)
% hObject    handle to CheckReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Read directories of the selected images
Dir_img=handles.Dir.String;
id=strfind(Dir_img{1},'\');
% Target the folder containing the selected images
Dir=Dir_img{1}(1:(id(end)-1));
currentFolder = pwd;
Im_ref=[];
% Read from the interface the step that the user wants to check
Reg2Check=handles.Reg2Check.String{handles.Reg2Check.Value};
if ~isempty(strfind(Reg2Check,'MNI'))
    result_folder='to_MNI';
    Im_ref=strcat(currentFolder,'\Template\MNI152_T1_1mm.nii');
    Im_reg=strcat(Dir,'\',result_folder,'\result.nii');
elseif ~isempty(strfind(Reg2Check,'SC'))
    result_folder='T1_to_SC';
    Im_ref=strcat(currentFolder,'\Template\sct1_unsmooth.nii');
    Im_reg=strcat(Dir,'\',result_folder,'\result.1.nii');
elseif ~isempty(strfind(Reg2Check,'DWI'))
    result_folder='DWI_to_T1';
    Im_ref=find_Ref_T1(Dir,Dir,1);    
    Im_reg=strcat(Dir,'\',result_folder,'\result.0.nii');
elseif ~isempty(strfind(Reg2Check,'FLAIR'))
    result_folder='FLAIR_to_T1';
    Im_ref=find_Ref_T1(Dir,Dir,1);
    Im_reg=strcat(Dir,'\',result_folder,'\result.0.nii');
end

if exist(Im_reg,'file')
    spm_check_registration(Im_ref,Im_reg);% call SPM function for checking
else
    errordlg('Specified registration result not found!');
end

% --- Executes on selection change in Dir.
function Dir_Callback(hObject, eventdata, handles)
% hObject    handle to Dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Dir contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Dir


% --- Executes on selection change in Reg2Check.
function Reg2Check_Callback(hObject, eventdata, handles)
% hObject    handle to Reg2Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Reg2Check contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Reg2Check
contents = cellstr(get(hObject,'String'));
handles.Reg2check.Value=contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Reg2Check_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Reg2Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in copyLesionGeometry.
function copyLesionGeometry_Callback(hObject, eventdata, handles)
% hObject    handle to copyLesionGeometry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of copyLesionGeometry
