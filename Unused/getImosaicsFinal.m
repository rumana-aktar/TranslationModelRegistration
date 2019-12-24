%% save xy location of intermediate mosaics: col(x)-row(y) fashion
%% uses xy locatons and Frames to produce iMosaics
%%
function getImosaicsFinal(MM, xy, dirname, Fm, Fn, FrameDir, filesFrame)
    
    %% output mosaicL and maskL directory
    dirnameOutMosaic=sprintf('%sMosaicL/',dirname); mkdir(dirnameOutMosaic);
    
    [M,N, ~]=size(MM)
    
    %% first mosaic
    iMosaic=zeros(M,N,3);
    
    for i=1:size(xy)
        i        
        m1=xy(i,2); m2=m1+Fm-1;
        n1=xy(i,1); n2=n1+Fn-1;
        
        %[m1 m2 M n1 n2 N]
        Fr=imread(fullfile(FrameDir, filesFrame(i).name));
        iMosaic(m1:m2, n1:n2, :)=Fr;
        
        %% write output image
        fname=sprintf('Mosaic_%06d.png', i);
        fname_wpath=fullfile(dirnameOutMosaic,fname);
        imwrite(uint8(iMosaic),fname_wpath); 
        
    end
    
end

