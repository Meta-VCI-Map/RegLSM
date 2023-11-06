function Dir_subject=Registration_elastix_batch(Dir, scheme, copyLesionGeometry)
Dir_code = fileparts(which('RegLSM.m'));
%% Initialization for specific registration scheme
if isempty(Dir)
    errordlg('Please specify the folder where images locate!');
        return;
elseif isempty(scheme)
    errordlg('The registration scheme has not been specified!');
        return;
end
        
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

Dir_subject=cell(length(subfolders),1);
for i=1:length(subfolders)
    Dir_subject{i}=strcat(Dir,'\',subfolders{i});
end

subject_record=[];
if ~isempty(strfind(scheme,'DWI_with_T1'))
    subject_record=batch_DWI_T1(Dir_code,Dir,subfolders,copyLesionGeometry);
elseif ~isempty(strfind(scheme,'DWI_without_T1'))
    subject_record=batch_DWI_no_T1(Dir_code,Dir,subfolders,copyLesionGeometry);
elseif ~isempty(strfind(scheme,'FLAIR_with_T1'))&&isempty(strfind(scheme,'+'))
    subject_record=batch_FLAIR_T1(Dir_code,Dir,subfolders,copyLesionGeometry);
elseif ~isempty(strfind(scheme,'FLAIR_with_T1+'))
    subject_record=batch_FLAIR_T1_plus(Dir_code,Dir,subfolders,copyLesionGeometry);
elseif ~isempty(strfind(scheme,'FLAIR_without_T1'))&&isempty(strfind(scheme,'+'))
    subject_record=batch_FLAIR_no_T1(Dir_code,Dir,subfolders,[],copyLesionGeometry);
elseif ~isempty(strfind(scheme,'FLAIR_without_T1+'))
    subject_record=batch_FLAIR_no_T1(Dir_code,Dir,subfolders,'+',copyLesionGeometry);
elseif ~isempty(strfind(scheme,'CT'))
    subject_record=batch_CT(Dir_code,Dir,subfolders,copyLesionGeometry);
else 
    errordlg('The registration scheme has not been specified!');
    return;
end

if ~isempty(subject_record)
    xlswrite(strcat(Dir,'\batch_record_',datestr(now,30),'.xlsx'),subject_record);
end
        
    