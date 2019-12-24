
clc;
clear all;
warning off;

%% bark, bikes, boat, graf, leuven, trees, ubc, wall



dirnameFrame='/Volumes/F/Courses/MesenteryData/Sequence5_fr5_cropped';
dirnameMosaic='/Volumes/F/Courses/MesenteryData/Sequence5_fr5_cropped/FeatureMean_ADD/MosaicL';
dirnameMotion='/Volumes/F/Courses/MesenteryData/Sequence5_fr5_cropped/FeatureMean/Motion_Paired';

dirnameOut=sprintf('%sFr_Mos_Motion/', dirnameMosaic(1:end-7));
if (~isdir(dirnameOut))
    mkdir(dirnameOut);
end

%check if you have enough images
filesFrame = dir(fullfile(dirnameFrame,'Fr*.png'));
if( size(filesFrame,1) < 2 )
    disp('at least two images with appropriate format in the directory');
    return;
end;% 
filesMosaic = dir(fullfile(dirnameMosaic,'Mo*.png'));
filesMotion = dir(fullfile(dirnameMotion,'AA*.png'));

lines=2;


%cut off extra black region    
i=1;
while (i<=size(filesFrame,1))
    i
    
    IFrame = imread(fullfile(dirnameFrame, filesFrame(i).name)); [mF, nF, ~]=size(IFrame);
    IMosaic = imread(fullfile(dirnameMosaic, filesMosaic(i).name)); IMosaic(end+1: end+6, :, :)=255; [mM, nM, ~]=size(IMosaic);
    IMotion = imread(fullfile(dirnameMotion, filesMotion(i).name)); [mMt, nMt, ~]=size(IMotion);
    
    IMosaic(mM+1: mM+mF+2, :, :)=0;
    IMosaic(mM+1: mM+mF, 1:nF, :)=IFrame;[mM, nM, ~]=size(IMosaic);
    
    IMosaic(:, nM+1:nM+nMt, :)=0;
    IMosaic(1:mMt, nM+1:nM+nMt, :)=IMotion;
    
    
    
    fname=sprintf('AA_%06d.png', i);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(IMosaic,fname_wpath);  
    i=i+1;
end

