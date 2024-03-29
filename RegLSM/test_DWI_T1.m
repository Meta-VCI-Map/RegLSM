function sub_record=test_DWI_T1(Dir_code,Dir_img,record,copyLesionGeometry)
%% Initialization 
    sub_record=cell(1,3);   
    % Check if the input images is sufficient to perform the specified
    % registration scheme
    Img=cell(length(Dir_img),1);    
    for i=1:length(Dir_img)
        id=strfind(Dir_img{i},'\');        
        Img{i}=Dir_img{i}((id(end)+1):end);
    end
    % Get the required images (leison mask,source image and T1)
    t1=0;dwi=0;lesion=0;% Image counters
    for i=1:length(Dir_img)
        if ~isempty(strfind(Img{i},'lesion'))&&~isempty(strfind(Img{i},'DWI'))
            lesion=lesion+1;
            LESION_org=Dir_img{i};
            % Check if the nii image is 4D and make conversion to 3D if
            % applicable (the first image of 4D nii would be used by default )
            convt_img=convert_nii_4D_to_3D(LESION_org);
            if isempty(convt_img)
                sub_record{1}=LESION_org;
                LESION=LESION_org;
            else
                LESION=convt_img;
                sub_record{1}=LESION;
            end
        elseif ~isempty(strfind(Img{i},'T1'))
            t1=t1+1;
            T1=Dir_img{i};
            % Check if the nii image is 4D and make conversion to 3D if applicable 
            % (the first image of 4D nii would be used by default )   
            convt_img=convert_nii_4D_to_3D(T1);
            if isempty(convt_img)
                sub_record{3}=T1;
            else
                T1=convt_img;
                sub_record{3}=T1;
            end
        end
    end
    if lesion<1&&isempty(record) % Check lesion mask for test mode
        errordlg('Lesion segmentation not found!');
        return;
    elseif lesion<1&&~isempty(record) % Check lesion mask for batch mode
        sub_record{1}=num2str(lesion);
        return;  
    else 
        % Get source image (DWI)
        for i=1:length(Dir_img)
          % It's recommended that the lesion mask has the same name as
          % source image except for the string of 'lesion'
          if ~isempty(strfind(LESION_org,Dir_img{i}(1:(end-4))))&&isempty(strfind(Img{i}(1:(end-4)),'lesion'))
            dwi=dwi+1;
            DWI=Dir_img{i};
            % Check if the nii image is 4D and make conversion to 3D if applicable
            % (the first image of 4D nii would be used by default ) 
            convt_img=convert_nii_4D_to_3D(DWI);            
            if isempty(convt_img)
                sub_record{2}=DWI;
            else
                DWI=convt_img;
                sub_record{2}=DWI;
            end
            
            break;
          % If there is no source image that matches lesion in name, we
          % would select a source image randomly (last one in name order)
          elseif ~isempty(strfind(Img{i},'DWI'))&&isempty(strfind(Img{i}(1:(end-4)),'lesion'))
            warning('The name of lesion mask does not match source image: the source image is selected randomly!');
            dwi=dwi+1;
            DWI=Dir_img{i};
            % Check if the nii image is 4D and make conversion to 3D if applicable
            % (the first image of 4D nii would be used by default ) 
            convt_img=convert_nii_4D_to_3D(DWI);            
            if isempty(convt_img)
                sub_record{2}=DWI;
            else
                DWI=convt_img;
                sub_record{2}=DWI;
            end
            
          end
        end
    end    
    if t1<1&&isempty(record)
        errordlg('T1 image not found!');
        return;
    elseif t1<1&&~isempty(record)
        sub_record{3}='0';
        return;
    elseif dwi<1&&isempty(record)
        errordlg('DWI image not found!');
        return;
    elseif dwi<1&&~isempty(record)
        sub_record{2}='0';
        return;
    end

    if copyLesionGeometry
        copy_lesion_geometry(DWI, LESION);
    end
    
    % Specify parameter files for registration
    reg_T1_Rorden=['-p ',blanks(1),'"',Dir_code,'\Parameter\affine.txt','"',' -p ',blanks(1),'"',Dir_code,'\Parameter\bspline_CR.txt','"'];
    reg_DWI_T1=['-p ',blanks(1),'"',Dir_code,'\Parameter\Euler.txt','"'];
    % Specify the location of intermediate Rorden template
    SC=strcat(Dir_code,'\Template\sct1_unsmooth.nii');
    
    % Generate directories for temporary results
    id=strfind(Dir_img{1},'\');
    Dir=Dir_img{1}(1:(id(end)-1));
    mkdir(Dir,'batch');
    mkdir(Dir,'DWI_to_T1');
    mkdir(Dir,'T1_to_SC');
    mkdir(Dir,'to_MNI');
%% Writing elastix command for registration
    fid = fopen(strcat(Dir,'\batch\elastix_DWI_T1_SC.bat'),'wt');
    CMD_DWI_T1 = ['"',Dir_code,'\Elastix\elastix.exe' '"' ' -f' blanks(1) '"' T1 '"' blanks(1) '-m' blanks(1) '"' DWI '"' blanks(1) reg_DWI_T1 blanks(1) '-out' blanks(1) '"' strcat(Dir,'\DWI_to_T1') '"'];
    fprintf(fid, '%s\n', CMD_DWI_T1);
    CMD_T1_Rorden = ['"',Dir_code,'\Elastix\elastix.exe' '"' ' -f' blanks(1) '"' SC '"' blanks(1) '-m' blanks(1) '"' T1 '"' blanks(1) reg_T1_Rorden blanks(1) '-out' blanks(1) '"' strcat(Dir,'\T1_to_SC') '"'];
    fprintf(fid, '%s\n', CMD_T1_Rorden);
    fclose(fid);
    winopen(strcat(Dir,'\batch\elastix_DWI_T1_SC.bat'));
    disp('MATLAB continues after calling elastix.exe')
    
%% Wait until the registration is finished
flag = true;
while flag
     clc;
     disp('elastix.exe still running');   
     flag = isprocess('elastix.exe'); % isprocess is the function attached. Place it on the MATLAB path.
     pause(1) % check every 1 second
end
disp('registration from DWI to T1 to SC is Done');
%% Rewrite transformation files for final transformation of source image and lesion
dir_para=strcat(Dir_code,'\Parameter\');
dir_tar=strcat(Dir,'\to_MNI\');
para_name={'to_MNI.txt';'to_MNI_lesion.txt';'SC_to_MNI.txt';'SC_to_MNI.1.txt';...
           'TransformParameters.1.txt';'TransformParameters.0.txt';'DWI_to_SC.txt';'DWI_to_SC.1.txt';};
for i=1:length(para_name)
    if exist(strcat(dir_tar,para_name{i}),'file')
        delete(strcat(dir_tar,para_name{i}));
    end
end

for i=1:4
    copyfile(strcat(dir_para,para_name{i}),dir_tar);
end

str_no='NoInitialTransform';
clc;
    
    DWI_to_T1=strcat(Dir,'\DWI_to_T1\TransformParameters.0.txt');
    copyfile(DWI_to_T1,dir_tar);
    movefile(strcat(dir_tar,'TransformParameters.0.txt'),strcat(dir_tar,'DWI_to_T1.txt'));
    str_t1=strcat(dir_tar,'DWI_to_T1.txt');
    
    T1_to_SC=strcat(Dir,'\T1_to_SC\TransformParameters.1.txt');
    copyfile(T1_to_SC,dir_tar);
    movefile(strcat(dir_tar,'TransformParameters.1.txt'),strcat(dir_tar,'T1_to_SC.txt'));
    
    T1_to_SC_1=strcat(Dir,'\T1_to_SC\TransformParameters.0.txt');
    copyfile(T1_to_SC_1,dir_tar);
    movefile(strcat(dir_tar,'TransformParameters.0.txt'),strcat(dir_tar,'T1_to_SC.1.txt'));
    
    dir_init=strcat(dir_tar,'to_MNI.txt');
    dir_init_lesion=strcat(dir_tar,'to_MNI_lesion.txt');
    str_Rorden=strcat(dir_tar,'T1_to_SC.txt');
    dir_Rorden=strcat(dir_tar,'T1_to_SC.1.txt');
    str_MNI=strcat(dir_tar,'SC_to_MNI.txt');
    dir_MNI=strcat(dir_tar,'SC_to_MNI.1.txt');
    % Rewrite to_MNI.txt for DWI image
    fid_m=fopen(dir_init);
    count=1;
    str=[];
    while ~feof(fid_m)
          tline = fgetl(fid_m);
          str{count}=tline;
          count=count+1;
    end
    fclose(fid_m);    
    
    for k=1:(count-1)
        str{k}=strrep(str{k},str_no,str_t1);
    end
    fid_m = fopen(dir_init,'wt');
    for k=1:(count-1)
        fprintf(fid_m, '%s\n', str{k});
    end
    fclose(fid_m);
    % Rewrite to_MNI_lesion.txt for lesion mask
    fid_m=fopen(dir_init_lesion);
    count=1;
    str=[];
    while ~feof(fid_m)
          tline = fgetl(fid_m);
          str{count}=tline;
          count=count+1;
    end
    fclose(fid_m);    
    
    for k=1:(count-1)
        str{k}=strrep(str{k},str_no,str_t1);
    end
    fid_m = fopen(dir_init_lesion,'wt');
    for k=1:(count-1)
        fprintf(fid_m, '%s\n', str{k});
    end
    fclose(fid_m);
    
    % Rewrite DWI_to_T1_Euler transformation file with initial registration of T1 to Rorden
    fid_m=fopen(str_t1);
    count=1;
    str=[];
    while ~feof(fid_m)
          tline = fgetl(fid_m);
          str{count}=tline;
          count=count+1;
    end
    fclose(fid_m);   
    
    for k=1:(count-1)
        str{k}=strrep(str{k},str_no,str_Rorden);
    end
    
    for k=1:(count-1)        
        str{k}=strrep(str{k},strcat(Dir,'\T1_to_SC\TransformParameters.1.txt'),str_Rorden);
    end
    fid_m = fopen(str_t1,'wt');
    for k=1:(count-1)
        fprintf(fid_m, '%s\n', str{k});
    end
    fclose(fid_m);
    % Rewrite T1_to_SC for the current directory
    fid_m=fopen(str_Rorden);
    count=1;
    str=[];
    while ~feof(fid_m)
          tline = fgetl(fid_m);
          str{count}=tline;
          count=count+1;
    end
    fclose(fid_m);    
 
    for k=1:(count-1)        
        str{k}=strrep(str{k},strcat(Dir,'\T1_to_SC\TransformParameters.0.txt'),dir_Rorden);
    end
    fid_m = fopen(str_Rorden,'wt');
    for k=1:(count-1)
        fprintf(fid_m, '%s\n', str{k});
    end
    fclose(fid_m);

    % Rewrite T1_to_Rorden transformation file with initial registration of Rorden to MNI152
    fid_m=fopen(dir_Rorden);
    count=1;
    str=[];
    while ~feof(fid_m)
          tline = fgetl(fid_m);
          str{count}=tline;
          count=count+1;
    end
    fclose(fid_m);    
    
    for k=1:(count-1)
        str{k}=strrep(str{k},str_no,str_MNI);
    end
    fid_m = fopen(dir_Rorden,'wt');
    for k=1:(count-1)
        fprintf(fid_m, '%s\n', str{k});
    end
    fclose(fid_m);
    
    % Rewrite SC_to_MNI.txt to match the current directory
    fid_m=fopen(str_MNI);
    count=1;
    str=[];
    while ~feof(fid_m)
          tline = fgetl(fid_m);
          str{count}=tline;
          count=count+1;
    end
    fclose(fid_m);    
    
    for k=1:(count-1)
        str{k}=strrep(str{k},'SC_to_MNI.1.txt',dir_MNI);
    end
    fid_m = fopen(str_MNI,'wt');
    for k=1:(count-1)
        fprintf(fid_m, '%s\n', str{k});
    end
    fclose(fid_m);
%% Write transformix command to map source image and lesion to MNI space
fid = fopen(strcat(Dir,'\batch\transformix_to_MNI.bat'),'wt');
mkdir(strcat(Dir,'\to_MNI'),'lesion');
CMD_to_MNI=['"',Dir_code,'\Elastix\transformix.exe' '"' ' -in' blanks(1) '"' DWI '"' blanks(1) '-out' blanks(1) '"' strcat(Dir,'\to_MNI') '"' blanks(1) '-tp ' blanks(1) '"' strcat(Dir,'\to_MNI\to_MNI.txt') '"'];
fprintf(fid, '%s\n', CMD_to_MNI);
CMD_to_MNI_lesion=['"',Dir_code,'\Elastix\transformix.exe' '"' ' -in' blanks(1) '"' LESION '"' blanks(1) '-out' blanks(1) '"' strcat(Dir,'\to_MNI\lesion') '"' blanks(1) '-tp ' blanks(1) '"' strcat(Dir,'\to_MNI\to_MNI_lesion.txt') '"'];
fprintf(fid, '%s\n', CMD_to_MNI_lesion);
fclose(fid);
winopen(strcat(Dir,'\batch\transformix_to_MNI.bat'));
    