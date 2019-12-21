%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Main: TranslationalMosaicModel_NCC_Feature.m
%-- Author: Rumana Aktar, 12/14/19
%--------------------------------------------------------------------------
%--first run TranslationalMosaicModel_NCC_Feature for positive and negative motion, and generate a file containing xy location of iMosaics
%--then run this file to generate iMosaics
%--save xy location of intermediate mosaics: col(x)-row(y) fashion
%--uses xy locatons and Frames to produce iMosaics
%--produces border around current frames
%--if border==0, no border, 
%--if border==1, border for current frame only,
%--if border==2, border for all frames together
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; clc;

%% parameters
lineWidth=4;
border=1;           %--if border==0, no border, 
                    %--if border==1, border for current frame only,
                    %--if border==2, border for all frames together XXX
motionOnImosaic=1;  %--if motionOnImosaic==0, do not show iMosaicBlended
                    %--if motionOnImosaic==1, show motion on top of iMosaicBlended
dirname='/Volumes/F/Courses/MesenteryData/Seq5/NCC_60_100_150x200/';
sameIMosaicDir=1;   %--if sameIMosaicDir=1, save the updated iMosaic at the preivous iMosaic direcotry
                    %--if sameIMosaicDir=0, save the updated iMosaic at a new direcotry

%% read the file for Frame start position 
%xy=dlmread(sprintf('%sxy.txt', dirname));
xy=dlmread(sprintf('%sxy_blur_edge.txt', dirname));

%% Blending metric
blendingMetric='EdgeRes'; %--blurMetric, EdgeRes, REP 
    
%% go to the parent directory and read a frame and read the size
idcs   = strfind(dirname,'/');
FrameDir = dirname(1:idcs(size(idcs,2)-1));
%-- read the frame
filesFrame = dir(fullfile(FrameDir,'Fr*.png'));
I=imread(fullfile(FrameDir, filesFrame(1).name));
[Fm, Fn, ~]=size(I);

%% read the Mosaic
files = dir(fullfile(dirname,'Mosaic*.png')); 
mosaic=imread(sprintf('%s%s',dirname, sprintf('Mosaic_%06d.png', size(filesFrame,1))));


%% iMosaicDirname
iMosaicDirname=sprintf('%siMosaic/',dirname);
    
%% generate iMosaics
%iMosaicDirname=getImosaicsImproved(mosaic, xy, dirname, Fm, Fn, FrameDir, filesFrame, blendingMetric);
getMotionBorder(mosaic, xy, dirname, iMosaicDirname, Fm, Fn, FrameDir, filesFrame, border, lineWidth, motionOnImosaic, sameIMosaicDir)
%getImosaicsColoredBorderFinalBlurry(mosaic, xy, dirname, iMosaicDirname, Fm, Fn, FrameDir, filesFrame, border, lineWidth, motionBorderTogether);    
%getImosaicsColoredBorderFinal(mosaic, xy, dirname, Fm, Fn, FrameDir, filesFrame, border, lineWidth, motionBorderTogether);    
%getImosaicsColoredBorder2(mosaic, xy, dirname, Fm, Fn, FrameDir, filesFrame, border, lineWidth);
%getImosaicsFinal(mosaic, xy, dirname, Fm, Fn, FrameDir, filesFrame);