function Im_ref=find_Ref_T1(Dir_form,Dir_subject,SubID)
Im_ref=[];
T1=[];
[files,~]=doc_name(Dir_form);
    for i=1:length(files)
        if ~isempty(strfind(files{i},'batch_record'))&&~isempty(strfind(files{i},'.xlsx'))
            [~,~,record]=xlsread(strcat(Dir_form,'\',files{i}));
            if SubID+1>size(record,1)||size(record,2)<4
                break;
            else
                Im_ref=record{SubID+1,4};
            end
                    
        end
    end
    
    if isempty(Im_ref)
        [files,~]=doc_name(Dir_subject);
        for i=1:length(files)
            if ~isempty(strfind(files{i},'T1'))&&~isempty(strfind(files{i},'.nii'))
                T1=files{i};
            end
        end
        if ~isempty(T1)
            Im_ref=strcat(Dir_subject,'\',T1);
        else 
            errordlg('Reference T1 image not found!');
        end
    end
end
    
    
    