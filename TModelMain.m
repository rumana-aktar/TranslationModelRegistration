%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Main: TModelMain.m
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
% NCC = 0.1615 sec/frame % Feature = 0.1675 sec/frame for ABQ_Synthetic
% NCC = 0.1169 sec/frame % Feature = 0.1314 sec/frame for ABQ_Synthetic_Negative imsize: 480x720
% NCC = 0.1229 sec/frame % Feature = 0.2936 sec/frame for sequence5, imsize: 480x720
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

clc;
clear all;
warning off;

addpath('./tModel/');

tic;

%% pick a model
NCC = 1; %%1==NCC and 0==SURF

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
%dirname='/Volumes/F/Courses/MesenteryData/Seq5_fr30/';
%dirname='/Volumes/F/Courses/MesenteryData/SFM_100/';
dirname='/Volumes/D/Mesentery/Seq2/';
%dirname='/Volumes/F/Courses/MesenteryData/ABQ_Synthetic_blur2_alt/';
%dirname='/Volumes/F/Courses/MesenteryData/ABQ_Synthetic/';

dirFrames=sprintf('%sFrames/', dirname);


%% make output directories
if NCC==1
     dirnameOut=sprintf('%sNCC_%d_%d_%dx%d/',dirname, template_row_start, template_col_start, template_hight, template_width);
else
    if  SURF_Feature_Mean_Mode==1
        dirnameOut=sprintf('%sFeatureMean/',dirname); 
    else
        dirnameOut=sprintf('%sFeatureMode/',dirname); 
    end
     
end
dirnameOutFeatureMatched=sprintf('%sFeatureMatched/',dirnameOut(1:end));
dirnameOutMotion=sprintf('%sMotion/',dirnameOut(1:end));
if (~isdir(dirnameOut)); mkdir(dirnameOut); end;

%% make directories iff we are handling SURF features instead of NCC
if NCC==0
    if (~isdir(dirnameOutFeatureMatched)); mkdir(dirnameOutFeatureMatched); end;
    if (~isdir(dirnameOutMotion)); mkdir(dirnameOutMotion); end;
end

%% check if you have enough images
files = dir(fullfile(dirFrames,'F*.png'));
no_Frames=size(files,1);
if( no_Frames < 2 );     disp('at least two images with appropriate format in the directory');    return; end;% 

%% read the very first image, mosaic and mask
prevFrame = imread(fullfile(dirFrames, files(1).name)); [M,N,~]=size(prevFrame);
pf_row_start=1; pf_col_start=1; yend=480; xend=720;

%% initialization
mosaic=prevFrame;
prevMosaic=mosaic;
mosaicADD=mosaic;
mosaicAVG=mosaic;

mosaicBLUR=mosaic; usingCanvasEdge=0; usingCanvasBlur=0;
mosaicEdge=mosaic;

mask=ones(M,N);
prevMask=mask;

%% location of Intermediate Mosaics
xy=[]; xy_row=[];

%% loop over for processing
for i=1:no_Frames
    i
    [pf_col_start pf_row_start];
    
    %--Read frame and template
    Frame = imread(fullfile(dirFrames, files(i).name)); [m,n,~]=size(Frame); Frame_org=Frame;    
    
    
    %% --------------------------------------------------------------------    
    %--xbeginFrame, ybeginFrame wrt previous Frame using either NCC or SURF
    [xbeginFrame, ybeginFrame, matching_score]=getTranslationPrevFrame(NCC, template_row_start, template_hight, template_col_start, template_width, Frame, prevFrame, saved_matched_Points, save_tx_ty, i, dirnameOutFeatureMatched, dirnameOutMotion,  SURF_Feature_Mean_Mode);

    
    %% --------------------------------------------------------------------    
    %--[xbegin, ybegin] is wrt to Mosaic, 
    xbegin=xbeginFrame+pf_col_start-1;
    ybegin=ybeginFrame+pf_row_start-1;
   
    %--if xbegin and ybegin turn out to be negative
    if xbegin<1 || ybegin<1
        [mosaic, mask, prevMask, xbegin, ybegin, mosaicADD, mosaicAVG, mosaicBLUR, mosaicEdge, xy]=handleNegativeMotion(mosaic, mask, prevMask, xbegin, ybegin, ADD, mosaicADD, AVG, mosaicAVG, mosaicBLUR, mosaicEdge, xy);
    end
    
    %--find end position of Frame wrt canvas
    xend=xbegin+n-1;
    yend=ybegin+m-1;       
    
    %% --------------------------------------------------------------------    
    %--update size of mosaic and mask
    mosaic(end+1: yend, end+1:xend, :)=0;
    mosaicBLUR(end+1: yend, end+1:xend, :)=0;
    mosaicEdge(end+1: yend, end+1:xend, :)=0;
    mosaicADD(end+1: yend, end+1:xend, :)=0;    
    mosaicAVG(end+1: yend, end+1:xend, :)=0;  
    prevMask(end+1: yend, end+1:xend)=0;
    mask=prevMask;
    mask(ybegin: yend, xbegin:xend)=1;
    
    
    %% --------------------------------------------------------------------    
    %--begug purpose
    diff=mosaic(ybegin:yend, xbegin:xend, :)-Frame;
    prevMaskROI=prevMask(ybegin:yend, xbegin:xend, :);
    diff1=diff(:,:, 1);    diff2=diff(:,:, 2);    diff3=diff(:,:, 3);
    diff1(prevMaskROI==0)=0;      diff2(prevMaskROI==0)=0;      diff3(prevMaskROI==0)=0;
    [sum(diff1(:)) sum(diff2(:)) sum(diff3(:))];    
    
    
    
    %% --------------------------------------------------------------------    
    %--required for EDGE and BLUR blending
    newPixels=mask-prevMask;
    newPixels=newPixels(ybegin:yend, xbegin:xend);        
    
    %%  blur effects    
    canvasROI=mosaicBLUR(ybegin:yend, xbegin:xend, :);
    [mm, nn]=size(newPixels);newPixels3=zeros(mm,nn, 3);newPixels3(:,:,1)=newPixels;newPixels3(:,:,2)=newPixels;newPixels3(:,:,3)=newPixels;
    canvasROI(newPixels3==1)=0;
    blurCanvas = blurMetric(canvasROI);
    frameROI=Frame;
    frameROI(newPixels3==1)=0;
    blurFrame = blurMetric(frameROI);
    
    %% edge effect      
    canvasEdgeROI=mosaicEdge(ybegin:yend, xbegin:xend, :);
    canvasEdge=edge(rgb2gray(canvasEdgeROI), 'Canny');
    canvasEdge(newPixels==1)=0;
    canvasEdgeResponse=sum(canvasEdge(:));
    frameEdge=edge(rgb2gray(Frame), 'Canny');
    frameEdge(newPixels==1)=0;  
    frameEdgeResponse=sum(frameEdge(:));  

    
    %% --------------------------------------------------------------------    
    %--update mosaic for Pixel Replacement and mask
    mosaic(ybegin:yend, xbegin:xend, :)=Frame(:,:,:);  %mosaic(ybegin:yend, xbegin:xend, 1)=Frame(:,:,1); mosaic(ybegin:yend, xbegin:xend, 1)=Frame(:,:,1);
    mask(ybegin:yend, xbegin:xend, :)=1;
    prevFrame=Frame;    
    
    %% --------------------------------------------------------------------    
    %--for Pixels addition
    if ADD==1; mosaicADD=updateMosaicADD(Frame, mask, prevMask, xbegin, ybegin, xend, yend, mosaicADD); end;  
    
    %% --------------------------------------------------------------------    
    %--for average blending
    if AVG==1; mosaicAVG=updateMosaicAVG(Frame, mask, prevMask, xbegin, ybegin, xend, yend, mosaicAVG); end;
    
    %% Edge effect
    if canvasEdgeResponse < frameEdgeResponse
        usingCanvasEdge=0;
        mosaicEdge(ybegin:yend, xbegin:xend, :)=Frame(:,:,:);
    else
        mosaicEdge=updateMosaicADD(Frame, mask, prevMask, xbegin, ybegin, xend, yend, mosaicEdge);     
        usingCanvasEdge=1;
    end

    %% blur effect
    if blurFrame < blurCanvas
        usingCanvasBlur=0;
        mosaicBLUR(ybegin:yend, xbegin:xend, :)=Frame(:,:,:);
    else
        mosaicBLUR=updateMosaicADD(Frame, mask, prevMask, xbegin, ybegin, xend, yend, mosaicBLUR);
        usingCanvasBlur=1;
    end

    %% --------------------------------------------------------------------    
    %--update file for iMosaics
    %xy= [xy; [xbegin ybegin size(mosaic,2) size(mosaic,1) i matching_score blurCanvas blurFrame usingCanvas]];
    xy= [xy; [xbegin ybegin size(mosaic,2) size(mosaic,1) i matching_score  blurFrame blurCanvas usingCanvasBlur frameEdgeResponse canvasEdgeResponse usingCanvasEdge]];

    %% --------------------------------------------------------------------    
    %--save for next iteration    
    prevMask=mask;
    pf_col_start=xbegin;
    pf_row_start=ybegin;     
    
end

%% save xy location of intermediate mosaics: col(x)-row(y) fashion
dlmwrite(sprintf('%sxy.txt',dirnameOut), xy(1:end, :));

%% write output image
fname=sprintf('MosaicREP_%06d.png', i);
fname_wpath=fullfile(dirnameOut,fname);
imwrite(uint8(mosaic),fname_wpath); 

%% write output mosaic using BLUR metric
fname=sprintf('MosaicBLUR_%06d.png', i);
fname_wpath=fullfile(dirnameOut,fname);
imwrite(uint8(mosaicBLUR),fname_wpath); 

%% write output mosaic using EDGE metric
fname=sprintf('MosaicEDGE_%06d.png', i);
fname_wpath=fullfile(dirnameOut,fname);
imwrite(uint8(mosaicEdge),fname_wpath); 



if AVG==1 && ADD==1
 %% write output mosaic using EDGE, BLUR, REP, ADD
    fname=sprintf('Mosaic_EDGE_BLUR_REP_ADD_AVG_%06d.png', i);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8([mosaicEdge mosaicBLUR mosaic mosaicADD mosaicAVG]),fname_wpath); 
elseif ADD==1
    %% write output mosaic using EDGE, BLUR, REP, ADD
    fname=sprintf('Mosaic_EDGE_BLUR_REP_ADD_%06d.png', i);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8([mosaicEdge mosaicBLUR mosaic mosaicADD]),fname_wpath); 
else
    %% write output mosaic using EDGE, BLUR, REP, ADD
    fname=sprintf('Mosaic_EDGE_BLUR_REP_%06d.png', i);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8([mosaicEdge mosaicBLUR mosaic]),fname_wpath); 
end

if ADD==1
    %% write output image
    fname=sprintf('MosaicADD_%06d.png', i);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8(mosaicADD),fname_wpath); 
    %dlmwrite(sprintf('%sxy.txt',dirnameOutADD), xy);
end

if AVG==1
    %% write output image
    fname=sprintf('MosaicAVG_%06d.png', i);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8(mosaicAVG),fname_wpath);   
    %dlmwrite(sprintf('%sxy.txt',dirnameOutAVG), xy);
end

total_time=toc
time_per_frame=total_time/no_Frames



