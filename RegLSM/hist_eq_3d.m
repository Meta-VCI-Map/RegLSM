function hist_eq_3d(dir_ct,dir_ct_histeq)
ct=load_untouch_nii(dir_ct);
img_ct=ct.img;
v_img=img_ct(:);
n_pix=length(v_img);
n_intensity=unique(v_img);
n_pix_intensity=zeros(length(n_intensity),1);
Pn=n_pix_intensity;
intensity_pix_id=cell(length(n_intensity),1);
% calculating Pn
for i=1:length(n_intensity)
    clc;
    fprintf('Histogram equalization \n Step 1: Calculating Pn for every existing intensity: %f/%d ', i/length(n_intensity)*100,100);
    temp=find(v_img==n_intensity(i));
    intensity_pix_id{i}=temp;
    n_pix_intensity(i)=length(temp);
    Pn(i)=double(n_pix_intensity(i))/n_pix;
end
% Calculating normalized intensities for every pixel
for i=1:length(n_intensity)
    clc;
    fprintf('Histogram equalization \n Step 2: calculating normalized image by every existing intensity: %f/%d \n', i/length(n_intensity)*100,100);
    index=intensity_pix_id{i};
    pix_histeq=sum(Pn(1:i));
 
    P_hist_eq=pix_histeq*(max(n_intensity)-min(n_intensity))+min(n_intensity);
    v_img(index)=ones(length(index),1)*double(P_hist_eq);
end
img_out=img_ct;
img_out(:)=v_img;
ct.img=img_out;
save_untouch_nii(ct,dir_ct_histeq);
end





