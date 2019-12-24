%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Main: MainIMosaicIMapIAnimation.m
%-- Author: Rumana Aktar, 12/22/19
%--------------------------------------------------------------------------
%--first run TranslationalMosaicModel_NCC_Feature for positive and negative motion, and generate a file containing xy location of iMosaics
%--then run this file to generate iMosaics
%--save xy location of intermediate mosaics: col(x)-row(y) fashion
%--uses xy locatons and Frames to produce iMosaics
%--produces border around current frames
%--if border==0, no border, 
%--if border==1, border for current frame only,
%--------------------------------------------------------------------------
%for Seq5_100: change, frame_rate=6(30), frame_no=501, frame_no=frame_no+5,
%textInsert for str_info1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --------------------------------------------------------------------    
clear all; clc;
%% --------------------------------------------------------------------    
%--parameters
lineWidth=2;
border=1;           %--if border==0, no border, 
                    %--if border==1, border for current frame only,
motionOnImosaic=1;  %--if motionOnImosaic==0, do not show motion on top of iMosaicBlended
                    %--if motionOnImosaic==1, show motion on top of iMosaicBlended
rootDir='/Volumes/F/Courses/MesenteryData/SFM_100/';   %Sequence5_fr6_cropped, SFM_100, Seq5_fr30         
sameIMosaicDir=1;   %--if sameIMosaicDir=1, save the updated iMosaic at the preivous iMosaic direcotry
                    %--if sameIMosaicDir=0, save the updated iMosaic at a new direcotry
frameScale=1;
Vertical=1;         %--if Vertical=1, Mosaic will be in Vertial orientation
                    %--if Vertical==0, Mosaic will be in Horizontal orientation
mosaicDir=sprintf('%sNCC_60_100_150x200/', rootDir);

%% --------------------------------------------------------------------    
%--iMosaic, iMotion and iAnimation directoty
iMosaicDirname=sprintf('%siMosaic/',mosaicDir);
dirnameOutMotion=sprintf('%sMotionMap/',mosaicDir); 
dirnameAnimationOut=sprintf('%sAnimation/',mosaicDir); 

%% --------------------------------------------------------------------    
%--iMosaicDirname='/Volumes/D/Mesentery/iMosaic/';
% dirnameOutMotion='/Volumes/D/Mesentery/MotionMap/';
% dirnameAnimationOut='/Volumes/D/Mesentery/Animation/';

%% --------------------------------------------------------------------    
%--Read xy file
xy=dlmread(sprintf('%sxy.txt', mosaicDir));

%% --------------------------------------------------------------------    
%--Blending metric
blendingMetric='EdgeRes'; %--blurMetric, EdgeRes, REP 
    
%% --------------------------------------------------------------------    
%--go to the parent directory and read a frame and read the size
idcs   = strfind(mosaicDir,'/');
FrameDir = sprintf('%sFrames/', rootDir);
%-- read the frame
filesFrame = dir(fullfile(FrameDir,'Fr*.png'));
I=imread(fullfile(FrameDir, filesFrame(1).name));
[Fm, Fn, ~]=size(I);

%% --------------------------------------------------------------------    
%--read the Mosaic
files = dir(fullfile(mosaicDir,'MosaicEDGE_0*.png')); 
mosaic=imread(sprintf('%s%s',mosaicDir, sprintf('MosaicEDGE_%06d.png', size(filesFrame,1))));

%% --------------------------------------------------------------------    
%--generate iMosaics
getImosaicsImproved(mosaic, xy, mosaicDir, Fm, Fn, FrameDir, filesFrame, blendingMetric, iMosaicDirname);
getMotionBorder(mosaic, xy, mosaicDir, iMosaicDirname, Fm, Fn, FrameDir, filesFrame, border, lineWidth, motionOnImosaic, sameIMosaicDir, dirnameOutMotion);
%--check frame_rate, frame_no=frame_no+5/1 before changing 
if Vertical==1
    generateAnimationVertical(frameScale, FrameDir, iMosaicDirname, dirnameOutMotion, dirnameAnimationOut);
else
    generateAnimationHorizontal(frameScale, FrameDir, iMosaicDirname, dirnameOutMotion, dirnameAnimationOut);
end





%--previous codes
%getImosaicsColoredBorderFinalBlurry(mosaic, xy, dirname, iMosaicDirname, Fm, Fn, FrameDir, filesFrame, border, lineWidth, motionBorderTogether);    
%getImosaicsColoredBorderFinal(mosaic, xy, dirname, Fm, Fn, FrameDir, filesFrame, border, lineWidth, motionBorderTogether);    
%getImosaicsColoredBorder2(mosaic, xy, dirname, Fm, Fn, FrameDir, filesFrame, border, lineWidth);
%getImosaicsFinal(mosaic, xy, dirname, Fm, Fn, FrameDir, filesFrame);