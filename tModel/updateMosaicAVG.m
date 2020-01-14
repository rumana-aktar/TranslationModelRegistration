function mosaicAVG=updateMosaicAVG(Frame, mask, prevMask, xbegin, ybegin, xend, yend, mosaicAVG)
    %--save iit for later
    Frame_org=Frame;
    
    newPixels=mask-prevMask;
    newPixels=newPixels(ybegin:yend, xbegin:xend);

    %% new Pixels are added here
    F1=Frame(:,:,1); F2=Frame(:,:,2); F3=Frame(:,:,3);
    F1(newPixels==0)=0; F2(newPixels==0)=0; F3(newPixels==0)=0;
    Frame(:,:,1)=F1; Frame(:,:,2)=F2; Frame(:,:,3)=F3;
    %imshow(uint8([mosaic(ybegin:yend, xbegin:xend, 1) Frame(:,:,1) mask(ybegin:yend, xbegin:xend)*255 newPixels*255 mosaicAVG(ybegin:yend, xbegin:xend)]))
    mosaicAVG(ybegin:yend, xbegin:xend, :)=mosaicAVG(ybegin:yend, xbegin:xend, :)+Frame;

    %% now take care of overlapping pixels 
    %% in new pixel region, both mosaicADD and Frame are same, average will still be same
    %% in overlapping region, they need to be averaged
    Frame=Frame_org;
    mosaicAVG(ybegin:yend, xbegin:xend, :)=uint8((0.5*mosaicAVG(ybegin:yend, xbegin:xend, :)+0.5*Frame));
end