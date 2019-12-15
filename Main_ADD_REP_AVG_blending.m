clc;
clear all
close all

shot=1;
start=501; %1, 209, 230, 281
last=600; %209, 230, 281, 338
padding=1500; %standard 400

% inputpath=sprintf('F:/Courses/BioMedicalImageProcessing/Project/Input/shot%d',shot);
% image1= double(imread(sprintf('%s/Frame_0%d.png', inputpath,start)));
% image2 = double(imread(sprintf('%s/Frame_0%d.png',inputpath, start+1)));
% outputpath=sprintf('F:/Courses/BioMedicalImageProcessing/Project/Final_output/Fail_case/shot%d_from_%d',3,start);

% outputpath_ADD=sprintf('F:/Courses/BioMedicalImageProcessing/Project/Final_output/Test_case/shot%d_from_%d/ADD',3,start);
% outputpath_REP=sprintf('F:/Courses/BioMedicalImageProcessing/Project/Final_output/Test_case/shot%d_from_%d/REP',3,start);
% outputpath_AVG=sprintf('F:/Courses/BioMedicalImageProcessing/Project/Final_output/Test_case/shot%d_from_%d/AVG',3,start);
% outputpath_AVG_of_ADD_REP=sprintf('F:/Courses/BioMedicalImageProcessing/Project/Final_output/Test_case/shot%d_from_%d/AVG_of_ADD_REP',3,start);


inputpath=sprintf('/Volumes/D/Masentry/Sequence5_fr5');
image1= double(imread(sprintf('%s/Frames_%06d.png', inputpath,start)));
image2 = double(imread(sprintf('%s/Frames_%06d.png',inputpath, start+1)));
outputpath=sprintf('/Volumes/F/Courses/MesenteryData/SFM2_BIP_Output/');


outputpath_ADD=sprintf('%s/ADD',outputpath);
outputpath_REP=sprintf('%s/REP',outputpath);
outputpath_AVG=sprintf('%s/AVG',outputpath);
outputpath_AVG_of_ADD_REP=sprintf('%s/ADD_REF_AVG',outputpath);

%%%%-------------------------------------
if (~isdir(outputpath))
    mkdir(outputpath);
end
if (~isdir(outputpath_ADD))
    mkdir(outputpath_ADD);
end
if (~isdir(outputpath_REP))
    mkdir(outputpath_REP);
end
if (~isdir(outputpath_AVG))
    mkdir(outputpath_AVG);
end
if (~isdir(outputpath_AVG_of_ADD_REP))
    mkdir(outputpath_AVG_of_ADD_REP);
end

[m,n,~]=size(image1);
crop_row=17;
crop_col=5;


image1=image1(crop_row:m-crop_row, crop_col:n-crop_col, :);
image2=image2(crop_row:m-crop_row, crop_col:n-crop_col, :);
[m,n,~]=size(image1);


mosaic=zeros(m+2*padding, n+2*padding, 3);
current_mask=zeros(m+2*padding, n+2*padding);
mosaic(padding+1:m+padding, padding+1:n+padding, :)=image1;
rep_mosaic=mosaic;
avg_mosaic=mosaic;
current_mask(padding+1:m+padding, padding+1:n+padding)=1;
prev_mask=current_mask;

first_frame=mosaic;
first_mask=current_mask;

avg_of_ADD_REP=mosaic;


%figure, imshow([uint8(image1) uint8(image2)])

start_template_row=50; start_template_col=50;
template_row=100; template_col=100;




flist=dir(fullfile(inputpath,'*.png')); 
nn=length(flist);
avg_mosaic_final=mosaic;
%%%%%%%%%%%%%make loop for all images
for fr=start+1:last
    
    
    if fr==start+1
        prev_mosaic2=rep_mosaic;
    end
    fr
    image2=imread(fullfile(inputpath,flist(fr).name));
    [m,n,~]=size(image2);
    image2=image2(crop_row:m-crop_row, crop_col:n-crop_col, :);
    [m,n,~]=size(image2);
    
    %%%start loop
    %template=image2(1:template_row, 1:template_col, :);
    template=image2(start_template_row+1:start_template_row+template_row, start_template_col+1:start_template_col+template_col, :);

    %figure, imshow(uint8(mosaic));
    %figure, imshow(uint8(template));

    c = normxcorr2(template(:,:,1),mosaic(:,:,1));
    %figure, surf(c), shading flat

    % offset found by correlation
    [max_c, imax] = max(abs(c(:)));
    [ypeak, xpeak] = ind2sub(size(c),imax(1));
    corr_offset = [(xpeak-size(template,2)) 
                   (ypeak-size(template,1))]

    xbegin=round(corr_offset(1)+ 1) - start_template_col
    ybegin=round(corr_offset(2)+ 1) - start_template_row 

    %update current mask by adding the pixels from second image
    current_mask(ybegin:ybegin+m-1, xbegin:xbegin+n-1)=1;
    %new mask pixels
    difference_mask=current_mask-prev_mask;
    
  %  imshow(uint8(current_mask*255));
    common_mask=current_mask-difference_mask;
    
    prev_mask=current_mask;    
    temp_image=zeros(size(mosaic));
    temp_image(ybegin:ybegin+m-1, xbegin:xbegin+n-1, :)=image2;
    rep_mosaic(ybegin:ybegin+m-1, xbegin:xbegin+n-1, :)=image2;
    avg_mosaic=rep_mosaic;

    %figure, imshow(mosaic)
    %figure, imshow(difference_mask)
    for i=1:size(mosaic,1)
        for j=1:size(mosaic,2)
            if difference_mask(i,j)==1
                mosaic(i,j,:)=temp_image(i,j,:);
            end
            if common_mask(i,j)==1
                avg_mosaic(i,j,:)=(mosaic(i,j,:)+rep_mosaic(i,j,:))/2;
            end
        end
    end
    
    if fr==start+1
        prev_mosaic1=rep_mosaic;
    end
    if fr>=start+2
        RGB=zeros(size(mosaic));
        RGB(:,:,1)=prev_mosaic2(:,:,1);
        RGB(:,:,2)=prev_mosaic1(:,:,2);
        RGB(:,:,3)=rep_mosaic(:,:,3);
        
        prev_mosaic2=prev_mosaic1;
        prev_mosaic1=rep_mosaic;
        
         %save the EvalutionRGB
         RGB_1=imresize(RGB,2);
         fname=sprintf('%s%s','Rep_RGB_',flist(fr).name);
         fname_wpath=fullfile(outputpath,fname);
         imwrite(uint8(RGB_1), fname_wpath);
    end
    
     %average of mosaic from addition and replacement method
     avg_of_ADD_REP=(rep_mosaic+mosaic)/2;
    
    
     %save the mosaics
     ms=imresize(mosaic,2);
     fname=sprintf('%s%s','Mosaic_',flist(fr).name);
     fname_wpath=fullfile(outputpath_ADD,fname);
     imwrite(uint8(ms), fname_wpath);
     
     rep_ms=imresize(rep_mosaic,2);
     fname=sprintf('%s%s','Rep_Mosaic_',flist(fr).name);
     fname_wpath=fullfile(outputpath_REP,fname);
     imwrite(uint8(rep_ms), fname_wpath);
     
%      avg_ms=imresize(avg_mosaic,2);
%      fname=sprintf('%s%s','AVG_Mosaic_',flist(fr).name);
%      fname_wpath=fullfile(outputpath_AVG,fname);
%      imwrite(uint8(avg_ms), fname_wpath);
%      
%      
%      
%      avg_ms=imresize(avg_of_ADD_REP,2);
%      fname=sprintf('%s%s','avg_of_ADD_REP',flist(fr).name);
%      fname_wpath=fullfile(outputpath_AVG_of_ADD_REP,fname);
%      imwrite(uint8(avg_ms), fname_wpath);    
   
 
end

% %no need
%  last_mask=zeros(size(first_mask));
%  last_mask(ybegin:ybegin+m-1, xbegin:xbegin+n-1, :)=1;
% 
%  %no need
%  for i=1:size(mosaic,1)
%         for j=1:size(mosaic,2)
%             if first_mask(i,j)==1
%                 rep_mosaic(i,j,:)=first_frame(i,j,:);
%             end
%             if last_mask(i,j)==1
%                 mosaic(i,j,:)=temp_image(i,j,:);
%             end
%         end
%  end
%     
%  
%  %no need
%  ms=imresize(rep_mosaic,2);
%  fname=sprintf('%s%s','First_add_Mosaic_',flist(fr).name);
%  fname_wpath=fullfile(outputpath,fname);
%  imwrite(uint8(ms), fname_wpath);   
%  
%  ms=imresize(mosaic,2);
%  fname=sprintf('%s%s','Last_add_Mosaic_',flist(fr).name);
%  fname_wpath=fullfile(outputpath,fname);
%  imwrite(uint8(ms), fname_wpath);   
%  
% 




