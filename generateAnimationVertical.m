function generateAnimationVertical(frameScale, dirnameFrame, dirnameMosaic, dirnameMotion, dirnameOut)

if (~isdir(dirnameOut))
    mkdir(dirnameOut);
end

%check if you have enough images
filesFrame = dir(fullfile(dirnameFrame,'Fr*.png'));
if( size(filesFrame,1) < 2 )
    disp('at least two images with appropriate format in the directory');
    return;
end;% 
filesMosaic = dir(fullfile(dirnameMosaic,'iM*.png'));
filesMotion = dir(fullfile(dirnameMotion,'Mo*.png'));

line=10;


%% seq5: whole sequence
   seq_name='Sequence Name -> VTS_01_5.VOB';
 start_time='Start Time -> 16:54:43:32';
   end_time='End Time -> 16:57:21:86';
  time_intv='Time Interval -> 00:02:38:54';
       date='Date -> 07-24';
 frame_rate='Frame Rate -> 30';
 frame_size='Frame Size -> 720x480';
str_info=sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s', seq_name, start_time, end_time, time_intv, date, frame_rate, frame_size)
fontSize=60;


%% seq5, fr+501:600
%    seq_name='Sequence Name -> VTS_01_5.VOB';
%  start_time='   Start Time -> 16:56:06:09';
%    end_time='     End Time -> 16:56:22:59';
%   time_intv='Time Interval -> 00:00:16:50';
%        date='         Date -> 07-24';
%        date='      FrameNo -> 07-24';
% str_info=sprintf('%s\n%s\n%s\n%s\n%s',seq_name, start_time, end_time, time_intv, date)
% fontSize=60;


j=1;
i=1;
frame_no=1;

while (i<=size(filesMosaic,1))
    fprintf('\nGenerating Vertical Animation for frame = %d', i);      

    %% read iMosaic
    IMosaic = imread(fullfile(dirnameMosaic, filesMosaic(i).name));  
    [mM, nM, ~]=size(IMosaic); 
    
    %% read frame and upscale it
    IFrame = imread(fullfile(dirnameFrame, filesFrame(j).name));    
    IFrame = imresize(IFrame, frameScale);    [mF, nF, ~]=size(IFrame);
    %--add 
    str=sprintf('Frame_%04d', frame_no);
    IFrame=insertText(uint8(IFrame), [1, 1], str,'AnchorPoint', 'LeftTop', 'fontSize', 60);

    
    %% read frame and upscale it
    IMotion = imread(fullfile(dirnameMotion, filesMotion(j).name));    
    IMotion = imresize(IMotion, frameScale);    [mMt, nMt, ~]=size(IMotion);
    
    Canvas=IFrame;
    Canvas(mF+1: mM, : ,:)=0;
    Canvas(:, nF+1:nF+line ,:)=255; [mC, nC, ~]=size(Canvas);
    Canvas(:, nC+1:nC+nM ,:)=0;    
    Canvas(:, nC+1:nC+nM ,:)=IMosaic;

    %% add frame no in text
    str_info1=sprintf('FrameNo -> %04d\n%s', frame_no, str_info);
    Canvas = insertText(uint8(Canvas), [100 mF+100 ], str_info1, 'AnchorPoint', 'LeftTop', 'fontSize', fontSize, 'BoxColor', 'black', 'TextColor', 'white'); %1800      
 
    %% add motion frame on canvas
    Canvas(mF*2+100+1: mF*2+100+mMt, 1:nMt, :)=IMotion;
    
    fname=sprintf('AA_%06d.png', i-1);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8(Canvas),fname_wpath);  
    i=i+1;
    j=j+1;
    frame_no=frame_no+1;
end

fprintf('\n');
end
