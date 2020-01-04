function  [xbeginFrame, ybeginFrame, points3]=get_tx_ty_multiTemplate(Frame, prevFrame)
    row=40; col=50;
    iFrame=Frame(row+1:end-row+1, col+1:end-col+1, :);
    [m,n,d]=size(iFrame);
    m_blck_size=floor(m/3);
    n_blck_size=floor(n/3);
    
    m_blck_size=100;
    n_blck_size=200;
    
    m_index=1:m_blck_size:m;
    n_index=1:n_blck_size:n;
    
%     points=[];
%     for i=m_index
%         for j=n_index(1:end-1)
%             [i j];
%             [xbeginFrame, ybeginFrame]=getNccMatching(iFrame, prevFrame, i, m_blck_size, j, n_blck_size);            
%             if xbeginFrame==-999 || ybeginFrame==-999
%                 ;
%             else
%                 xbeginFrame=xbeginFrame-col;
%                 ybeginFrame=ybeginFrame-row;
%                 [xbeginFrame ybeginFrame];
%                 points=[points; [i+1 j+1 i+m_blck_size j+n_blck_size xbeginFrame ybeginFrame]];   
%             end
%         end
%    end  
%     
    %points
  
    points3=[];
    for i=m_index
        for j=n_index(1:end-1)
            [i j];
            [xbeginFrame, ybeginFrame]=getNccMatching3(Frame, prevFrame, i+row, i-1+m_blck_size+row, j+col, j-1+n_blck_size+col);            
            if xbeginFrame==-999 || ybeginFrame==-999
                ;
            else
                xbeginFrame=xbeginFrame;
                ybeginFrame=ybeginFrame;
                [xbeginFrame ybeginFrame];
                points3=[points3; [i+1 j+1 i+m_blck_size j+n_blck_size xbeginFrame ybeginFrame]];   
            end
        end
    end  
    
   
    %points3
    
    
%     if sum([points(:, [5 6])-points3(:, [5 6])])~=0
%         points(:, [5 6])
%         points3(:, [5 6])
%         br=1;
%     end

    xbeginFrame=mean(points3(:,5));
    ybeginFrame=mean(points3(:,6));

end

function [xbeginFrame, ybeginFrame]=getNccMatching3(Frame, prevFrame, m1, m2, n1, n2)
    
    %% --------------------------------------------------------------------
    %--parameter setting
    [M,N,~]=size(Frame);
    sw_x=160; sw_y=120; 
    [m1 m2 n1 n2];
    
    %% --------------------------------------------------------------------
    %--parameter setting
    mm1=max(1, m1-sw_y); mm2=min(M, m2+sw_y);
    nn1=max(1, n1-sw_x); nn2=min(N, n2+sw_x);
    %
   
    if  (mm1>=1 && mm2<=M && nn1>=1 && nn2<=N) && (m1>=1 && m2<=M && n1>=1 && n2<=N)
        template=Frame(m1:m2, n1:n2, :);
        c = normxcorr2(template(:,:,1),prevFrame(mm1:mm2, nn1:nn2, 1));   
        [max_c, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        corr_offset = [(xpeak-size(template,2)); (ypeak-size(template,1))];                   
        xbeginFrame=round(corr_offset(1)+1) - n1 + nn1;
        ybeginFrame=round(corr_offset(2)+1) - m1 + mm1;
        
        %[mm1 nn1 ybeginFrame  xbeginFrame ]
        
        dd=1;
    else
        xbeginFrame=-999;
        ybeginFrame=-999;
    end
end

function [xbeginFrame, ybeginFrame]=getNccMatching3_w(Frame, prevFrame, m1, m2, n1, n2)
    
    %% --------------------------------------------------------------------
    %--parameter setting
    [M,N,~]=size(Frame);
    sw_x=80; sw_y=10; 
    [m1 m2 n1 n2];
    
    %% --------------------------------------------------------------------
    %--parameter setting
    mm1=max(1, m1-sw_y); mm2=min(M, m2+sw_y);
    nn1=max(1, n1-sw_x); nn2=min(N, n2+sw_x);
    %(mm1>=1 && mm2<=M && nn1>=1 && nn2<=N) &&
   
    if  (m1>=1 && m2<=M && n1>=1 && n2<=N)
        template=Frame(m1:m2, n1:n2, :);
        c = normxcorr2(template(:,:,1),prevFrame(:,:, 1));   
        [max_c, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        corr_offset = [(xpeak-size(template,2)); (ypeak-size(template,1))];                   
        xbeginFrame=round(corr_offset(1)+1) - n1+1;
        ybeginFrame=round(corr_offset(2)+1) - m1+1; 
    else
        xbeginFrame=-999;
        ybeginFrame=-999;
    end
end


function [xbeginFrame, ybeginFrame]=getNccMatching(Frame, prevFrame, template_row_start, template_hight, template_col_start, template_width)
    
    %[template_row_start template_row_start+template_hight template_col_start template_col_start+template_width]

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

function [xbeginFrame, ybeginFrame]=getNccMatching2(Frame, prevFrame, m1, template_hight, n1, template_width)
    %% --------------------------------------------------------------------
    %--parameter setting
    [M,N,~]=size(Frame);
    sw_x=150; sw_y=150;     m2=m1+template_hight;     n2=n1+template_width;
    [m1 m2 n1 n2]
    
    %% --------------------------------------------------------------------
    %--parameter setting
    mm1=max(1, m1-sw_y); mm2=min(M, m2+sw_y);
    nn1=max(1, n1-sw_y); nn2=min(N, n2+sw_x);
    
    
    %% --------------------------------------------------------------------
    %--parameter setting
    if mm1>=1 && mm2<=M && nn1>=1 && nn2<=N
        template=Frame(m1+1:m2, n1+1:n2, :);
        c = normxcorr2(template(:,:,1),prevFrame(mm1:mm2, nn1:nn2, 1));  
        [max_c, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        corr_offset = [(xpeak-size(template,2)); (ypeak-size(template,1))];                   
        xbeginFrame=round(corr_offset(1)+1) - m1;
        ybeginFrame=round(corr_offset(2)+1) - n1; 
    else
        xbeginFrame=-999;
        ybeginFrame=-999;
    end
end