clc;
clear all
close all

shot=3;

inputpath1='/Volumes/F/Courses/MesenteryData/SmallFragment_Mesentery_2/NCC_ADD/MosaicL';

outputpath=sprintf('%s_RGB',inputpath1);

%outputpath=inputpath1;
%%%%-------------------------------------
if (~isdir(outputpath))
    mkdir(outputpath);
end

flist1=dir(fullfile(inputpath1,'*.png')); 
nn=length(flist1);

image1=imread(fullfile(inputpath1,flist1(1).name));
image2=imread(fullfile(inputpath1,flist1(2).name));
image3=imread(fullfile(inputpath1,flist1(3).name));

sum_diff=zeros(size(image1));
%%%%%%%%%%%%%make loop for all images
for fr=4:nn
    fr
    RGB=zeros(size(image1));
    RGB(:,:,1)=image1(:,:,1);
    RGB(:,:,2)=image2(:,:,2);
    RGB(:,:,3)=image3(:,:,3);
    
    difference_image=abs(uint8(RGB)-image3);
    fname=sprintf('%s%s','RGB',flist1(fr).name);
    fname_wpath=fullfile(outputpath,fname);
    imwrite(uint8(RGB), fname_wpath);
    
%     difference_image=abs(uint8(RGB)-image3);
%     fname=sprintf('%s%s','RGB_difference',flist1(fr).name);
%     fname_wpath=fullfile(outputpath,fname);
%     imwrite(uint8(difference_image), fname_wpath);
    
    sum_diff=uint8(sum_diff)+difference_image;
    xx=sum_diff/(nn-3);
    
    
    
    %prepare for next image 
    image1=image2;
    image2=image3;
    image3=imread(fullfile(inputpath1,flist1(fr).name));
    
%     if mod(fr,30) ==0
%         fname=sprintf('%s%s','xx_',flist1(fr).name);
%         fname_wpath=fullfile(outputpath,fname);
%         imwrite(uint8(sum_diff), fname_wpath);      
%         sum_diff=zeros(size(image3));
%     end
    
 
end
    
    





