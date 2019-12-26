%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Filename: tensor.m
%  Description: Compute beltrami operator on each feature block
%  Author: Adel Hafiane, Kannappan Palaniappan 
%  Copyright (C)  Kannappan Palaniappan, Adel Hafiane and Curators of the
%                           University of Missouri, a public corporation.
%                           All Rights Reserved.
%
%  For more information, contact:
%      Dr. Adel Hafiane &
%      Dr. Kannappan Palaniappan
%      Computer Science Department,
%      University of Missouri-Columbia
%      (573) 884-9266
%      PalaniappanK@missouri.edu, adel.hafiane@ensi-bourges.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function [Ic,Ie,Icf] = tensor(I1, I2, a, b)
function [lamda1 Ibel] = tensor(I1, a, b)%[lamda1,Ibel] = tensor(I1, I2, a, b)
%Ic: moving corners
%Ie: moving edges
%Icf: motion confidence
%a: derivative mask for X axis Dx
%b: derivative mask for Y axis Dy



I1x=conv2(I1,a,'same');
I1y=conv2(I1,b,'same');


filtSize=3;
c=fspecial('gaussian',filtSize,0.7);

d=sum(sum(c));
hs=uint16(filtSize/2);

Sxx=conv2((I1x.*I1x),c,'same')./d;
Syy=conv2((I1y.*I1y),c,'same')./d;
Sxy=conv2((I1x.*I1y),c,'same')./d;



[M,N]=size(I1);
Ie=zeros(M,N);
Ic=zeros(M,N);
Icf=zeros(M,N);

Sxx=Sxx./max(I1(:));
Syy=Syy./max(I1(:));
Sxy=Sxy./max(I1(:));
%trace matrix
%Tr=Sxx+Syy;%+Stt; 
%Dt=Sxx.*Syy-Sxy.*Sxy;
[lamda1,lamda2,Tr,Dt] = eig2image(Sxx,Sxy,Syy);


%Tr=Tr-min(Tr(:));
%Tr=Tr./max(Tr(:));

%Dt=Dt-min(Dt(:));
%Dt=Dt./max(Dt(:));

  Ibel=(1+Tr+Dt);%beltrami 
  %Ic= Dt-0.04.*(Tr.^2);%harris
% 
% Icf=Ie+Ic;
% 
% Ibel = Ibel/norm(Ibel);
% 
% Ic(1:hs, :)=0;
% Ic(M-hs:M, :)=0;
% Ic(:, N-hs:N)=0;
% Ic(:, 1:hs)=0;
% 
% for i=1+hs:M-hs
%     for j=1+hs:N-hs
%         T=[Sxx(i,j) Sxy(i,j) ; Sxy(i,j) Syy(i,j)];
%         lamda=eig(T);
%         Ic(i,j)=min(lamda); 
%     end
% end
% 
% Ic = Ic/norm(Ic);

    


%Tensor and eigen vlaues
% for i=1+hs:M-hs
% for j=1+hs:N-hs
% %T=[Sxx(i,j) Sxy(i,j) Sxt(i,j) ; Sxy(i,j) Syy(i,j) Syt(i,j) ; Sxt(i,j) Syt(i,j) Stt(i,j)];
% 
%   %if (Tr(i,j)>10000)
%   %  lamda=eigs(T);
%   %  Icf(i,j)=((lamda(1)-lamda(3))./(lamda(1)+lamda(3))).^2;
%   %  Ie(i,j)=((lamda(1)-lamda(2))./(lamda(1)+lamda(2))).^2;
%   %  Ic(i,j)=Icf(i,j)-Ie(i,j);
%   %end
% T=[Sxx(i,j) Sxy(i,j) ; Sxy(i,j) Syy(i,j)];
% 
%   if (Tr(i,j)>1)
%     lamda=eig(T);
%     Ic(i,j)=min(lamda);  
%     %Ie(i,j)=max(lamda);
%    %Ic(i,j)= (1+Tr(i,j)+det(T));%./sum(T(:)) ; 
%    
%     
%   end
% end
% end


