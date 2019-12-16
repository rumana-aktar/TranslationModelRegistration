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
%--if border==2, border for all frames together
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function getImosaicsColoredBorderFinal(MM, xy, dirname, Fm, Fn, FrameDir, filesFrame, border, line, motionBorderTogether)
    
%% output mosaicL and maskL directory
dirnameOutMosaic=sprintf('%sMosaicL/',dirname); mkdir(dirnameOutMosaic);

dirnameOutMotion=sprintf('%sMosaicMotion/',dirname); mkdir(dirnameOutMotion);


[M,N, ~]=size(MM)


%% border control
clist=colormap(jet(size(xy,1)));
clist=clist*255;

%% first mosaic
iMosaic=zeros(M,N,3); mosaicLast=iMosaic; mosaicLastLast=iMosaic;
for i=1:size(xy)
    i       

    %% get the next iMosaic
    Fr=imread(fullfile(FrameDir, filesFrame(i).name));
    m1=xy(i,2); m2=m1+Fm-1;
    n1=xy(i,1); n2=n1+Fn-1;       
    iMosaic(m1:m2, n1:n2, :)=Fr;


    %% if we want to see motion
    if i==1
        mosaicLastLast=iMosaic;
        Motion=iMosaic;
    elseif i==2
        mosaicLast=iMosaic;
        Motion=iMosaic;
    else
        Motion=zeros(size(iMosaic));
        Motion(:,:,1)=mosaicLastLast(:,:,1);
        Motion(:,:,2)=mosaicLast(:,:,2);
        Motion(:,:,3)=iMosaic(:,:,3);

        %Motion=imresize(Motion, 2);
        if motionBorderTogether==0
            fname=sprintf('%s%s','Motion_',filesFrame(i).name);
            fname_wpath=fullfile(dirnameOutMotion,fname);
            imwrite(uint8(Motion), fname_wpath);
        end
        mosaicLastLast=mosaicLast;
        mosaicLast=iMosaic;

    end
    


    %% border control
    m1_m=max(1, m1-line); m1_p=min(M, m1+line);
    m2_m=max(1, m2-line); m2_p=min(M, m2+line);

    n1_m=max(1, n1-line); n1_p=min(N, n1+line);
    n2_m=max(1, n2-line); n2_p=min(N, n2+line);

    if motionBorderTogether==1
        iMosaicBrd=Motion;
    else
        iMosaicBrd=iMosaic;
    end

    iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 3)=clist(i, 3);
    iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 3)=clist(i, 3);
    iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 3)=clist(i, 3);
    iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 3)=clist(i, 3);
    %imshow(uint8(iMosaic));
    %%border control

    %% write output image
    fname=sprintf('Mosaic_%06d.png', i);
    fname_wpath=fullfile(dirnameOutMosaic,fname);
    
    

    if border==0
        imwrite(uint8(iMosaic),fname_wpath);         
    elseif border==1 || border ==2
        imwrite(uint8(iMosaicBrd),fname_wpath);         
    end

    if border==2
        iMosaic=iMosaicBrd;
    end

    %% just for saving the motion part frame seperately
    fname=sprintf('Motion_%06d.png', i);
    fname_wpath=fullfile(dirnameOutMotion,fname);
    imwrite(uint8(iMosaicBrd(m1:m2, n1:n2, :)),fname_wpath);         



end
%     %% write output image
%     fname=sprintf('Mosaic_%06d.png', i);
%     fname_wpath=fullfile(dirnameOutMosaic,fname);
%     imwrite(uint8(iMosaicBrd),fname_wpath); 

    
end


