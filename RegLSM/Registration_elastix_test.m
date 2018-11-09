function Registration_elastix_test(Dir_img,scheme)
Dir_code = pwd;
%% Initialization for specific registration scheme
if isempty(Dir_img)
    errordlg('Please specify the images to be registered!');
        return;
elseif isempty(scheme)
    errordlg('The registration scheme has not been specified!');
        return;

end
% sub_record=[];
if ~isempty(strfind(scheme,'DWI_with_T1'))
    test_DWI_T1(Dir_code,Dir_img,[]);
elseif ~isempty(strfind(scheme,'DWI_without_T1'))
    test_DWI_no_T1(Dir_code,Dir_img,[]);
elseif ~isempty(strfind(scheme,'FLAIR_with_T1'))&&isempty(strfind(scheme,'+'))
    test_FLAIR_T1(Dir_code,Dir_img,[]);
elseif ~isempty(strfind(scheme,'FLAIR_with_T1+'))
    test_FLAIR_T1_plus(Dir_code,Dir_img,[]);
elseif ~isempty(strfind(scheme,'FLAIR_without_T1'))&&isempty(strfind(scheme,'+'))
    test_FLAIR_no_T1(Dir_code,Dir_img,[],[]);
elseif ~isempty(strfind(scheme,'FLAIR_without_T1+'))
    test_FLAIR_no_T1(Dir_code,Dir_img,'+',[]);
elseif ~isempty(strfind(scheme,'CT'))
    test_CT(Dir_code,Dir_img,[]);
else 
    errordlg('The registration scheme has not been specified!');
    return;
end
% sub_inf=cell(2,4);
% sub_inf(1,:)={'Subject folder name','Lesion mask','Source image','T1 image'};
% sub_inf(2,2:4)=sub_record;
% id=strfind(Dir_img{1},'\');
% Dir=Dir_img{1}(1:(id(end)-1));
% if ~isempty(sub_inf)
%     xlswrite(strcat(Dir,'\batch_record_',datestr(now,30),'.xlsx'),sub_inf);
% end
        
    