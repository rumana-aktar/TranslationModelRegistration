function [xbeginFrame, ybeginFrame, matching_score, xySingleMulti]=getTranslationPrevFrame(NCC, template_row_start, template_hight, template_col_start, template_width, Frame, prevFrame, saved_matched_Points, save_tx_ty, i, dirnameOutFeatureMatched, dirnameOutMotion, SURF_Feature_Mean_Mode)

    xySingleMulti=[];
    if NCC == 1
        
        %% --------------------------------------------------------------------    
        %--find NCC from multiple template
        [xbeginFrameM, ybeginFrameM, points]=get_tx_ty_multiTemplate(Frame, prevFrame);
        index1=getOutliersRANSAC(points(:, 5), 500, 2);
        index2=getOutliersRANSAC(points(:, 6), 500, 2);
        index=union(index1, index2);
        in_index=1:size(points,1);in_index(index)=[];
        
        xbeginFrameM=mean(points(in_index, 5));
        ybeginFrameM=mean(points(in_index, 6));

        
%         %% --------------------------------------------------------------------    
%         blocStep=80;    searchWin=200; imgName=i; reference_frame=i-1; FeatureMatchedSave=1; FileDir=dirnameOutFeatureMatched;
%         [referencePoints, inputPoints]=getHomographyMatrix(rgb2gray(prevFrame), rgb2gray(Frame), blocStep, searchWin, imgName, reference_frame, FeatureMatchedSave, FileDir);
%         save_tx_ty=0;
%         [mean_x, mean_y]=outlierRemoval(rgb2gray(prevFrame), rgb2gray(Frame), referencePoints, inputPoints, save_tx_ty);
        
        %% --------------------------------------------------------------------    
        %--find NCC from single template matching        
        template=Frame(template_row_start+1:template_row_start+template_hight, template_col_start+1:template_col_start+template_width, :);
            c = normxcorr2(template(:,:,1),prevFrame(:,:,1));%figure, surf(c), shading flat    
        [max_c, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        corr_offset = [(xpeak-size(template,2)) 
                       (ypeak-size(template,1))];                   
        matching_score=max_c;          
        %--[xbeginFrame, ybeginFrame] is wrt to Frame,  [round(corr_offset(1)+ 1), round(corr_offset(2)+ 1)] is wrt to template    
        xbeginFrame=round(corr_offset(1)+ 1) - template_col_start;
        ybeginFrame=round(corr_offset(2)+ 1) - template_row_start; 
        
        
        
        xySingleMulti=round([i  xbeginFrame ybeginFrame xbeginFrameM ybeginFrameM ]);
        xbeginFrame=round(xbeginFrameM);
        ybeginFrame=round(ybeginFrameM);
        
        if size(in_index,2)<2
            xbeginFrame=NaN;
            ybeginFrame=NaN;
        end
        
        
    else
        [mean_ix, mean_iy, mode_ix, mode_iy, matching_score]=getTranslation(rgb2gray(prevFrame), rgb2gray(Frame), saved_matched_Points,save_tx_ty, i, dirnameOutFeatureMatched, dirnameOutMotion);    
        
        if SURF_Feature_Mean_Mode==0
            xbeginFrame=round(mode_ix+1);
            ybeginFrame=round(mode_iy+1);
        else
            xbeginFrame=round(mean_ix+1);
            ybeginFrame=round(mean_iy+1);
        end
    end
end