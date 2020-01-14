clc; clear all; warning off;
dir='/Volumes/F/Courses/MesenteryData/Sequence5_fr6_cropped/NCC_100_200_150x200/Fr/';
%template=imread(sprintf('%sBlck.png', dir));
I1=imread(sprintf('%sFrames_000213.png', dir));
I2=imread(sprintf('%sFrames_000214.png', dir));


template_row_start=100;
template_col_start=200;

% template_col_start=100;
% template_row_start=100;

template=I2(template_row_start:template_row_start+150, template_col_start:template_col_start+200, :);
I3=I2;
I3(template_row_start-1:template_row_start+1, template_col_start:template_col_start+200, 1)=255;
I3(template_row_start+150-1:template_row_start+150+1, template_col_start:template_col_start+200, 1)=255;
I3(template_row_start:template_row_start+150, template_col_start-1:template_col_start+1, 1)=255;
I3(template_row_start:template_row_start+150, template_col_start+200-1:template_col_start+200+1, 1)=255;

imshow(uint8(I3));


c = normxcorr2(template(:,:,1),I1(:,:,1));%figure, surf(c), shading flat    
[max_c, imax] = max(abs(c(:)));
[ypeak, xpeak] = ind2sub(size(c),imax(1));
corr_offset = [(xpeak-size(template,2)+1) 
           (ypeak-size(template,1)+1)]
       
       
xbeginFrame=round(corr_offset(1)) - template_col_start+1
ybeginFrame=round(corr_offset(2)) - template_row_start+1
                   
       
m=corr_offset(2);
n=corr_offset(1);
       
mat=c(size(template,1):end, size(template,2):end);
imshow(uint8(mat*255))


I1(m-1:m+1, n:n+size(template,2)-1, 1)=255;
I1(m+size(template,1)-1:m+size(template,1)+1, n:n+size(template,2)-1, 1)=255;

I1(m:m+size(template,1)-1, n-1:n+1, 1)=255;
I1(m:m+size(template,1)-1, n+size(template,2)-1:n+size(template,2)+1, 1)=255;


% I1(template_row_start+size(template,1)-1: template_row_start+size(template,1)+1, template_col_start:template_col_start+size(template,2)-1, 1)=255;
% 
% I1(template_row_start:template_row_start+size(template,1)-1, template_col_start+size(template,2)-1: template_col_start+size(template,2)+1, 1)=255;
% I1(template_row_start:template_row_start+size(template,1)-1, template_col_start-1: template_col_start+1, 1)=255;

imshow(uint8(I1))
imwrite(uint8(I1), sprintf('%sTemplate_I1.png',dir));

imwrite(uint8(I3), sprintf('%stemplate_I2.png',dir));

imwrite(uint8(mat*255), sprintf('%sMat.png',dir));
imwrite(uint8(template), sprintf('%sTemplate.png',dir));

Iout=zeros(1000, 2000, 3);
Iout(1:size(I1,1), 1:size(I1,2), :)=I1;
Iout(ybeginFrame:ybeginFrame+size(I1,1)-1, xbeginFrame:xbeginFrame+size(I1,2)-1, :)=I2;
imwrite(uint8(Iout), sprintf('%sMosaic.png',dir));


