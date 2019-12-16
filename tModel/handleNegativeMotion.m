function [mosaic, mask, prevMask, xbegin, ybegin, mosaicADD, mosaicAVG, xy]=handleNegativeMotion(mosaic, mask, prevMask, xbegin, ybegin, ADD, mosaicADD, AVG, mosaicAVG, xy)

%% if xbegin and ybegin turn out to be negative
if xbegin<1
    mosaic=[zeros(size(mosaic,1), -xbegin+1, 3) mosaic];
    prevMask=[zeros(size(prevMask,1), -xbegin+1)  prevMask];
    mask=[zeros(size(mask,1), -xbegin+1)  mask];

    %% for retriveing global indexes later
    for j=1:size(xy,1)
        xy(j,1)=xy(j,1)-xbegin+1;
    end 
    if ADD==1;  mosaicADD=[zeros(size(mosaicADD,1), -xbegin+1, 3) mosaicADD]; end;
    if AVG==1;  mosaicAVG=[zeros(size(mosaicAVG,1), -xbegin+1, 3) mosaicAVG]; end;

    xbegin=1;


end
if ybegin<1
    mosaic=[zeros(-ybegin+1, size(mosaic,2), 3); mosaic];
    mask=[zeros(-ybegin+1, size(mask,2)); mask];
    prevMask=[zeros(-ybegin+1, size(prevMask,2)); prevMask];

    %% for retriveing global indexes later
    for j=1:size(xy,1)
        xy(j,2)=xy(j,2)-ybegin+1;
    end
    if ADD==1; mosaicADD=[zeros(-ybegin+1, size(mosaicADD,2), 3); mosaicADD]; end;
    if AVG==1; mosaicAVG=[zeros(-ybegin+1, size(mosaicAVG,2), 3); mosaicAVG]; end;

    ybegin=1;

 end
    
end