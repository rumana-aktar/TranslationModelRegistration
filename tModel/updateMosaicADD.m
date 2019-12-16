function mosaicADD=updateMosaicADD(Frame, mask, prevMask, xbegin, ybegin, xend, yend, mosaicADD)
    %Frame=Frame_org;
    newPixels=mask-prevMask;

    newPixels=newPixels(ybegin:yend, xbegin:xend);        
    F1=Frame(:,:,1); F2=Frame(:,:,2); F3=Frame(:,:,3);
    F1(newPixels==0)=0; F2(newPixels==0)=0; F3(newPixels==0)=0;
    Frame(:,:,1)=F1; Frame(:,:,2)=F2; Frame(:,:,3)=F3;
    %imshow(uint8([mosaic(ybegin:yend, xbegin:xend, 1) Frame(:,:,1) mask(ybegin:yend, xbegin:xend)*255 newPixels*255 mosaicADD(ybegin:yend, xbegin:xend)]))
    mosaicADD(ybegin:yend, xbegin:xend, :)=mosaicADD(ybegin:yend, xbegin:xend, :)+Frame;

end