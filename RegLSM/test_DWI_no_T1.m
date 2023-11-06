function sub_record=test_DWI_no_T1(Dir_code,Dir_img,record,copyLesionGeometry)
%% Initialization 
    sub_record=cell(1,2);   

% Check if the input images is sufficient to perform the specified
    % registration scheme
    Img=cell(length(Dir_img),1);    
    for i=1:length(Dir_img)
        id=strfind(Dir_img{i},'\');        
        Img{i}=Dir_img{i}((id(end)+1):end);
    end
    dwi=0;lesion=0; % Image counters
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
        end
    end
    if lesion<1&&isempty(record)
        errordlg('Lesion segmentation not found!');
        return;
    elseif lesion<1&&~isempty(record)
        sub_record{1}=num2str(lesion);
        return;  
    else 
        for i=1:length(Dir_img)
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
    if  dwi<1&&isempty(record)
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
    reg_DWI_Rorden=['-p ',blanks(1),'"',Dir_code,'\Parameter\affine.txt','"',' -p ',blanks(1),'"',Dir_code,'\Parameter\bspline.txt','"'];
    
    % Specify the location of intermediate Rorden template
    SC=strcat(Dir_code,'\Template\betsct1_unsmooth.nii');      
   
%     % Generate directories for temporary results
    id=strfind(Dir_img{1},'\');
    Dir=Dir_img{1}(1:(id(end)-1));
    mkdir(Dir,'batch');
    mkdir(Dir,'DWI_to_SC');
    mkdir(Dir,'to_MNI');
%% Brain extraction for DWI
if isempty(strfind(DWI,'brain'))
    spm_jobman('initcfg'); 
    spm('defaults', 'FMRI');
    matlabbatch=spm_seg(DWI,Dir_code);
    spm_jobman('serial', matlabbatch);
    mkdir(Dir,'SPM_segmentation');
    [DWI_brain,dir_c1,dir_c2,dir_c3,dir_c4,dir_c5]=Brain_mask_spm(DWI);
    dir_spm_seg=strcat(Dir,'\SPM_segmentation\');
    movefile(dir_c1,dir_spm_seg);
    movefile(dir_c2,dir_spm_seg);
    movefile(dir_c3,dir_spm_seg);
    movefile(dir_c4,dir_spm_seg);
    movefile(dir_c5,dir_spm_seg);
else
    DWI_brain=DWI;
end

%% Writing elastix command for registration
    fid = fopen(strcat(Dir,'\batch\elastix_DWI_SC.bat'),'wt');
    CMD_DWI_Rorden = ['"',Dir_code,'\Elastix\elastix.exe' '"' ' -f' blanks(1) '"' SC '"' blanks(1) '-m' blanks(1) '"' DWI_brain '"' blanks(1) reg_DWI_Rorden blanks(1) '-out' blanks(1) '"' strcat(Dir,'\DWI_to_SC') '"'];
    fprintf(fid, '%s\n', CMD_DWI_Rorden);
    fclose(fid);
    winopen(strcat(Dir,'\batch\elastix_DWI_SC.bat'));
    disp('MATLAB continues after calling elastix.exe')
%     
%% Wait until the registration is finished
flag = true;
disp('elastix.exe still running...'); 
pause(5) % wait to start
maxruntime = 60 * 15; % 15 minutes, then we continue anyway, because elastix probably crashed
runningtime = 0;
while flag && runningtime < maxruntime     
     flag = isprocess('elastix.exe'); % isprocess is the function attached. Place it on the MATLAB path.
     pause(1) % check every 1 second
     runningtime = runningtime + 1;
end

if runningtime >= maxruntime
  [~,~,c] = isprocess('elastix.exe');
  system(strjoin({'taskkill /F /PID', num2str(c{1})})) ;
  throw(MException('elastix', 'elastix has crashed and was force-closed'));
end
disp('registration from DWI to SC is Done');
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
    
    DWI_to_SC=strcat(Dir,'\DWI_to_SC\TransformParameters.1.txt');
    if exist(DWI_to_SC,'file')
        copyfile(DWI_to_SC,dir_tar);
        movefile(strcat(dir_tar,'TransformParameters.1.txt'),strcat(dir_tar,'DWI_to_SC.txt'));
    else 
        errordlg('Registration failed from DWI to MNI!');
    end
    str_Rorden=strcat(dir_tar,'DWI_to_SC.txt');
     
    
    DWI_to_SC_1=strcat(Dir,'\DWI_to_SC\TransformParameters.0.txt');
    copyfile(DWI_to_SC_1,dir_tar);
    movefile(strcat(dir_tar,'TransformParameters.0.txt'),strcat(dir_tar,'DWI_to_SC.1.txt'));

    
    
    dir_init=strcat(dir_tar,'to_MNI.txt');
    dir_init_lesion=strcat(dir_tar,'to_MNI_lesion.txt');
    
    dir_Rorden=strcat(dir_tar,'DWI_to_SC.1.txt');
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
        str{k}=strrep(str{k},str_no,str_Rorden);
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
        str{k}=strrep(str{k},str_no,str_Rorden);
    end
    fid_m = fopen(dir_init_lesion,'wt');
    for k=1:(count-1)
        fprintf(fid_m, '%s\n', str{k});
    end
    fclose(fid_m);
        
    % Rewrite DWI_to_SC for the current directory
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
        str{k}=strrep(str{k},strcat(Dir,'\DWI_to_SC\TransformParameters.0.txt'),dir_Rorden);
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
CMD_to_MNI=['"',Dir_code,'\Elastix\transformix.exe' '"' ' -in' blanks(1) '"' DWI_brain '"' blanks(1) '-out' blanks(1) '"' strcat(Dir,'\to_MNI') '"' blanks(1) '-tp ' blanks(1) '"' strcat(Dir,'\to_MNI\to_MNI.txt') '"'];
fprintf(fid, '%s\n', CMD_to_MNI);
CMD_to_MNI_lesion=['"',Dir_code,'\Elastix\transformix.exe' '"' ' -in' blanks(1) '"' LESION '"' blanks(1) '-out' blanks(1) '"' strcat(Dir,'\to_MNI\lesion') '"' blanks(1) '-tp ' blanks(1) '"' strcat(Dir,'\to_MNI\to_MNI_lesion.txt') '"'];
fprintf(fid, '%s\n', CMD_to_MNI_lesion);
fclose(fid);
winopen(strcat(Dir,'\batch\transformix_to_MNI.bat'));