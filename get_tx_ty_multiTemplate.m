function  [xbeginFrame, ybeginFrame, points]=get_tx_ty_multiTemplate(Frame, prevFrame)
    row=40; col=50;
    iFrame=Frame(row+1:end-row+1, col+1:end-col+1, :);
    [m,n,d]=size(iFrame);
    m_blck_size=floor(m/3);
    n_blck_size=floor(n/3);
    
    m_index=1:m_blck_size:m;
    n_index=1:n_blck_size:n;
    
    points=[];
    for i=m_index
        for j=n_index(1:end-1)
            [i j];
            [xbeginFrame, ybeginFrame]=getNccMatching(iFrame, prevFrame, i, m_blck_size, j, n_blck_size);            
            if xbeginFrame==-999 || ybeginFrame==-999
                ;
            else
                xbeginFrame=xbeginFrame-col;
                ybeginFrame=ybeginFrame-row;
                [xbeginFrame ybeginFrame];
                points=[points; [i+1 j+1 i+m_blck_size j+n_blck_size xbeginFrame ybeginFrame]];   
            end
        end
    end  
    
    xbeginFrame=mean(points(:,5));
    ybeginFrame=mean(points(:,6));

end

function [xbeginFrame, ybeginFrame]=getNccMatching(Frame, prevFrame, template_row_start, template_hight, template_col_start, template_width)
    
    [M,N,~]=size(Frame);
    if template_row_start+1>=1 && template_row_start+template_hight<=M && template_col_start+1>=1 && template_col_start+template_width<=N
        template=Frame(template_row_start+1:template_row_start+template_hight, template_col_start+1:template_col_start+template_width, :);
        c = normxcorr2(template(:,:,1),prevFrame(:,:,1));%figure, surf(c), shading flat    
        [max_c, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        corr_offset = [(xpeak-size(template,2)) 
                       (ypeak-size(template,1))];                   
        matching_score=max_c;          
        %--[xbeginFrame, ybeginFrame] is wrt to Frame,  [round(corr_offset(1)+ 1), round(corr_offset(2)+ 1)] is wrt to template    
        xbeginFrame=round(corr_offset(1)+1) - template_col_start;
        ybeginFrame=round(corr_offset(2)+1) - template_row_start; 
    else
        xbeginFrame=-999;
        ybeginFrame=-999;
    end
end