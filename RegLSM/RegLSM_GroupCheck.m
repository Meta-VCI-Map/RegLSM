function varargout = RegLSM_GroupCheck(varargin)
% REGLSM_GROUPCHECK MATLAB code for RegLSM_GroupCheck.fig
%      REGLSM_GROUPCHECK, by itself, creates a new REGLSM_GROUPCHECK or raises the existing
%      singleton*.
%
%      H = REGLSM_GROUPCHECK returns the handle to a new REGLSM_GROUPCHECK or the handle to
%      the existing singleton*.
%
%      REGLSM_GROUPCHECK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGLSM_GROUPCHECK.M with the given input arguments.
%
%      REGLSM_GROUPCHECK('Property','Value',...) creates a new REGLSM_GROUPCHECK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegLSM_GroupCheck_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegLSM_GroupCheck_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegLSM_GroupCheck

% Last Modified by GUIDE v2.5 28-Mar-2017 11:37:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegLSM_GroupCheck_OpeningFcn, ...
                   'gui_OutputFcn',  @RegLSM_GroupCheck_OutputFcn, ...
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


% --- Executes just before RegLSM_GroupCheck is made visible.
function RegLSM_GroupCheck_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegLSM_GroupCheck (see VARARGIN)

% Choose default command line output for RegLSM_GroupCheck
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RegLSM_GroupCheck wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RegLSM_GroupCheck_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in CheckReg.
function CheckReg_Callback(hObject, eventdata, handles)
% hObject    handle to CheckReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'subjects')
   subject_folder=handles.subjects;
else subject_folder=[];
end
Dir_code = pwd;
startNO=str2double(handles.SubNO.String);
if isempty(subject_folder)
    errordlg('Please open a folder first!');
    return;
elseif startNO>length(subject_folder)
    errordlg('Folder index exceeds the number of subjects: index is reset to 1');
    startNO=1;
    handles.SubNO.String=num2str(1);
end
    

handles.CurrentSubfolder.String=strcat(handles.Dir.String,'\',subject_folder{startNO});
guidata(hObject, handles);

Im_ref=[];

Dir=strcat(handles.Dir.String,'\',subject_folder{startNO});
temp=cellstr(handles.Reg2Check.String);
Reg2Check=temp{handles.Reg2Check.Value};
if ~isempty(strfind(Reg2Check,'MNI'))
    result_folder='to_MNI';
    Im_ref=strcat(Dir_code,'\Template\MNI152_T1_1mm.nii');
    Im_reg=strcat(Dir,'\',result_folder,'\result.nii');
elseif ~isempty(strfind(Reg2Check,'SC'))
    result_folder='T1_to_SC';
    Im_ref=strcat(Dir_code,'\Template\sct1_unsmooth.nii');
    Im_reg=strcat(Dir,'\',result_folder,'\result.1.nii');
elseif ~isempty(strfind(Reg2Check,'DWI'))
    result_folder='DWI_to_T1';
    Im_ref=find_Ref_T1(handles.Dir.String,Dir,startNO);
    Im_reg=strcat(Dir,'\',result_folder,'\result.0.nii');
elseif ~isempty(strfind(Reg2Check,'FLAIR'))
    result_folder='FLAIR_to_T1';
    Im_ref=find_Ref_T1(handles.Dir.String,Dir,startNO);
    Im_reg=strcat(Dir,'\',result_folder,'\result.0.nii');
end

if ~exist(Im_reg,'file')
    errordlg('Registration not finished!');
    return;
end

spm_check_registration(Im_ref,Im_reg);


function SubNO_Callback(hObject, eventdata, handles)
% hObject    handle to SubNO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SubNO as text
%        str2double(get(hObject,'String')) returns contents of SubNO as a double


% --- Executes during object creation, after setting all properties.
function SubNO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubNO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckNext.
function CheckNext_Callback(hObject, eventdata, handles)
% hObject    handle to CheckNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'subjects')
   subject_folder=handles.subjects;
else 
    errordlg('Please select a folder!');
        return;
    
end
SubNO=str2double(handles.SubNO.String)+1;
if SubNO<=length(subject_folder)
    handles.SubNO.String=num2str(SubNO);
else 
    handles.SubNO.String='1';
end

startNO=str2double(handles.SubNO.String);

handles.CurrentSubfolder.String=strcat(handles.Dir.String,'\',subject_folder{startNO});
guidata(hObject, handles);

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


% --- Executes on button press in OpenFolder.
function OpenFolder_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Dir = uigetdir;
if ~isempty(Dir)&&length(Dir)>1
    [subfolders,~]=doc_name(Dir);
else
    return;
end

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
set(handles.NumSub,'String',['/',blanks(2),num2str(length(subfolders))]);
set(handles.Dir,'String',Dir);
handles.subjects=subfolders;
guidata(hObject, handles);
