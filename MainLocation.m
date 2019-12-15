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
border=1; %--if border==0, no border, 
          %--if border==1, border for current frame only,
          %--if border==2, border for all frames together
motionBorderTogether=1; %-- 0: iMosaic(w/o border)in MosaicL directory + Motion in Motion directory
                        %-- 1: iMosaic(w/o border)+Motion in MosaicL directory
                        %-- 2: iMosaic(w/o border)in MosaicL directory
dirname='/Volumes/F/Courses/MesenteryData/Sequence5_fr5_cropped2/NCC_60_100_150x200/';

%% read the file for Frame start position 
xy=dlmread(sprintf('%sxy.txt', dirname));


%% read the Mosaic
files = dir(fullfile(dirname,'Mosaic*.png'));
mosaic=imread(sprintf('%s%s',dirname, files(1).name));


%% go to the parent directory and read a frame and read the size
idcs   = strfind(dirname,'/');
FrameDir = dirname(1:idcs(size(idcs,2)-1));
%-- read the frame
filesFrame = dir(fullfile(FrameDir,'Fr*.png'));
I=imread(fullfile(FrameDir, filesFrame(1).name));
[Fm, Fn, ~]=size(I);

%% generate iMosaics
getImosaicsColoredBorderFinal(mosaic, xy, dirname, Fm, Fn, FrameDir, filesFrame, border, lineWidth, motionBorderTogether);    
%getImosaicsColoredBorder2(mosaic, xy, dirname, Fm, Fn, FrameDir, filesFrame, border, lineWidth);
%getImosaicsFinal(mosaic, xy, dirname, Fm, Fn, FrameDir, filesFrame);