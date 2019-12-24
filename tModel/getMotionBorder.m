%-- Main: TranslationalMosaicModel_NCC_Feature.m
%-- Author: Rumana Aktar, 12/14/19
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Main: TranslationalMosaicModel_NCC_Feature.m
%-- Author: Rumana Aktar, 12/14/19
%--------------------------------------------------------------------------
%--save xy location of intermediate mosaics: col(x)-row(y) fashion
%--uses xy locatons and Frames to produce iMosaics
%--produces border around current frames
%--if border==0, no border, 
%--if border==1, border for current frame only,
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function getMotionBorder(MM, xy, dirname, iMosaicDirname, Fm, Fn, FrameDir, filesFrame, border, line, motionOnImosaic, sameIMosaicDir, dirnameOutMotion)

%dirnameOutMotion=sprintf('%sMotionMap/',dirname); 
mkdir(dirnameOutMotion);
filesIMosaic = dir(fullfile(iMosaicDirname,'iM*.png'));

if sameIMosaicDir==1
    dirnameOutMotionMosaic=iMosaicDirname;
else
    dirnameOutMotionMosaic=sprintf('%siMosaicMotion/',dirname); mkdir(dirnameOutMotionMosaic);
end
[M,N, ~]=size(MM);

%% border control
clist=colormap(jet(size(xy,1)));
clist=clist*255;

%% first mosaic
iMosaic=zeros(M,N,3); mosaicLast=iMosaic; mosaicLastLast=iMosaic; mosaicEdge=iMosaic; mask=zeros(M,N,3); prevMask=mask; prevprevMask=mask;
for i=1:size(xy)
    fprintf('\nGenerating Motion Map for frame = %d', i);      

    %% get the next iMosaic
    Fr=imread(fullfile(FrameDir, filesFrame(i).name));
    iMosaicBlended=imread(fullfile(iMosaicDirname, filesIMosaic(i).name));
    
    m1=xy(i,2); m2=m1+Fm-1;
    n1=xy(i,1); n2=n1+Fn-1;       
    iMosaic(m1:m2, n1:n2, :)=Fr;
    mask(m1:m2, n1:n2, :)=1;
    

    %% if we want to see motion
    if i==1
        mosaicLastLast=iMosaic;
        Motion=iMosaic;
    elseif i==2
        mosaicLast=iMosaic;
        Motion=iMosaic;
        prevMask=mask;
    else
        Motion=zeros(size(iMosaic));
        Motion(:,:,1)=mosaicLastLast(:,:,1);
        Motion(:,:,2)=mosaicLast(:,:,2);
        Motion(:,:,3)=iMosaic(:,:,3);
        
%         %% for remove nonOverlapping region in consecutive 3 frames
%         commonMask=prevprevMask;
%         %Motion(commonMask==0)=0;
%         %% for remove nonOverlapping region in consecutive 3 frames
        
        mosaicLastLast=mosaicLast;
        mosaicLast=iMosaic;  
        prevprevMask=prevMask;
        prevMask=mask;
        
        %imshow(uint8([commonMask*255 iMosaic]))
    end
    
    

    %% border control
    m1_m=max(1, m1-line); m1_p=min(M, m1+line);
    m2_m=max(1, m2-line); m2_p=min(M, m2+line);

    n1_m=max(1, n1-line); n1_p=min(N, n1+line);
    n2_m=max(1, n2-line); n2_p=min(N, n2+line);

    %% if you want to show motion on top of iMosaicBlended
    if motionOnImosaic==1
        iMosaicBrd=Motion;
    else
        iMosaicBrd=iMosaicBlended;
    end
    
    %% add borders
    iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 3)=clist(i, 3);
    iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 3)=clist(i, 3);
    iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 3)=clist(i, 3);
    iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 3)=clist(i, 3);
    
    
    if border==0 
        if motionOnImosaic==0
            ; %% nothing to do
        else
            iMosaicBlended(m1:m2, n1:n2, :)=Motion(m1:m2, n1:n2, :);
        end
        MotionFr=Motion(m1:m2, n1:n2, :);
    elseif border==1
        iMosaicBlended(m1_m:m2_p, n1_m:n2_p, :)=iMosaicBrd(m1_m:m2_p, n1_m:n2_p, :);
        %MotionFr=Motion(m1:m2, n1:n2, :);               %--individual motionFr without border
        MotionFr=iMosaicBrd(m1_m:m2_p, n1_m:n2_p, :);    %--individual motionFr with border
        
%         if i>=3
%             %% for remove nonOverlapping region in consecutive 3 frames
%             iMosaicROI=iMosaicBlended(m1_m:m2_p, n1_m:n2_p, :);
%             commonMaskROI=commonMask(m1_m:m2_p, n1_m:n2_p, :);
%             iMosaicBrdROI=iMosaicBrd(m1_m:m2_p, n1_m:n2_p, :);
%             iMosaicROI(commonMaskROI==1)=0;
%             iMosaicBrdROI(commonMaskROI==0)=0;
%             iMosaicROI=iMosaicROI+uint8(iMosaicBrdROI);
%             iMosaicBlended(m1_m:m2_p, n1_m:n2_p, :)=iMosaicROI;
%             %% for remove nonOverlapping region in consecutive 3 frames
%             imshow(uint8([prevprevMask*255 iMosaicBlended]))
%         end
        

    end
    
    %% save iMosaicBlended
    fname=sprintf('%s',filesIMosaic(i).name);
    fname_wpath=fullfile(dirnameOutMotionMosaic,fname);
    imwrite(uint8(iMosaicBlended), fname_wpath);

    
%     %% just for saving the motion part frame seperately
%     Im=iMosaicBrd(m1:m2, n1:n2, :);
%     %str=sprintf('%d: %6.5f %d', i, xy(i,9)-xy(i,8), xy(i,12)-xy(i,11));
%     str=sprintf('Frame_%04d',i);
%     Im=insertText(uint8(Im), [size(Im,2), 1], str,'AnchorPoint', 'RightTop', 'fontSize', 30);
    
    %% save motion on raw frame
    fname=sprintf('Motion_%06d.png', i);
    fname_wpath=fullfile(dirnameOutMotion,fname);
    imwrite(uint8(MotionFr),fname_wpath);    
    
    %


end
% fname=sprintf('%s%s','Motion_',filesFrame(i).name);
% fname_wpath=fullfile(dirnameOutMotion,fname);
% imwrite(uint8([iMosaic]), fname_wpath);
     
end

