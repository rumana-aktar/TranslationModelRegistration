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
iMosaic=zeros(M,N,3); mosaicLast=iMosaic; mosaicLastLast=iMosaic; mosaicEdge=iMosaic; mask=zeros(M,N,3); prevMask=mask; prevprevMask=mask; pppMask=mask;
for i=1:size(xy)
    fprintf('\nGenerating Motion Map for frame = %d', i);  
    
    if i==45
        br=1;
    end

    %% get the next iMosaic
    Fr=imread(fullfile(FrameDir, filesFrame(i).name));
    iMosaicBlended=imread(fullfile(iMosaicDirname, filesIMosaic(i).name));
%     xx=iMosaicBlended;
%     if border==2
%         iMosaicBrd=iMosaicBlended;
%     end
    
    if isnan(xy(i,1)) || isnan(xy(i,2))
            continue;
    end
    
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
    elseif i==3
        mosaicLast=iMosaic;
        Motion=iMosaic;
        prevprevMask=prevMask;
        prevMask=mask;
    else
        Motion=zeros(size(iMosaic));
        Motion(:,:,1)=mosaicLastLast(:,:,1);
        Motion(:,:,2)=mosaicLast(:,:,2);
        Motion(:,:,3)=iMosaic(:,:,3);
        
        %% for remove nonOverlapping region in consecutive 3 frames        
        mosaicLastLast=mosaicLast;
        mosaicLast=iMosaic;  
        prevprevMask=prevMask;
        prevMask=mask;
        Motion(pppMask==0)=0;
        %imshow(uint8([commonMask*255 iMosaic]))
    end
    
    

    %% border control
    m1_m=max(1, m1-line); m1_p=min(M, m1+line);
    m2_m=max(1, m2-line); m2_p=min(M, m2+line);

    n1_m=max(1, n1-line); n1_p=min(N, n1+line);
    n2_m=max(1, n2-line); n2_p=min(N, n2+line);
    
    iMosaicBlended(m1_m:m2_p, n1_m:n2_p, :)=Motion(m1_m:m2_p, n1_m:n2_p, :);    
    if border==1
        %% add borders
        iMosaicBrd=iMosaicBlended;
        iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 3)=clist(i, 3);
        iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 3)=clist(i, 3);
        iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 3)=clist(i, 3);
        iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 3)=clist(i, 3);
        iMosaicBlended(m1_m:m2_p, n1_m:n2_p, :)=iMosaicBrd(m1_m:m2_p, n1_m:n2_p, :);
    end
    MotionFr=iMosaicBrd(m1:m2, n1:n2, :);

    %% save iMosaicBlended
    fname=sprintf('%s',filesIMosaic(i).name);
    fname_wpath=fullfile(dirnameOutMotionMosaic,fname);
    %imwrite(uint8([pppMask*255 iMosaicBlended]), fname_wpath);
    imwrite(uint8([ iMosaicBlended]), fname_wpath);
    
    %% save motion on raw frame
    fname=sprintf('Motion_%06d.png', i-1);
    fname_wpath=fullfile(dirnameOutMotion,fname);
    imwrite(uint8(MotionFr),fname_wpath);    
    

    pppMask=prevprevMask;

end
% fname=sprintf('%s%s','Motion_',filesFrame(i).name);
% fname_wpath=fullfile(dirnameOutMotion,fname);
% imwrite(uint8([iMosaic]), fname_wpath);
     
end


