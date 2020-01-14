%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Main: getImosaicsImproved.m
%-- Author: Rumana Aktar, 12/14/19
%--------------------------------------------------------------------------
%--generates iMosaic with specific blending type
%--blendingMetric==blurMetric; blurMetric: xy(ii, 9)==1 means pixel ADD, xy(i, 9)==0 means pixel REP
%--blendingMetric==EdgeRes; EdgeRes: xy(i, 12)==1 means pixel ADD, xy(i, 12)==0 means pixel REP
%--blendingMetric==REP: means pixel REP
%--blendingMetric==ADD: means pixel ADD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function getImosaicsImproved(MM, xy, dirname, Fm, Fn, FrameDir, filesFrame, blendingMetric, dirnameOut)
    
    %% output mosaicL and maskL directory
    mkdir(dirnameOut);
    
     
    %% first mosaic
    iMosaic=zeros(size(MM));
    mask=iMosaic; 
    prevMask=mask;
    
    %% get first frame and first iMosaic
    i=1;
    Fr=imread(fullfile(FrameDir, filesFrame(i).name));
    m1=xy(i,2); m2=m1+Fm-1;
    n1=xy(i,1); n2=n1+Fn-1;       
    iMosaic(m1:m2, n1:n2, :)=Fr;
    
    
    %% add frame number and save iMosaics
    %str=sprintf('%d: %6.5f %d', i, xy(i,9)-xy(i,8), xy(i,12)-xy(i,11));
    str=sprintf('Frame_%04d',i);
    %Iout=insertText(uint8(iMosaic), [size(iMosaic,2), 1], str,'AnchorPoint', 'RightTop', 'fontSize', 60);
    fname=sprintf('iMosaic_%06d.png', i-1);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8(iMosaic),fname_wpath);   
   
    
    %% loop over
    for i=2:size(xy)
        fprintf('\nGenerating iMosaics for frame = %d', i);
        
        %% get the next iMosaic
        Fr=imread(fullfile(FrameDir, filesFrame(i).name)); %--read next frame
        m1=xy(i,2); m2=m1+Fm-1;                            %--get positions
        n1=xy(i,1); n2=n1+Fn-1;                            %--get positions
        
        if isnan(xy(i,1)) || isnan(xy(i,2))
            continue;
        end
        
        %% update mask and iMosaics
        mask(m1:m2, n1:n2, :)=1;                         %--update mask
        newPixels=mask-prevMask;                         %--new pixels being added
        newPixels=newPixels(m1:m2, n1:n2, :);            %--new pixels ROI

        %if xy(i,10)> xy(i,11)                            %--xy(:,10)=edgeResponse of Frame, xy(:,11)=edgeResponse of Canvas
        if (strcmp(blendingMetric, 'EdgeRes')==1 && xy(i,12)==0) || (strcmp(blendingMetric, 'blurMetric')==1 && xy(i,9)==0) || strcmp(blendingMetric, 'REP')==1
            iMosaic(m1:m2, n1:n2, :)=Fr;                 %--Hence PixelREP; FrameROI edgeResponse is better than canvasROI edgeResponse;            
        else
            FrameADD=Fr;                                 %--Hence PixelADD; canvasROI edgeResponse is better than frameROI edgeResponse;            
            canvasROI=iMosaic(m1:m2, n1:n2, :);          %--canvasROI          
            canvasROI(newPixels==1)=0;                   %--consider only canvasROI commonPixels
            FrameADD(newPixels==0)=0;                    %--consider only frameROI newPixels
            canvasROI=uint8(canvasROI)+FrameADD;         %--update canvasROI with pixelADD
            iMosaic(m1:m2, n1:n2, :)=uint8(canvasROI);   %--update mosaicEdge
        end              
        prevMask=mask;                                   %--update prevMask for next iteratiton
        
%         %% save Imosaics
%         fname=sprintf('iMosaic_%06d.png', i-1);
%         fname_wpath=fullfile(dirnameOut,fname);
%         imwrite(uint8(iMosaic),fname_wpath);         
    end
end


