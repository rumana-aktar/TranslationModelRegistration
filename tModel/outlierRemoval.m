function [mean_x, mean_y]=outlierRemoval(I1, I2, coords1, coords2, save_tx_ty)
    
    
    motion(:,1)=coords1(:,1)-coords2(:,1);
    motion(:,2)=coords1(:,2)-coords2(:,2);
    
    
    I=showMatchedFeatures(I1,I2,coords1,coords2);%,'montage','Parent',ax);
        

    if size(motion,1)==0
        motion=[1 1];
    end
    if save_tx_ty==1
        %% save motions after oultier removals
        close all
        
        plot(motion(:,1), 'r*'); 
        %text(size(motion,1),max(motion(:,1)),strcat(sprintf('Fr_%4d',i)),'HorizontalAlignment','right', 'FontSize' ,14);
        title(sprintf('ATx: Frame=%04d, #features=%d, Range=%d', i, size(motion,1), round(max(motion(:,1))-min(motion(:,1)))));
        print(sprintf('%sXAfterOR_%06d', dirnameOutMotion, i), '-dpng')
        
        close all; plot(motion(:,2), 'b+');
        title(sprintf('ATy: Frame=%04d, #features=%d, Range=%d', i, size(motion,1), round(max(motion(:,2))-min(motion(:,2)))));
        %text(size(motion,1),max(motion(:,2)),strcat(sprintf('Fr_%4d',i)),'HorizontalAlignment','right', 'FontSize' ,14);
        print(sprintf('%sYAfterOR_%06d', dirnameOutMotion, i), '-dpng')

    end
   
    
    mean_x=mean(motion(:,1));
    mean_y=mean(motion(:,2));
    
    
    
    no_matched=size(motion,1);
    
end