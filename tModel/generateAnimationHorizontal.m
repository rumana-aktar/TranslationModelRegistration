function generateAnimationHorizontal(frameScale, dirnameFrame, dirnameMosaic, dirnameMotion, dirnameOut, xy, seqNo, frameRate)

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
    lines=10;


    if seqNo==3
        seq_name='Sequence Name -> VTS_01_3.VOB'; %seq3
        start_time='Start Time -> 16:48:05:92'; %seq3
        end_time='End Time -> 16:52:03:65'; %seq3
        time_intv='Time Interval -> 00:3:57:73'; %seq3
        frame_no=728;
    elseif seqNo==4
        seq_name='Sequence Name -> VTS_01_4.VOB'; %seq4
        start_time='Start Time -> 16:52:09:60'; %seq4
        end_time='End Time -> 16:54:14:78'; %seq4
        time_intv='Time Interval -> 00:02:05:18'; %seq4
        frame_no=1;
    elseif seqNo==5
        seq_name='Sequence Name -> VTS_01_5.VOB'; %seq5
        start_time='Start Time -> 16:54:43:32'; %seq5
        end_time='End Time -> 16:57:21:86'; %seq5
        time_intv='Time Interval -> 00:02:38:54'; %seq5
        frame_no=1;
    end
    
    if frameRate==6
        frame_rate='Frame Rate -> 6(30)';
        frame_increase=5;
        if seqNo==3
            frame_no=728*5;
        end
    else
        frame_rate='Frame Rate -> 30';
        frame_increase=1;
    end
    
    date='Date -> 07-24';
    frame_size='Frame Size -> 720x480';
    str_info=sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s', seq_name, start_time, end_time, time_intv, date, frame_rate, frame_size)
    fontSize=40;
    text_x=20; text_y=50 ;



    
    j=1;
    i=1;
    while (i<=size(filesMosaic,1))
        fprintf('\nGenerating Horizontal Animation for frame = %d', i);      

        %% read iMosaic
        IMosaic = imread(fullfile(dirnameMosaic, filesMosaic(i).name)); 

        %% read frame and upscale it
        IFrame = imread(fullfile(dirnameFrame, filesFrame(j).name)); 
        IFrame = imresize(IFrame, frameScale);    [mF, nF, ~]=size(IFrame);
        %--add 
        str=sprintf('Frame_%04d', frame_no);
        IFrame=insertText(uint8(IFrame), [1, 1], str,'AnchorPoint', 'LeftTop', 'fontSize', fontSize+10);
       

        %% read motion and upscale it
        IMotion = imread(fullfile(dirnameMotion, filesMotion(j).name)); 
        IMotion = imresize(IMotion, frameScale);    [mMt, nMt, ~]=size(IMotion);

        %% rotate the iMosaic
        IMosaic=permute(IMosaic,[2 1 3]);   [mM, nM, ~]=size(IMosaic); IMosaicT=zeros(size(IMosaic));
        IMosaicT=IMosaic;

        %% add white border
        IMosaicT(end+1: end+lines, :)=255;    
        [mM, nM, ~]=size(IMosaicT);    

        %% add Frame below
        IMosaicT(mM+1:mM+mMt, :, :)=0;    
        IMosaicT(mM+1:mM+mF, 1:nF, :)=IFrame;  

        %% add Motion Frame below
        IMosaicT(mM+1:mM+mMt, size(IMosaicT,2)-nMt+1:size(IMosaicT,2), :)=IMotion;      

        %% add text
        str_info1=sprintf('FrameNo -> %04d\n%s', frame_no, str_info);
        IMosaicT = insertText(uint8(IMosaicT), [nF+text_x mM+lines+text_y ], str_info1, 'AnchorPoint', 'LeftTop', 'fontSize', fontSize, 'BoxColor', 'black', 'TextColor', 'white'); %1800      

        fname=sprintf('AA_%06d.png', i-1);
        fname_wpath=fullfile(dirnameOut,fname);
        imwrite(uint8(IMosaicT),fname_wpath);  
        i=i+1;
        j=j+1;
        frame_no=frame_no+frame_increase;
    end
    
fprintf('\n');
end