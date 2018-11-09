function varargout = RegLSM_SingleCheck(varargin)
% REGLSM_SINGLECHECK MATLAB code for RegLSM_SingleCheck.fig
%      REGLSM_SINGLECHECK, by itself, creates a new REGLSM_SINGLECHECK or raises the existing
%      singleton*.
%
%      H = REGLSM_SINGLECHECK returns the handle to a new REGLSM_SINGLECHECK or the handle to
%      the existing singleton*.
%
%      REGLSM_SINGLECHECK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGLSM_SINGLECHECK.M with the given input arguments.
%
%      REGLSM_SINGLECHECK('Property','Value',...) creates a new REGLSM_SINGLECHECK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegLSM_SingleCheck_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegLSM_SingleCheck_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegLSM_SingleCheck

% Last Modified by GUIDE v2.5 28-Mar-2017 11:38:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegLSM_SingleCheck_OpeningFcn, ...
                   'gui_OutputFcn',  @RegLSM_SingleCheck_OutputFcn, ...
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


% --- Executes just before RegLSM_SingleCheck is made visible.
function RegLSM_SingleCheck_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegLSM_SingleCheck (see VARARGIN)

% Choose default command line output for RegLSM_SingleCheck
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RegLSM_SingleCheck wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RegLSM_SingleCheck_OutputFcn(hObject, eventdata, handles) 
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
Dir=handles.Dir.String;
currentFolder = pwd;
Im_ref=[];
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
    spm_check_registration(Im_ref,Im_reg);
else
    errordlg('Specified registration result not found!');
end

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


% --- Executes on button press in OpenSubfolder.
function OpenSubfolder_Callback(hObject, eventdata, handles)
% hObject    handle to OpenSubfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Dir = uigetdir;
if isempty(Dir)||length(Dir)<=1
    return;
end
if ~isdir(strcat(Dir,'\to_MNI'))&&~isdir(strcat(Dir,'\DWI_to_T1'))&&~isdir(strcat(Dir,'\FLAIR_to_T1'))&&~isdir(strcat(Dir,'\T1_to_SC'))
    errordlg('Please select another subject folder. There are no results supported for checking.');
        return;
end
set(handles.Dir,'String',Dir);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
