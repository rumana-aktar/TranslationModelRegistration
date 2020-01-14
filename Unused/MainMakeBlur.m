%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Main: TranslationalMosaicModel_NCC_Feature.m
%-- Author: Rumana Aktar, 12/5/19
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

clc;
clear all;
warning off;

addpath('./tModel/');

tic;


%% input and output directory
dirname='/Volumes/F/Courses/MesenteryData/ABQ_Synthetic';
dirnameOut=sprintf('%s_blur2_alt/',dirname); mkdir(dirnameOut);

%% check if you have enough images
files = dir(fullfile(dirname,'F*.png'));
no_Frames=size(files,1);
if( no_Frames < 2 );     disp('at least two images with appropriate format in the directory');    return; end;% 


xy=[];

%% loop over for processing
for i=1:no_Frames
    i
    if i>=50
        br=1;
    end
    
    %--Read frame and template
    Frame = imread(fullfile(dirname, files(i).name)); [m,n,~]=size(Frame); Frame_org=Frame;
    FrameEdge=edge(rgb2gray(Frame), 'Canny');
    
    Output=zeros(size(Frame));
    Output(:,:,1)=medfilt2((Frame(:,:,1)), [5 5]);
    Output(:,:,2)=medfilt2((Frame(:,:,2)), [5 5]);
    Output(:,:,3)=medfilt2((Frame(:,:,3)), [5 5]);    
    OutputEdge=edge(rgb2gray(Output), 'Canny');

    Output2=zeros(size(Frame));
    Output2(:,:,1)=medfilt2((Output(:,:,1)), [10 10]);
    Output2(:,:,2)=medfilt2((Output(:,:,2)), [10 10]);
    Output2(:,:,3)=medfilt2((Output(:,:,3)), [10 10]);
    Output2Edge=edge(rgb2gray(Output2), 'Canny');

    %% write output
    fname=sprintf('FrameB_%06d.png', i);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8([Frame Output, Output2]),fname_wpath); 

    
    if mod(i,4)==0
        imwrite(uint8(Output),fname_wpath); 
        xy=[xy; [i blurMetric(Output)]];
    elseif mod(i,15)==0
        imwrite(uint8(Output2),fname_wpath); 
        xy=[xy; [i blurMetric(Output2)]];
   else
        imwrite(uint8(Frame),fname_wpath);         
        xy=[xy; [i blurMetric(Frame)]];
   end
    
  % xy=[xy; [i blurMetric(Frame) blurMetric(Output) blurMetric(Output2) sum(FrameEdge(:)) sum(OutputEdge(:)) sum(Output2Edge(:))]]; 
    
end

%% save xy location of intermediate mosaics: col(x)-row(y) fashion
dlmwrite(sprintf('%sxy.txt',dirnameOut), xy(1:end, :));

%% save BLUR response
figure, plot(1: size(xy,1), xy(:, 2),'r--*')
%legend('Frame','Median1', 'Median2')
title('Blur2');
print(sprintf('%sBlur2', dirnameOut), '-dpng')


% %% save BLUR response
% figure, plot(1: size(xy,1), xy(:, 2),'r--*', 1: size(xy,1), xy(:, 3),'b--o', 1: size(xy,1), xy(:, 4),'g--+')
% legend('Frame','Median1', 'Median2')
% title('Blur2');
% print(sprintf('%sBlur2', dirnameOut), '-dpng')
% 
% 
% %% save EDGE response
% figure, plot(1: size(xy,1), xy(:, 5),'r--*', 1: size(xy,1), xy(:, 6),'b--o', 1: size(xy,1), xy(:, 7), 'g--+')
% set(gca, 'YScale', 'log')
% legend('Frame','Median1', 'Median2')
% title('Edge Response');
% print(sprintf('%sEdge', dirnameOut), '-dpng')
% 
