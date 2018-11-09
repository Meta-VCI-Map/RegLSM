function convt_img=convert_nii_4D_to_3D(dir_img)
convt_img=[];
id=strfind(dir_img,'\');
folder=dir_img(1:(id(end)-1));
Image=dir_img((id(end)+1):end);

temp=load_untouch_nii(strcat(folder,'\',Image));
if temp.hdr.dime.dim(6)>1
   nii=load_untouch_nii(strcat(folder,'\',Image));
   img=nii.img;
   n=nii.hdr.dime.dim(6);
   nii.hdr.dime.dim(6)=1;
   nii.hdr.dime.pixdim(5:8)=zeros(1,4);
   for j=1:n
       im=img(:,:,:,:,j);
       nii.img=im;
       save_untouch_nii(nii,strcat(folder,'\',Image(1:(end-4)),'_',num2str(j),'.nii'));
   end
   convt_img=strcat(folder,'\',Image(1:(end-4)),'_',num2str(1),'.nii');
end



        
