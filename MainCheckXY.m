clc; clear all;

dir='/Volumes/F/Courses/MesenteryData/ABQ_Synthetic_blur2_alt/';
xyFrame=dlmread(sprintf('%sxy_wrt_F_000000.txt', dir));
xyMosaic=dlmread(sprintf('%sNCC_60_100_150x200/xy_blur_edge.txt', dir)); %xy_blur_edge
xyMosaic=xyMosaic(:,1:2);

diffXY=xyFrame-xyMosaic;

for i=1:size(diffXY,1)
    if xyFrame(i,1)~=xyMosaic(i,1) || xyFrame(i,2)~=xyMosaic(i,2)
        fprintf('Difference found at location i=%d, Frame=%d,%d, Mosaic=%d,%d\n', i, xyFrame(i,1), xyFrame(i,2), xyMosaic(i,1), xyMosaic(i,2));
    end
end
