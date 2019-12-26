%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Filename: getBestMatchCordinate.m
%  Description: Feature block matching using NCC or SAD
%  Author: Adel Hafiane, Kannappan Palaniappan 
%  Copyright (C)  Kannappan Palaniappan, Adel Hafiane and Curators of the
%                           University of Missouri, a public corporation.
%                           All Rights Reserved.
%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  For more information, contact:
%      Dr. Adel Hafiane &
%      Dr. Kannappan Palaniappan
%      Computer Science Department,
%      University of Missouri-Columbia
%      (573) 884-9266
%      PalaniappanK@missouri.edu, adel.hafiane@ensi-bourges.fr
%
% or
%      Dr. K. Palaniappan
%      205 Naka Hall (EBW)
%      University of Missouri-Columbia
%      Columbia, MO 65211
%      palaniappank@missouri.edu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [x y motion]=getBestMatchCordinate(bx, by, Iref, Iin, blockStep, sw, type)
%bx: center block cordinate in X
%by: center block cordinate in Y
%Iref: reference image features
%Iin: input image features
%blocStep: one dimension of square block
%sw: search window size

[M N] = size(Iref);
hBlck = floor(blockStep/2); %half block size
 hsw   = sw;        %half window size
% 
% %search window definition 
% pLow = hBlck-hsw;  if(bx-hsw<0) pLow=0; end
% qLow = hBlck-hsw;  if(by-hsw<0) qLow=0; end
% pHigh = hsw-hBlck;if(bx+hsw>M) pHigh=0; end
% qHigh = hsw-hBlck; if(by+hsw>N) qHigh=0; end

pLow = -sw;  if(bx-sw-hBlck<0) pLow=0; end
qLow = -sw;  if(by-sw-hBlck<0) qLow=0; end
pHigh = sw;if(bx+sw+hBlck>M) pHigh=0; end
qHigh = sw; if(by+sw+hBlck>N) qHigh=0; end

minSAD=1.000e+30; 
%matching
        i1 = bx-hBlck+1; i2 = bx+hBlck;
        j1 = by-hBlck+1; j2 = by+hBlck;
        
        %%size(Iref)=[1071        1911]
        %%[i1 i2 j1 j2 pLow pHigh qLow qHigh] =[912  1165  24  277 -265  0   0  265]
        
        %added by rumana
        if(i2>M || j2>N || i1<1 || j1< 1)
            x=0;y=0; motion=-1;
            return;
        end
        
if strcmp(type,'SAD')  
    
        for p=pLow:pHigh
            for q=qLow:qHigh

                s  = Iref(i1:i2,j1:j2)-Iin(i1+p:i2+p,j1+q:j2+q);
                s = s.*s; %abs(s);
                SAD = sum(s(:))./(blockStep*blockStep);       


                if(SAD<minSAD)
                minSAD=SAD;
                x=bx+p; y=by+q;
                end


            end
        end

else


%% GPU vs CPU for normxcross
if ~(parallel.gpu.GPUDevice.isAvailable) %% CPU VERSION
	corrmat = normxcorr2(Iref(i1:i2,j1:j2), Iin(i1+pLow:i2+pHigh, j1+qLow:j2+qHigh)) ;
else
	Ir=im2double(Iref(i1:i2,j1:j2)); Ii=im2double(Iin(i1+pLow:i2+pHigh, j1+qLow:j2+qHigh));
	gpu_corrmat=normxcorr2(gpuArray(Ir), gpuArray(Ii) ) ;
	corrmat=gather(gpu_corrmat);
end



[max_cc, imax] = max(abs(corrmat(:)));
[ypeak, xpeak] = ind2sub(size(corrmat),imax(1));
%ypeak = ypeak-round(size(corrmat,1)/2) ; 
ypeak = ypeak+pLow-size(Iref(i1:i2,j1:j2),1);
xpeak = xpeak+qLow-size(Iref(i1:i2,j1:j2),2);

%xpeak = xpeak-round(size(corrmat,2)/2) ;
x=bx+ypeak; y=by+xpeak;

motion = sqrt(ypeak^2+xpeak^2);



end

% prc = 4;  % subpixel precision = 1/prc 
% 
% [x2,y2]   = meshgrid(-hBlck:1:hBlck+1);
% [x2i,y2i] = meshgrid(-hBlck:1/prc:hBlck+1);
%      z2 = zeros(size(x2));
%    
%      pLow = x-hBlck ; pHigh = x+hBlck+1;
%      qLow = y-hBlck ; qHigh = y+hBlck+1;
%      if pLow == 0,
%       z2(pLow+2:pHigh+1,:) = Iin(pLow+1:pHigh,qLow:qHigh);
%      end
%      if qLow == 0,
%       z2(:,qLow+2:qHigh+1) = Iin(pLow:pHigh,qLow+1:qHigh);
%      end
%      if pHigh > M,
%       z2(pLow:pHigh-1,:) = Iin(pLow:pHigh-1,qLow:qHigh);
%      end
%      if qHigh > N,
%       z2(:,qLow:qHigh-1) = Iin(pLow:pHigh,qLow:qHigh-1);
%      end
%      if (pLow > 0 && pHigh <= M && qLow > 0 && qHigh <= N)  
%         z2 = Iin(pLow:pHigh,qLow:qHigh); 
%      end   
%       z2i =interp2(x2,y2,z2,x2i,y2i,'bilinear');
%       
% [x1,y1]   = meshgrid(-hBlck+1:1:hBlck);
% [x1i,y1i] = meshgrid(-hBlck+1:1/prc:hBlck);   
%      z1i  = interp2(x1,y1,Iref(i1:i2,j1:j2),x1i,y1i,'bilinear');
%  
%  
% [h w]= size(z1i);
% 
% for i=1:2*prc-1
%     for j=1:2*prc-1
%       s = z1i-z2i(i+1:h+i,j+1:w+j);  
%       s = s.*s;      
% 
% 
%       SAD = sum(s(:))/(h*w);    
%       
% if(SAD<minSAD)
% minSAD=SAD;
% x=x+(i-prc)/prc ; y=y+(j-prc)/prc;
% end
% 
%     end
% end
