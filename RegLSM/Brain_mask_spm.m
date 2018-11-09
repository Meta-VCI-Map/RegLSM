function [img_brain,dir_c1,dir_c2,dir_c3,dir_c4,dir_c5]=Brain_mask_spm(Dir_img)
id1=strfind(Dir_img,'\');
Dir=Dir_img(1:(id1(end)-1));
id2=strfind(Dir_img,'.nii');
img_name=Dir_img((id1(end)+1):(id2(end)-1));
dir_c1=strcat(Dir,'\c1',img_name,'.nii');
dir_c2=strcat(Dir,'\c2',img_name,'.nii');
dir_c3=strcat(Dir,'\c3',img_name,'.nii');
dir_c4=strcat(Dir,'\c4',img_name,'.nii');
dir_c5=strcat(Dir,'\c5',img_name,'.nii');

if exist(dir_c1,'file')
    c1_nii=load_untouch_nii(dir_c1);
else
    errordlg('SPM segmentation not finished!');
    return;
end
img1=c1_nii.img;

if exist(dir_c2,'file')
    c2_nii=load_untouch_nii(dir_c2);
else
    errordlg('SPM segmentation not finished!');
    return;
end
img2=c2_nii.img;

if exist(dir_c3,'file')
    c3_nii=load_untouch_nii(dir_c3);
else
    errordlg('SPM segmentation not finished!');
    return;
end
img3=c3_nii.img;

if ~exist(dir_c4,'file')
    errordlg('SPM segmentation not finished!');
    return;
end
if ~exist(dir_c5,'file')
    errordlg('SPM segmentation not finished!');
    return;
end

nii=load_untouch_nii(strcat(Dir,'\',img_name,'.nii'));
img=nii.img;
mask=img1+img2+img3;
for j=1:size(mask,3)
    mask(:,:,j)=imclose(mask(:,:,j),strel('disk',5));
end
t=find(mask>0);
I=zeros(size(mask));
I(t)=img(t);
nii.img=I;
img_brain=strcat(Dir,'\',img_name,'_brain_spm.nii');
save_untouch_nii(nii,img_brain);
end