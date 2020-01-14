%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Main: TranslationalMosaicModel_NCC_Feature.m
%-- Author: Rumana Aktar, 12/5/19
%--------------------------------------------------------------------------
%-- input: Sequence of images with translation motion only
%-- input: NCC (flag): if NCC == 1, then NCC based method, otherwise
%feature matching+feature distance method
%-- input: saved_matched_Points==1 shows matched feature for
%feature+distance based method
%-- output: mosaic, mask, iMosaics at local coordinate system, xy location of iMosaics or masks in Global coordinate system
%-- output: ADDITION blending when ADD is set to 1 and AVERAGE blending when AVG is set to 1
%--------------------------------------------------------------------------
%-- A Traslational model for mosaicing images with pure translation: for both positive and negative motion
%-- It produces pixel replacement blending
%-- It produces pixel addition blending
%-- It produces average blending
%-- It can hadle motiton along any direction: POSITIVE/NEGATIVE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------- Timing ----------------------------------
% NCC = 0.0762 sec/frame % Feature = 0.2926 sec/frame for SmallFragment_Mesentery
% NCC = 0.0860 sec/frame % Feature = 0.8717 sec/frame for SmallFragment_Mesentery_2
% NCC = 0.1615 sec/frame % Feature = 0.1675 sec/frame for  ABQ_Synthetic
% NCC = 0.1169 sec/frame % Feature = 0.1314 sec/frame for ABQ_Synthetic_Negative imsize: 480x720
% NCC = 0.1229 sec/frame % Feature = 0.2936 sec/frame for sequence5, imsize: 480x720
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

clc;
clear all;
warning off;

tic;

%% pick a model
NCC = 0; %%1==NCC and 0==SURF

%% pick blending methods
ADD = 1;
AVG = 0;

%% intermediate results
saved_matched_Points = 0;
save_tx_ty = 0;
save_masks = 0;
SURF_Feature_Mean_Mode = 1; %% 1=mean, 0=mode

%% pick your template position and size
template_row_start=60; template_col_start=100;
template_hight=150; template_width=200;


%% input and output directory
dirname='/Volumes/F/Courses/MesenteryData/SFM_300_400/';
if NCC==1
     dirnameOut=sprintf('%sNCC_%d_%d_%dx%d/',dirname, template_row_start, template_col_start, template_hight, template_width);
else
    if  SURF_Feature_Mean_Mode==1
        dirnameOut=sprintf('%sFeatureMean/',dirname); 
    else
        dirnameOut=sprintf('%sFeatureMode/',dirname); 
    end
     
    dirnameOutFeatureMatched=sprintf('%sFeatureMatched/',dirnameOut(1:end));
    dirnameOutMotion=sprintf('%sMotion/',dirnameOut(1:end));
    if (~isdir(dirnameOutFeatureMatched)); mkdir(dirnameOutFeatureMatched); end;
    if (~isdir(dirnameOutMotion)); mkdir(dirnameOutMotion); end;
end
if (~isdir(dirnameOut)); mkdir(dirnameOut); end;

%% all uneven mosaic directory
dirnameOutMosaic=sprintf('%sMosaic/',dirnameOut);
if (~isdir(dirnameOutMosaic)); mkdir(dirnameOutMosaic); end;


%% for pixel filling blending
if ADD==1
    dirnameOutADD=sprintf('%s_ADD/', dirnameOut(1:end-1));
    if (~isdir(dirnameOutADD)); mkdir(dirnameOutADD); end;
end

%% for average blending
if AVG==1
    dirnameOutAVG=sprintf('%s_AVG/', dirnameOut(1:end-1));
    if (~isdir(dirnameOutAVG)); mkdir(dirnameOutAVG); end;
end

%% check if you have enough images
files = dir(fullfile(dirname,'F*.png'));
no_Frames=size(files,1);
if( no_Frames < 2 );     disp('at least two images with appropriate format in the directory');    return; end;% 



%% read the very first image, mosaic and mask
prevFrame = imread(fullfile(dirname, files(1).name)); [M,N,~]=size(prevFrame);
pf_row_start=1; pf_col_start=1; yend=480; xend=720;

%% initialization
mosaic=prevFrame;
prevMosaic=mosaic;
mosaicADD=mosaic;
mosaicAVG=mosaic;

mask=ones(M,N);
prevMask=mask;

%% location of Intermediate Mosaics
xy=[]; xy_row=[]; no_matched=-1;

%% loop over for processing
for i=1:no_Frames
    [i no_matched]
    [pf_col_start pf_row_start];
    
    %% Read frame and template
    Frame = imread(fullfile(dirname, files(i).name)); [m,n,~]=size(Frame); Frame_org=Frame;    
    
    if NCC == 1
        %% find NCC        
        template=Frame(template_row_start+1:template_row_start+template_hight, template_col_start+1:template_col_start+template_width, :);
    
        c = normxcorr2(template(:,:,1),prevFrame(:,:,1));%figure, surf(c), shading flat    
        [max_c, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        corr_offset = [(xpeak-size(template,2)) 
                       (ypeak-size(template,1))];

        %% [xbeginFrame, ybeginFrame] is wrt to Frame,  [round(corr_offset(1)+ 1), round(corr_offset(2)+ 1)] is wrt to template    
        xbeginFrame=round(corr_offset(1)+ 1) - template_col_start;
        ybeginFrame=round(corr_offset(2)+ 1) - template_row_start; 
    else
        [mean_x, mean_y, mode_x, mode_y, mean_ix, mean_iy, mode_ix, mode_iy, no_matched]=getTranslation(rgb2gray(prevFrame), rgb2gray(Frame), saved_matched_Points,save_tx_ty, i, dirnameOutFeatureMatched, dirnameOutMotion);    
        
        if SURF_Feature_Mean_Mode==0
            xbeginFrame=round(mode_ix+1);
            ybeginFrame=round(mode_iy+1);
        else
            xbeginFrame=round(mean_ix+1);
            ybeginFrame=round(mean_iy+1);
        end
    end
    
    
    %% [xbegin, ybegin] is wrt to Mosaic, 
    xbegin=xbeginFrame+pf_col_start-1;
    ybegin=ybeginFrame+pf_row_start-1;
    
%     %% for debuging
%     if fix(mode_x+1) ~= xbeginFrame || fix(mode_y+1) ~= ybeginFrame
%         disp('-------------- found mismatch---------------------');
%         [fix(mode_x+1) fix(mode_y+1) mean_x mean_y ]
%         [xbeginFrame ybeginFrame ybegin yend xbegin xend]    
%     end
   
    
    %% if xbegin and ybegin turn out to be negative
    if xbegin<1
        mosaic=[zeros(size(mosaic,1), -xbegin+1, 3) mosaic];
        prevMask=[zeros(size(prevMask,1), -xbegin+1)  prevMask];
        mask=[zeros(size(mask,1), -xbegin+1)  mask];
       
        %% for retriveing global indexes later
        for j=1:size(xy,1)
            xy(j,1)=xy(j,1)-xbegin+1;
        end 
        if ADD==1;  mosaicADD=[zeros(size(mosaicADD,1), -xbegin+1, 3) mosaicADD]; end;
        if AVG==1;  mosaicAVG=[zeros(size(mosaicAVG,1), -xbegin+1, 3) mosaicAVG]; end;

        xbegin=1;
        
        
    end
    if ybegin<1
        mosaic=[zeros(-ybegin+1, size(mosaic,2), 3); mosaic];
        mask=[zeros(-ybegin+1, size(mask,2)); mask];
        prevMask=[zeros(-ybegin+1, size(prevMask,2)); prevMask];
        
        %% for retriveing global indexes later
        for j=1:size(xy,1)
            xy(j,2)=xy(j,2)-ybegin+1;
        end
        if ADD==1; mosaicADD=[zeros(-ybegin+1, size(mosaicADD,2), 3); mosaicADD]; end;
        if AVG==1; mosaicAVG=[zeros(-ybegin+1, size(mosaicAVG,2), 3); mosaicAVG]; end;

        ybegin=1;
        
     end
    
    %imshow(uint8([mask prevMask mask-prevMask]*255));
    
    xy_row=[xbegin ybegin];
    %xy= [xy; xbegin ybegin size(mosaic,2) size(mosaic,1)];

    %% find end position of Frame wrt canvas
    xend=xbegin+n-1;
    yend=ybegin+m-1;   
    
    
    %% update size of mosaic and mask
    mosaic(end+1: yend, end+1:xend, :)=0;
    mosaicADD(end+1: yend, end+1:xend, :)=0;    
    mosaicAVG(end+1: yend, end+1:xend, :)=0;  
    prevMask(end+1: yend, end+1:xend)=0;
    mask=prevMask;
    
    %% check difference
    diff=mosaic(ybegin:yend, xbegin:xend, :)-Frame;
    prevMaskROI=prevMask(ybegin:yend, xbegin:xend, :);
    diff1=diff(:,:, 1);    diff2=diff(:,:, 2);    diff3=diff(:,:, 3);
    diff1(prevMaskROI==0)=0;      diff2(prevMaskROI==0)=0;      diff3(prevMaskROI==0)=0;
    [sum(diff1(:)) sum(diff2(:)) sum(diff3(:))];

    
    %% update mosaic and mask
    mosaic(ybegin:yend, xbegin:xend, :)=Frame(:,:,:);  %mosaic(ybegin:yend, xbegin:xend, 1)=Frame(:,:,1); mosaic(ybegin:yend, xbegin:xend, 1)=Frame(:,:,1);
    mask(ybegin:yend, xbegin:xend, :)=1;
    prevFrame=Frame;
    
    
    %% for Pixels addition
    if ADD==1
        Frame=Frame_org;
        newPixels=mask-prevMask;
        
        newPixels=newPixels(ybegin:yend, xbegin:xend);        
        F1=Frame(:,:,1); F2=Frame(:,:,2); F3=Frame(:,:,3);
        F1(newPixels==0)=0; F2(newPixels==0)=0; F3(newPixels==0)=0;
        Frame(:,:,1)=F1; Frame(:,:,2)=F2; Frame(:,:,3)=F3;
        %imshow(uint8([mosaic(ybegin:yend, xbegin:xend, 1) Frame(:,:,1) mask(ybegin:yend, xbegin:xend)*255 newPixels*255 mosaicADD(ybegin:yend, xbegin:xend)]))
        mosaicADD(ybegin:yend, xbegin:xend, :)=mosaicADD(ybegin:yend, xbegin:xend, :)+Frame;
         
%         %% write output image
%         fname=sprintf('mask_%06d.png', i);
%         fname_wpath=fullfile(dirnameOutADD,fname);
%         imwrite(uint8(mask),fname_wpath);   
    
    end
    
    %% for average blending
    if AVG==1
        Frame=Frame_org;
        newPixels=mask-prevMask;
        newPixels=newPixels(ybegin:yend, xbegin:xend);
        
        %% new Pixels are added here
        F1=Frame(:,:,1); F2=Frame(:,:,2); F3=Frame(:,:,3);
        F1(newPixels==0)=0; F2(newPixels==0)=0; F3(newPixels==0)=0;
        Frame(:,:,1)=F1; Frame(:,:,2)=F2; Frame(:,:,3)=F3;
        %imshow(uint8([mosaic(ybegin:yend, xbegin:xend, 1) Frame(:,:,1) mask(ybegin:yend, xbegin:xend)*255 newPixels*255 mosaicAVG(ybegin:yend, xbegin:xend)]))
        mosaicAVG(ybegin:yend, xbegin:xend, :)=mosaicAVG(ybegin:yend, xbegin:xend, :)+Frame;
        
        %% now take care of overlapping pixels 
        %% in new pixel region, both mosaicADD and Frame are same, average will still be same
        %% in overlapping region, they need to be averaged
        Frame=Frame_org;
        mosaicAVG(ybegin:yend, xbegin:xend, :)=uint8((0.5*mosaicAVG(ybegin:yend, xbegin:xend, :)+0.5*Frame));

%         %% write output image
%         fname=sprintf('mask_%06d.png', i);
%         fname_wpath=fullfile(dirnameOutAVG,fname);
%         imwrite(uint8(mask),fname_wpath);  
         
    end
    
    %% for iMosaic generaton for even and uneven size
    if save_masks==1
        %% write output MASK image
        fname=sprintf('mask_%06d.png', i);
        fname_wpath=fullfile(dirnameOut,fname);
        imwrite(uint8(mask),fname_wpath); 

        %% write output MOSAIC image
        fname=sprintf('Mosaic_%06d.png', i);
        fname_wpath=fullfile(dirnameOutMosaic,fname);
        imwrite(uint8(mosaic),fname_wpath); 
    end
    
    xy_row=[xy_row size(mosaic,2) size(mosaic,1)];
    xy= [xy; xy_row];

    
    %% save for next iteration    
    prevMask=mask;
    pf_col_start=xbegin;
    pf_row_start=ybegin;   
    
   
end

%% save xy location of intermediate mosaics: col(x)-row(y) fashion
dlmwrite(sprintf('%sxy.txt',dirnameOut), xy(1:end, :));


%% write output image
fname=sprintf('Mosaic_%06d.png', i);
fname_wpath=fullfile(dirnameOut,fname);
imwrite(uint8(mosaic),fname_wpath); 

if ADD==1
    %% write output image
    fname=sprintf('MosaicADD_%06d.png', i);
    fname_wpath=fullfile(dirnameOutADD,fname);
    imwrite(uint8(mosaicADD),fname_wpath); 
    dlmwrite(sprintf('%sxy.txt',dirnameOutADD), xy);
end


if AVG==1
    %% write output image
    fname=sprintf('MosaicAVG_%06d.png', i);
    fname_wpath=fullfile(dirnameOutAVG,fname);
    imwrite(uint8(mosaicAVG),fname_wpath);   
    dlmwrite(sprintf('%sxy.txt',dirnameOutAVG), xy);
end

total_time=toc
time_per_frame=total_time/no_Frames



