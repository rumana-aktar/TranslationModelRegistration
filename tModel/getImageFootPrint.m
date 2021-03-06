%-- Main: getImageFootPrint.m
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

function getImageFootPrint(MM, xy, mosaicDir, Fm, Fn, FrameDir, filesFrame, line, onFrame)    
    
    [M,N, ~]=size(MM);    

    %% border control
    clist=colormap(jet(size(xy,1)));
    clist=clist*255;

    %% first mosaic
    iMosaic=zeros(M,N,3); 
    for i=1:size(xy)
        i       

        %% get the next iMosaic
        Fr=imread(fullfile(FrameDir, filesFrame(i).name));
        m1=xy(i,2); m2=m1+Fm-1;
        n1=xy(i,1); n2=n1+Fn-1;       
        iMosaic(m1:m2, n1:n2, :)=Fr;

        %% border control
        m1_m=max(1, m1-line); m1_p=min(M, m1+line);
        m2_m=max(1, m2-line); m2_p=min(M, m2+line);

        n1_m=max(1, n1-line); n1_p=min(N, n1+line);
        n2_m=max(1, n2-line); n2_p=min(N, n2+line);
        
        if onFrame==1
           iMosaicBrd=iMosaic;
        end

        iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m1_p, n1_m:n2_p, 3)=clist(i, 3);
        iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m2_m:m2_p, n1_m:n2_p, 3)=clist(i, 3);
        iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m2_p, n1_m:n1_p, 3)=clist(i, 3);
        iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 1)=clist(i, 1); iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 2)=clist(i, 2); iMosaicBrd(m1_m:m2_p, n2_m:n2_p, 3)=clist(i, 3);
        iMosaic=iMosaicBrd;

    end

    %% write output image
    fname=sprintf('Footprint_%06d_%d.png', i, onFrame);
    fname_wpath=fullfile(mosaicDir,fname);
    imwrite(uint8(iMosaicBrd),fname_wpath); 
    
end


