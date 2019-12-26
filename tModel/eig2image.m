%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


function [Lambda1,Lambda2,T,D]=eig2image(Dxx,Dxy,Dyy)
% This function eig2image calculates the eigen values from the
% hessian matrix, sorted by abs value. And gives the direction
% of the ridge (eigenvector smallest eigenvalue) .
%
% [Lambda1,Lambda2,Ix,Iy]=eig2image(Dxx,Dxy,Dyy)
%

% | Dx^2  Dxy |
% |          |
% | Dxy  Dy^2 |

% Calculate eigen values
T=Dxx+Dyy;
D=Dxx.*Dyy-Dxy.*Dxy;
A=T*0.5;
B=sqrt(T.^2/4-D);
L1=A + B;
L2=A - B;

% Sort eigen values by absolute value abs(Lambda1)<abs(Lambda2)
check=abs(L1)>abs(L2);
Lambda1=L1; Lambda1(check)=L2(check);
Lambda2=L2; Lambda2(check)=L1(check);

% Calculate eigen vector
% Cx=(Lambda1-Dyy); Cy=Dxy;
% 
% N=sqrt(Cx.^2+Cy.^2);
% Ix=Cx./N;
% Iy=Cy./N;
end