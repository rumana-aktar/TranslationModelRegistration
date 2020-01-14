
% clc; clear all; close all;
% 
% seq=5;
% rootDir=sprintf('/Volumes/F/Courses/MesenteryData/Sequence%d_fr6_cropped/', seq);   %Sequence5_fr6_cropped, SFM_100, Seq5_fr30         
% %rootDir='/Volumes/D/Mesentery/SFM_100/';
% mosaicDir=sprintf('%sNCC_60_100_150x200/', rootDir);
% %% --------------------------------------------------------------------    
% %dirnameOut=sprintf('%siMosaic/',mosaicDir);
% xy=dlmread(sprintf('%sxy.txt', mosaicDir));
% tx_ty=dlmread(sprintf('%sXY_Single_Multi.txt', mosaicDir));
% no_Frames=size(tx_ty,1);
% 
% 
% plot(1:no_Frames, tx_ty(:,2), 'ro--', 1:no_Frames, tx_ty(:,3), 'b+--');
% ylim([-150 150]);
% xlim([1 no_Frames]);
% legend({'tx', 'ty'},'fontSize', 18);
% %yt=get(gca,'yticklabel');
% set(gca,'yticklabel',-150:50:150, 'fontSize', 18);
% %set(gca,'xticklabel',1:100:no_Frames, 'fontSize', 18);
% print(sprintf('%sSeq%d_Translation', mosaicDir, seq), '-dpng');


clc; clear all; close all;

Seq5=[0.2075, 0.6585, 0.3830];
Seq4=[0.2303, 0.7071, 0.4029];
Seq3=[0.1682, 0.6499, 0.3526];


Seq=[Seq3; Seq4; Seq5];
bar(Seq)
ylim([0:1])
ylabel('Time (s)')

xt={'Sequence3' ; 'Sequence4'; 'Sequence5'} ; 
set(gca,'xtick',1:3); 
set(gca,'xticklabel',xt, 'fontSize', 18);


legend({'Single Template', 'Multiple Templates', 'Multiple Templates with Search Window'}, 'fontSize', 18)
print(sprintf('Time'), '-dpng')


