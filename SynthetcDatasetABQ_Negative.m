%% Reads single image from ABQ dataset and generetes 30 images of size 720x480 with only translation only
%% objective is to prepare a groundtruth dataset for Mesentery or frames with only translation

clc;
clear all;
warning off;



dirname='/Volumes/E/ABQ_all/ABQ';
dirnameOut='/Volumes/F/Courses/MesenteryData/ABQ_Synthetic_Negative/';
if (~isdir(dirnameOut))
    mkdir(dirnameOut);
end


%check if you have enough images
files = dir(fullfile(dirname,'D*.jpg'));
if( size(files,1) < 2 );     disp('at least two images with appropriate format in the directory');    return; end;% 
I1 = imread(fullfile(dirname, files(1).name)); [M,N,~]=size(I1);
I_out=I1;

xy=[];

m=480; n=720; no_Frames=50; bw=2; %border width

clist=colormap(jet(no_Frames));
clist=clist*255;

x1=bw+1000; y1=bw+1000; xx1=x1; yy1=y1;

for i=1:no_Frames
    i
    x2=x1+n-1;
    y2=y1+m-1;
    croppedI=I1(y1:y2, x1:x2, :);
    xy=[xy; x1 y1];
    
    I_out(y1-bw:y1+bw, x1:x2, 1)=clist(i,1);
    I_out(y2-bw:y2+bw, x1:x2, 1)=clist(i,1);
    I_out(y1:y2, x1-bw:x1+bw, 1)=clist(i,1);
    I_out(y1:y2, x2-bw:x2+bw, 1)=clist(i,1);
    
    I_out(y1-bw:y1+bw, x1:x2, 2)=clist(i,2);
    I_out(y2-bw:y2+bw, x1:x2, 2)=clist(i,2);
    I_out(y1:y2, x1-bw:x1+bw, 2)=clist(i,2);
    I_out(y1:y2, x2-bw:x2+bw, 2)=clist(i,2);
    
    I_out(y1-bw:y1+bw, x1:x2, 3)=clist(i,3);
    I_out(y2-bw:y2+bw, x1:x2, 3)=clist(i,3);
    I_out(y1:y2, x1-bw:x1+bw, 3)=clist(i,3);
    I_out(y1:y2, x2-bw:x2+bw, 3)=clist(i,3);
    %imshow(uint8(I_out));

    
    %% write cropped image
    fname=sprintf('Frame_%06d.png', i-1);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(croppedI,fname_wpath); 
    
    cut=0;
    while cut~=1
        [shift] = randi([-100 50],1,2); shiftX=shift(1);shiftY=shift(2);
        if x1+shiftX>=1 && x1+shiftX<=N &&  y1+shiftY>=1 && y1+shiftY<=M
            x1=x1+shiftX; y1=y1+shiftY;
            cut=1;
        end
    end
end

%% save original coordinate on BIG ABQ image
dlmwrite(sprintf('%sxy_original_on_Image.txt',dirnameOut), xy);
fname=sprintf('ABQ.png');
fname_wpath=fullfile(dirnameOut,fname);
imwrite(I_out,fname_wpath); 

%% save global coordinate among selected/generated images only
X=xy(:, 1); Y=xy(:, 2);
minX=min(X); minY=min(Y(:));
XX=zeros(size(X)); YY=XX;
XX(:)=-minX+1; YY(:)=-minY+1;
xy(:,1)=xy(:,1)+XX; 
xy(:,2)=xy(:,2)+YY; 
dlmwrite(sprintf('%sxy.txt',dirnameOut), xy);

    
