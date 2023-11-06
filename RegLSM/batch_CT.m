function subject_record=batch_CT(Dir_code,Dir,subfolders,copyLesionGeometry)
%% Initialization
% Identify the subfolders with sufficient images for specified registration
subject_record=cell(length(subfolders)+1,3);
for i=1:length(subfolders)
    subject_record(1,1:3)={'Subject folder name','Lesion mask','Source image'};
    subject_record(i+1,1)=subfolders(i);    
end


for i=1:length(subfolders)
    notNii=[];t=1;
    [img,~]=doc_name(strcat(Dir,'\',subfolders{i}));
    for j=1:length(img)
        if isempty(strfind(img{j},'.nii'))
            notNii(t)=j;
            t=t+1;
        end
    end
    if ~isempty(notNii)
        img(notNii)=[];
    end
    Dir_img=cell(length(img),1);
    for j=1:length(Dir_img)
        Dir_img{j}=strcat(Dir,'\',subfolders{i},'\',img{j});
    end
    
    try
        % Call test mode for image registration of a single subject
        sub_record=test_CT(Dir_code,Dir_img,'record',copyLesionGeometry);
        subject_record(i+1,2:3)=sub_record; 
    catch 
        fileID = fopen(strcat(Dir,'\',subfolders{i},'\','FAILED.TXT'), 'w');
        fprintf(fileID, 'This one has failed.');        
        fclose(fileID);
    end
end
    
