
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Filename: getHomographyMatrix.m
%  Description: This function accepts two images as input and estimates the
%  homography transformation matrix between them using the Beltrami feature operator.
%  Author: Adel Hafiane, Hadi AliAkbarpour, Kannappan Palaniappan 
%  Copyright (C) 2012 to 2014 Kannappan Palaniappan, Adel Hafiane, Hadi AliAkbarpour and Curators of the
%                           University of Missouri, a public corporation.
%                           All Rights Reserved.
%
%  For more information, contact:
%      Dr. Adel Hafiane &
%      Dr. Kannappan Palaniappan
%      Computer Science Department,
%      University of Missouri-Columbia
%      (573) 884-9266
%      PalaniappanK@missouri.edu, adel.hafiane@ensi-bourges.fr, hd.akbarpour@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [referencePoints, inputPoints]=getHomographyMatrix(I1, I2, blocStep, searchWin, imgName, reference_frame, FeatureMatchedSave, FileDir) 

%addpath('/Volumes/F/Courses/MesenteryData/TranslationModelRegistration/tModel/libraries/Zisserman_lib/vgg_examples');

start_t_fea=toc;

no_features=0;
format long


[M,N]=size(I1);

offset = floor(blocStep/2);
mean_motion = [];

% Image type casting
I1=double(I1);
I2=double(I2); 

% Get derivative masks
%a = [0.06368 0.37263 0 -0.37263 -0.06368 ];
a=[-1 0 1]; 
b=a';


[Ic Ib] = tensor(I1,  a, b);
% Normalization
 Ic=Ic - min(Ic(:));
 %Ic=Ic./max(Ic(:)); 

 %local maximum
 regmax = imregionalmax(real(Ic));
 regmax = 1-regmax;
 Ic(regmax==1) = 0;
 
 regmax = imregionalmax(Ib);
 regmax = 1-regmax;
 Ib(regmax==1) = 0;
 

    

    Mbk=floor((M-2*offset)/blocStep); % number of blocks in rows
    Nbk=floor((N-2*offset)/blocStep); % number of blocks in columns

    % Prominent function initialization
    PF=zeros(Mbk,Nbk);
    PF_s = PF;
    PFPOS=zeros(Mbk,Nbk,2);
    PFPOS_shi = PFPOS;
    %Feature location


    % Prominent function estimation for each block

    ii=1;jj=1;
    for i=offset:blocStep:M-blocStep-offset
        for j=offset:blocStep:N-blocStep-offset

            Icb=Ic(i:(i+blocStep),j:(j+blocStep));
            Ibb=Ib(i:(i+blocStep),j:(j+blocStep));
            [PF_s(ii,jj),IND] = max(Icb(:));
            [PFPOS_shi(ii,jj,1),PFPOS_shi(ii,jj,2)] = ind2sub([blocStep+1,blocStep+1],IND);
            PFPOS_shi(ii,jj,1) = PFPOS_shi(ii,jj,1)+i;
            PFPOS_shi(ii,jj,2) = PFPOS_shi(ii,jj,2)+j;

            [PF(ii,jj),IND] = max(Ibb(:));
            [PFPOS(ii,jj,1),PFPOS(ii,jj,2)] = ind2sub([blocStep+1,blocStep+1],IND);
            PFPOS(ii,jj,1) = PFPOS(ii,jj,1)+i;
            PFPOS(ii,jj,2) = PFPOS(ii,jj,2)+j;
            jj=jj+1;
        end
    ii=ii+1;jj=1;
    end


    Top30_s = floor(size(find(PF_s>0),1)/1.5); %top 33.33%
    [sortedValues,sortIndex] = sort(PF_s(:),'descend');
    maxIndex = sortIndex(1:Top30_s);
    otherIndex = sortIndex(Top30_s+1:end);
    %[ii,jj] = ind2sub(size(PF),maxIndex);
    PF_s(maxIndex) = 1;
    PF_s(otherIndex) = 0;
    [Lx_s Ly_s] = find(PF_s);


    sizePts=size(Lx_s);
    % Initialisation of points to be matched
    referencePoints = zeros(sizePts(1),2);
    inputPoints = zeros(sizePts(1),2);

    %size(referencePoints)

    %==========================================================================
    %Compute feature in second level
    %==========================================================================

    %Prominent function initialization
    PF1=zeros(Mbk,Nbk);        
    ii = 1;
    jj = 1;
    for i=1:Mbk-3
        for j=1:Nbk-3
            numfeatures = 0;
            for u = 1:2
                for v = 1:2
                    numfeatures = PF_s(i+u-1,j+v-1)+numfeatures;%+PF(i+u-1,j+v-1);
                end
            end
            if numfeatures==0
                PF1(ii,jj) = 1;
            end
            jj = jj+1;
        end
        ii = ii+1;jj = 1;
    end


    [Lx1 Ly1] = find(PF1); 
    
    t_st_finish=toc;
    t_st=t_st_finish-start_t_fea;


    p=1;
    for i=1:size(Lx_s)              
        x1 = PFPOS_shi(Lx_s(i),Ly_s(i),1);
        y1 = PFPOS_shi(Lx_s(i),Ly_s(i),2);  



        [x2 y2 motion] = getBestMatchCordinate(x1, y1, I1, I2, blocStep, searchWin,'nxcorr');

        if motion ~= -1
            referencePoints(p,1)=y1;
            referencePoints(p,2)=x1;


            inputPoints(p,1)=y2;
            inputPoints(p,2)=x2;

             mean_motion = [mean_motion;motion];

             p=p+1;
        end

    end


    % 
    %  imagesc(uint8(I1)),axis off,box off,hold on
    %   imshow(uint8(I1)),hold on;
    % plot(referencePoints(:,1),referencePoints(:,2),'rx');
    % drawnow;


    for i=1:size(Lx1)

        %Textureless region
        x1 = Lx1(i)*blocStep+offset+blocStep;
        y1 = Ly1(i)*blocStep+offset+blocStep;


        [x2 y2 motion] = getBestMatchCordinate(x1, y1, I1, I2, 2*blocStep, searchWin,'nxcorr');

        if motion ~= -1
            referencePoints(p,1)=y1;
            referencePoints(p,2)=x1;

            inputPoints(p,1)=y2;
            inputPoints(p,2)=x2;

            mean_motion = [mean_motion;motion];

            p=p+1;     
        end
    end
    
    inputPoints(p:end,:)=[];
	referencePoints(p:end,:)=[];
    
   close all;    

    if FeatureMatchedSave==1
        figure; ax = axes;
        I=showMatchedFeatures(I1,I2,referencePoints,inputPoints);%,'montage','Parent',ax);
        title(ax, sprintf('ST+NCC Frame: %d <- %d', reference_frame, imgName));
        legend(ax, 'Matched points 1','Matched points 2');
        
       
    end
    
    [tpr inliers] = ransacfithomography_vgg([inputPoints  repmat(1,size(inputPoints,1), 1)]',[referencePoints  repmat(1,size(referencePoints,1), 1)]' , 0.01 ) ;

    inputPoints=inputPoints(inliers(1,:), :);
    referencePoints=referencePoints(inliers(1, :), :);

%     ty=referencePoints(:,2)-inputPoints(:, 2);
%     tx=referencePoints(:,1)-inputPoints(:, 1);
%     
    

end

 

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% block step ends
% 
% inputPoints(p:end,:)=[];
% referencePoints(p:end,:)=[];
% 
% 
% %pfb_ncc=toc;
% 
% 
% 
% % imagesc(uint8(I1)),axis off,box off,hold on
% % plot(referencePoints(:,1),referencePoints(:,2),'rx');
% % figure,imagesc(uint8(I2)),axis off,box off,hold on
% % plot(inputPoints(:,1),inputPoints(:,2),'rx');
% % close all;
% %tic;
% 
% % disp('Filtering local motion regions in image....');
% %[new_refPoints, new_inPoints]= filtLocalMotion(referencePoints, inputPoints, 0);
% new_refPoints = referencePoints;
% new_inPoints = inputPoints;
% 
% percent_non_moving = (size(new_refPoints))/size(inputPoints)*100;
% 
% t_ncc_finish=toc;
% t_ncc=t_ncc_finish-t_st_finish;
% t_fea=toc;
% 
% %figure
% %imshow([uint8(I1), uint8(I2)])
% % %show matching features between two images
% 
% 
% 
% %disp('Estimating RANSAC-based image homography transformation....');
% %new_inPoints: integer set of points
% 
% [tpr inliers] = ransacfithomography_vgg([new_inPoints  repmat(1,size(new_inPoints,1), 1)]',[new_refPoints  repmat(1,size(new_refPoints,1), 1)]' , 0.01 ) ;
% 
% 

% 
% 
% 
% 
% tpr = tpr';
% m_motion = mean(mean_motion(inliers));
% 
% percent_inliers = size(inliers,2)/size(new_refPoints,1)*100;
% 
% num_features = size(new_refPoints,1);
% 
% reliability = percent_non_moving*percent_inliers/100;
% 
% %% save st features 
% if FeatureMatchedSave==1 || trace_video_on==1
%     %Non-overlapping prominent feature blocks
%     %imagesc(uint8(I2)),axis off,axis tight,box off,hold on
%     imshow(uint8(I2)),hold on;
% %     for i = offset:blocStep:size(I2,2)-offset
% %        i;
% %        plot([i,i],[1,size(I2,1)]);
% %     end
% %     for i = offset:blocStep:size(I2,1)-offset
% %        plot([1,size(I2,2)],[i,i]);
% %     end
% % 
% %      x = [offset+11*blocStep,offset+13*blocStep,offset+13*blocStep,offset+11*blocStep,offset+11*blocStep];
% %      y = [offset+8*blocStep,offset+8*blocStep,offset+10*blocStep,offset+10*blocStep,offset+8*blocStep];
% %      x1 = [offset+12*blocStep,offset+14*blocStep,offset+14*blocStep,offset+12*blocStep,offset+12*blocStep];
% %      y1 = [offset+8*blocStep,offset+8*blocStep,offset+10*blocStep,offset+10*blocStep,offset+8*blocStep];
% %      x2 = [offset+11*blocStep,offset+13*blocStep,offset+13*blocStep,offset+11*blocStep,offset+11*blocStep];
% %      y2 = [offset+9*blocStep,offset+9*blocStep,offset+11*blocStep,offset+11*blocStep,offset+9*blocStep];
% %      x3 = [offset+12*blocStep,offset+14*blocStep,offset+14*blocStep,offset+12*blocStep,offset+12*blocStep];
% %      y3 = [offset+9*blocStep,offset+9*blocStep,offset+11*blocStep,offset+11*blocStep,offset+9*blocStep];
% %       plot(x,y,'r');
% %       plot(x1,y1,'g');
% %       plot(x2,y2,'k');
% %       plot(x3,y3,'y');
% 
% 
%     %plot(new_inPoints(:,1),new_inPoints(:,2), 'r*');
%     %hold on; sz=1041;
%     %scatter(new_inPoints(:,1),new_inPoints(:,2), sz, 's','MarkerEdgeColor',[1 1 1]);
%     scatter(new_inPoints(:,1),new_inPoints(:,2), 'o', 'MarkerFaceColor', 'r','MarkerEdgeColor', 'r');
% 
%     drawnow;
% 
%     print(sprintf('%s/Features_%06d', FileDir, imgName), '-dpng')
% end
% 
% t_ran=toc;
% t_ran=(t_ran-t_fea);
% t_fea=(t_fea-start_t_fea);
% %[t_ran t_fea t_st t_ncc (t_st+t_ncc)]
% %[t_ran t_fea (t_ran-t_fea) start_t_fea  (t_fea-start_t_fea)]
% 
% %ransac_homo=toc;
% 
% % % % 
% % imagesc(uint8(I1)),axis off,box off,hold on
% % plot(new_refPoints(inliers,1),new_refPoints(inliers,2),'rx');
% % figure,imagesc(uint8(I2)),axis off,box off,hold on
% % plot(new_inPoints(inliers,1),new_inPoints(inliers,2),'rx');
% % 
% % print(sprintf('Er_%d', img_no), '-dpng')
% 
% 
% 
% 
% %tProj = cp2tform(new_inPoints, new_refPoints,'projective');
% 
% %A=tProj.tdata.T; 
% 
% 









