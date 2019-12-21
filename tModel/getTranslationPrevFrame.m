function [xbeginFrame, ybeginFrame, matching_score]=getTranslationPrevFrame(NCC, template_row_start, template_hight, template_col_start, template_width, Frame, prevFrame, saved_matched_Points, save_tx_ty, i, dirnameOutFeatureMatched, dirnameOutMotion, SURF_Feature_Mean_Mode)

    if NCC == 1
        %% find NCC        
        template=Frame(template_row_start+1:template_row_start+template_hight, template_col_start+1:template_col_start+template_width, :);
    
        c = normxcorr2(template(:,:,1),prevFrame(:,:,1));%figure, surf(c), shading flat    
        [max_c, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        corr_offset = [(xpeak-size(template,2)) 
                       (ypeak-size(template,1))];
                   
        matching_score=max_c;           

        %% [xbeginFrame, ybeginFrame] is wrt to Frame,  [round(corr_offset(1)+ 1), round(corr_offset(2)+ 1)] is wrt to template    
        xbeginFrame=round(corr_offset(1)+ 1) - template_col_start;
        ybeginFrame=round(corr_offset(2)+ 1) - template_row_start; 
    else
        [mean_x, mean_y, mode_x, mode_y, mean_ix, mean_iy, mode_ix, mode_iy, matching_score]=getTranslation(rgb2gray(prevFrame), rgb2gray(Frame), saved_matched_Points,save_tx_ty, i, dirnameOutFeatureMatched, dirnameOutMotion);    
        
        if SURF_Feature_Mean_Mode==0
            xbeginFrame=round(mode_ix+1);
            ybeginFrame=round(mode_iy+1);
        else
            xbeginFrame=round(mean_ix+1);
            ybeginFrame=round(mean_iy+1);
        end
    end
end