function sub_record=test_FLAIR_no_T1(Dir_code,Dir_img,mode,record)
%% Initialization 
    sub_record=cell(1,2);

    % Check if the input images are sufficient to perform the specified
    % registration scheme
    Img=cell(length(Dir_img),1);    
    for i=1:length(Dir_img)
        id=strfind(Dir_img{i},'\');        
        Img{i}=Dir_img{i}((id(end)+1):end);
    end
    flair=0;lesion=0; 
    for i=1:length(Dir_img)
        if ~isempty(strfind(Img{i},'lesion'))&&(~isempty(strfind(Img{i},'FLAIR'))||~isempty(strfind(Img{i},'T2')))
            lesion=lesion+1;
            LESION_org=Dir_img{i};
            % Check if the nii image is 4D and make conversion to 3D if applicable 
            % (the first image of 4D nii would be used by default )   
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
            flair=flair+1;
            FLAIR=Dir_img{i};
            % Check if the nii image is 4D and make conversion to 3D if applicable 
            % (the first image of 4D nii would be used by default )   
            convt_img=convert_nii_4D_to_3D(FLAIR);            
            if isempty(convt_img)
                sub_record{2}=FLAIR;
            else
                FLAIR=convt_img;
                sub_record{2}=FLAIR;
            end
            break;
          elseif (~isempty(strfind(Img{i},'FLAIR'))||~isempty(strfind(Img{i},'T2')))&&isempty(strfind(Img{i}(1:(end-4)),'lesion'))
            warning('The name of lesion mask does not match source image: the source image is selected randomly!');
            flair=flair+1;
            FLAIR=Dir_img{i};
            % Check if the nii image is 4D and make conversion to 3D if applicable 
            % (the first image of 4D nii would be used by default )   
            convt_img=convert_nii_4D_to_3D(FLAIR);            
            if isempty(convt_img)
                sub_record{2}=FLAIR;
            else
                FLAIR=convt_img;
                sub_record{2}=FLAIR;
            end
          end
        end
    end    
    
    if flair<1&&isempty(record)
        errordlg('FLAIR/T2 image not found');
        return;
    elseif flair<1&&~isempty(record)
        sub_record{2}='0';
        return;
    end
    % Specify parameter files for registration
    if isempty(mode)
       reg_FLAIR_Rorden=['-p ',blanks(1),'"',Dir_code,'\Parameter\affine.txt','"',' -p ',blanks(1),'"',Dir_code,'\Parameter\bspline.txt','"'];
    else 
       reg_FLAIR_Rorden=['-p ',blanks(1),'"',Dir_code,'\Parameter\affine.txt','"',' -p ',blanks(1),'"',Dir_code,'\Parameter\bspline_CR.txt','"'];
    end
    
    % Specify the location of intermediate Rorden template
    SC=strcat(Dir_code,'\Template\sct1_unsmooth.nii');
    
%     % Generate directories for temporary results
    id=strfind(Dir_img{1},'\');
    Dir=Dir_img{1}(1:(id(end)-1));
    mkdir(Dir,'batch');
    mkdir(Dir,'FLAIR_to_SC');
    mkdir(Dir,'to_MNI');
      
    
%% Writing elastix command for registration
    fid = fopen(strcat(Dir,'\batch\elastix_FLAIR_SC.bat'),'wt');
    CMD_FLAIR_Rorden = ['"' Dir_code,'\Elastix\elastix.exe' '"' ' -f' blanks(1) '"' SC '"' blanks(1) '-m' blanks(1) '"' FLAIR '"' blanks(1) reg_FLAIR_Rorden blanks(1) '-out' blanks(1) '"' strcat(Dir,'\FLAIR_to_SC') '"'];
    fprintf(fid, '%s\n', CMD_FLAIR_Rorden);
    fclose(fid);
    winopen(strcat(Dir,'\batch\elastix_FLAIR_SC.bat'));
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

disp('registration from FLAIR to SC is done.');
%% Rewrite transformation files for final transformation of source image and lesion
dir_para=strcat(Dir_code,'\Parameter\');
dir_tar=strcat(Dir,'\to_MNI\');
para_name={'to_MNI.txt';'to_MNI_lesion.txt';'SC_to_MNI.txt';'SC_to_MNI.1.txt';...
           'TransformParameters.1.txt';'TransformParameters.0.txt';'FLAIR_to_SC.txt';'FLAIR_to_SC.1.txt';};
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
    
    FLAIR_to_SC=strcat(Dir,'\FLAIR_to_SC\TransformParameters.1.txt');
    if exist(FLAIR_to_SC,'file')
        copyfile(FLAIR_to_SC,dir_tar);
        movefile(strcat(dir_tar,'TransformParameters.1.txt'),strcat(dir_tar,'FLAIR_to_SC.txt'));
    else 
        errordlg('Registration failed from FLAIR to MNI!');
    end
    str_Rorden=strcat(dir_tar,'FLAIR_to_SC.txt');
     
    
    FLAIR_to_SC_1=strcat(Dir,'\FLAIR_to_SC\TransformParameters.0.txt');
    copyfile(FLAIR_to_SC_1,dir_tar);
    movefile(strcat(dir_tar,'TransformParameters.0.txt'),strcat(dir_tar,'FLAIR_to_SC.1.txt'));

    
    
    dir_init=strcat(dir_tar,'to_MNI.txt');
    dir_init_lesion=strcat(dir_tar,'to_MNI_lesion.txt');
    
    dir_Rorden=strcat(dir_tar,'FLAIR_to_SC.1.txt');
    str_MNI=strcat(dir_tar,'SC_to_MNI.txt');
    dir_MNI=strcat(dir_tar,'SC_to_MNI.1.txt');
    % Rewrite to_MNI.txt for FLAIR image
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
        
    % Rewrite FLAIR_to_SC for the current directory
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
        str{k}=strrep(str{k},strcat(Dir,'\FLAIR_to_SC\TransformParameters.0.txt'),dir_Rorden);
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
CMD_to_MNI=['"',Dir_code,'\Elastix\transformix.exe' '"' ' -in' blanks(1) '"' FLAIR '"' blanks(1) '-out' blanks(1) '"' strcat(Dir,'\to_MNI') '"' blanks(1) '-tp ' blanks(1) '"' strcat(Dir,'\to_MNI\to_MNI.txt') '"'];
fprintf(fid, '%s\n', CMD_to_MNI);
CMD_to_MNI_lesion=['"',Dir_code,'\Elastix\transformix.exe' '"' ' -in' blanks(1) '"' LESION '"' blanks(1) '-out' blanks(1) '"' strcat(Dir,'\to_MNI\lesion') '"' blanks(1) '-tp ' blanks(1) '"' strcat(Dir,'\to_MNI\to_MNI_lesion.txt') '"'];
fprintf(fid, '%s\n', CMD_to_MNI_lesion);
fclose(fid);
winopen(strcat(Dir,'\batch\transformix_to_MNI.bat'));