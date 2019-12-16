
clc;
clear all;
warning off;

%% 

additionalMotion=0;
frameScale=1;



dirnameFrame='/Volumes/F/Courses/MesenteryData/SFM_100_BI';
dirnameMosaic=sprintf('%s/NCC/MosaicL', dirnameFrame);
dirnameMotion=sprintf('%s/NCC/MosaicMotion',dirnameFrame);

dirnameOut=sprintf('%s/Fr_Mosaic/', dirnameMosaic);
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
filesMotion = dir(fullfile(dirnameMotion,'Mo*.png'));

lines=5;

%% seq5: whole sequence
   seq_name='Sequence -> VTS_01_5.VOB';
 start_time='Start Time -> 16:54:43:32';
   end_time='End Time -> 16:57:21:86';
  time_intv='Time Interval -> 00:02:78:54';
       date='Date -> 07-24';
 frame_rate='Frame Rate -> 6(30)';
 frame_size='Frame Size -> 720x480';
str_info=sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s', seq_name, start_time, end_time, time_intv, date, frame_rate, frame_size)

if additionalMotion==1
    fontSize=40;
else
    fontSize=40;
end



%% seq5, fr+501:600
%    seq_name='Sequence Name -> VTS_01_5.VOB';
%  start_time='   Start Time -> 16:56:06:09';
%    end_time='     End Time -> 16:56:22:59';
%   time_intv='Time Interval -> 00:00:16:50';
%        date='         Date -> 07-24';
%        date='      FrameNo -> 07-24';
% str_info=sprintf('%s\n%s\n%s\n%s\n%s',seq_name, start_time, end_time, time_intv, date)
% fontSize=60;


%cut off extra black region  
j=1;
i=1;
frame_no=500*5;
while (i<=size(filesMosaic,1))
    i
    %% read iMosaic
    IMosaic = imread(fullfile(dirnameMosaic, filesMosaic(i).name));     
    
    %% read frame and upscale it
    IFrame = imread(fullfile(dirnameFrame, filesFrame(j).name)); 
    IFrame = imresize(IFrame, frameScale);    [mF, nF, ~]=size(IFrame);
    
    %% read motion and upscale it
    IMotion = imread(fullfile(dirnameMotion, filesMotion(j).name)); 
    IMotion = imresize(IMotion, frameScale);    [mMt, nMt, ~]=size(IMotion);
    
    %% rotate the iMosaic
    IMosaic=permute(IMosaic,[2 1 3]);   [mM, nM, ~]=size(IMosaic); IMosaicT=zeros(size(IMosaic));
    IMosaicT=IMosaic;
%     for k=1:nM
%         IMosaicT(:,nM-k+1,:)=IMosaic(:,k,:);
%     end  
    %% add white border
    IMosaicT(end+1: end+lines, :)=255;    
    [mM, nM, ~]=size(IMosaicT);    
    
    %% add Frame below
    IMosaicT(mM+1:mM+mF, :, :)=0;    
    IMosaicT(mM+1:mM+mF, 1:nF, :)=IFrame;  
    
    if additionalMotion ==1
        %% add Motion Frame below
        IMosaicT(mM+1:mM+mF, size(IMosaicT,2)-nMt+1:size(IMosaicT,2), :)=IMotion;  
    end
    
    
    %% add text
    str_info1=sprintf('FrameNo -> %04d\n%s', frame_no, str_info);
    
    if additionalMotion==1
        IMosaicT = insertText(uint8(IMosaicT), [nF+20 mM+lines+200 ], str_info1, 'AnchorPoint', 'LeftTop', 'fontSize', fontSize, 'BoxColor', 'black', 'TextColor', 'white'); %1800      
    else
        IMosaicT = insertText(uint8(IMosaicT), [nF+200 mM+lines+40 ], str_info1, 'AnchorPoint', 'LeftTop', 'fontSize', fontSize, 'BoxColor', 'black', 'TextColor', 'white'); %1800
    end
        
    %imshow(uint8(IMosaicT));     
    
    fname=sprintf('AA_%06d.png', i);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8(IMosaicT),fname_wpath);  
    i=i+1;
    j=j+1;
    frame_no=frame_no+5;
end

