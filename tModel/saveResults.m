function saveResults(i, no_Frames, tx_ty, xy, dirnameOut, XY_Single_Multi, mosaic, ADD, mosaicADD, AVG, mosaicAVG, mosaicEdge, BLURM, mosaicBLUR)

    %%----Translation tx, ty
    plot(1:no_Frames, tx_ty(:,2), 'ro--', 1:no_Frames, tx_ty(:,3), 'b+--');
    legend('tx', 'ty');
    print(sprintf('%sTranslation', dirnameOut), '-dpng');

    %%----No of Inliers
    plot(1:no_Frames, xy(:, 6), 'b+--');
    legend('No of Inliers');
    print(sprintf('%sNoInliers', dirnameOut), '-dpng');

    %%----Inliers Histogram
    %dirnameOut=mosaicDir;
    histogram(xy(:,6));
    %set(gca, 'YScale', 'log')
    xlim([0 9])
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
    print(sprintf('%sInliersHistogram', dirnameOut), '-dpng');

    %% save xy location of intermediate mosaics: col(x)-row(y) fashion
    dlmwrite(sprintf('%sxy.txt',dirnameOut), xy(1:end, :));
    dlmwrite(sprintf('%sXY_Single_Multi.txt',dirnameOut), XY_Single_Multi);

    %% write output image
    fname=sprintf('MosaicREP_%06d.png', i);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8(mosaic),fname_wpath); 

    %% write output mosaic using EDGE metric
    fname=sprintf('MosaicEDGE_%06d.png', i);
    fname_wpath=fullfile(dirnameOut,fname);
    imwrite(uint8(mosaicEdge),fname_wpath); 

    bd=ones(size(mosaicEdge,1), 20, 3)*255;
    if AVG==1 && ADD==1 && BLURM==1
     %% write output mosaic using EDGE, BLUR, REP, ADD
        fname=sprintf('MosaicMulti_EDGE_BLUR_REP_ADD_AVG_%06d.png', i);
        fname_wpath=fullfile(dirnameOut,fname);
        imwrite(uint8([mosaicEdge bd mosaicBLUR bd mosaic bd mosaicADD bd mosaicAVG]),fname_wpath); 

    elseif ADD==1 && BLURM==1
        %% write output mosaic using EDGE, BLUR, REP, ADD
        fname=sprintf('MosaicMulti_EDGE_BLUR_REP_ADD_%06d.png', i);
        fname_wpath=fullfile(dirnameOut,fname);
        imwrite(uint8([mosaicEdge bd mosaicBLUR bd mosaic bd mosaicADD]),fname_wpath); 
    elseif BLURM==1
        %% write output mosaic using EDGE, BLUR, REP, ADD
        fname=sprintf('MosaicMulti_EDGE_BLUR_REP_%06d.png', i);
        fname_wpath=fullfile(dirnameOut,fname);
        imwrite(uint8([mosaicEdge mosaicBLUR mosaic]),fname_wpath); 
    else
        %% write output mosaic using EDGE, BLUR, REP, ADD
        fname=sprintf('MosaicMulti_EDGE_REP_%06d.png', i);
        fname_wpath=fullfile(dirnameOut,fname);
        imwrite(uint8([mosaicEdge mosaic]),fname_wpath); 
    end

    if ADD==1
        %% write output image
        fname=sprintf('MosaicADD_%06d.png', i);
        fname_wpath=fullfile(dirnameOut,fname);
        imwrite(uint8(mosaicADD),fname_wpath); 
    end

    if AVG==1
        %% write output image
        fname=sprintf('MosaicAVG_%06d.png', i);
        fname_wpath=fullfile(dirnameOut,fname);
        imwrite(uint8(mosaicAVG),fname_wpath);   
    end

    if BLURM==1
        %% write output mosaic using BLUR metric
        fname=sprintf('MosaicBLUR_%06d.png', i);
        fname_wpath=fullfile(dirnameOut,fname);
        imwrite(uint8(mosaicBLUR),fname_wpath); 
    end

end