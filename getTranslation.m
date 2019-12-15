function  [mean_x, mean_y, mode_x, mode_y, mean_ix, mean_iy, mode_ix, mode_iy] = getTranslation(I1, I2, displayMatches, save_tx_ty, i, dirnameOutFeatureMatched, dirnameOutMotion)
   
    %% I1 is previous frame, so its strongest points should be considered; or it does not matter
    points1 = detectSURFFeatures(I1, 'MetricThreshold', 500);
    points2 = detectSURFFeatures(I2, 'MetricThreshold', 500);
    
    if length(points1) > 5000
        points1=selectStrongest(points1, 5000);
        %points2=selectStrongest(points2, 500);
    end
    
    %extract neighborhood features
    %--features1 is [MxN] of M vectors, valid_points1 is [Mx2] of M vectors
    [features1,valid_points1] = extractFeatures(I1,points1);
    [features2,valid_points2] = extractFeatures(I2,points2);

    
    
    %match the features, indexPairs returns indexs of matched features
    %which corresponds to both (indexPairs(:,1): feature1, valid_points1)
    %and (indexPairs(:,2): feature2, valid_points2)
    indexPairs = matchFeatures(features1,features2, 'Unique', true);
   
    
    %retrieve the locations of corresponding points
    matchedPoints1 = valid_points1(indexPairs(:,1),:);
    matchedPoints2 = valid_points2(indexPairs(:,2),:);
    
    %--coords1 return XY location of matchedPoints
    coords1=matchedPoints1.Location;
    coords2=matchedPoints2.Location;
    motion=zeros(size(coords1));
    motion(:,1)=coords1(:,1)-coords2(:,1);
    motion(:,2)=coords1(:,2)-coords2(:,2);
    
    
    
    if displayMatches==1 
        [M,N,~]=size(I2);
        
        %% --shift x coords for I2 for displaying
        shiftX=zeros(size(coords2,1),1);shiftX(:)=N;    
        shift_coords2=coords2;
        shift_coords2(:, 1)=coords2(:, 1)+shiftX;
        
        %% --show points
        close all;
        imshow(uint8([I1 I2])); hold on;
        plot(coords1(:,1), coords1(:,2), 'r*'); hold on;
        plot(shift_coords2(:,1), shift_coords2(:,2), 'g*'); hold on;
        
        %% --draw lines
        for i=1:size(coords2,1)
            plot([shift_coords2(i, 1) coords1(i, 1)], [shift_coords2(i, 2) coords1(i, 2)]);
        end
        print(sprintf('%sFeature_%40d_%04d', dirnameOutFeatureMatched, i, i+1), '-dpng')
        
        
   
    end
    
    if size(motion,1)==0
        motion=[1 1];
    end
    if save_tx_ty==1
        %% save motions before oultier removals
        close all
        plot(motion(:,1), 'r*');
        title(sprintf('BTx: Frame=%04d, #features=%d, Range=%d', i, size(motion,1), round(max(motion(:,1))-min(motion(:,1)))));
        %text(size(motion,1),max(motion(:,1)),strcat(sprintf('Fr_%4d',i)),'HorizontalAlignment','right', 'FontSize' ,14);
        set(gca, 'YScale', 'log')        
        print(sprintf('%sXBeforeOR_%06d', dirnameOutMotion, i), '-dpng')
        
        
        close all;
        plot(motion(:,2), 'b+');
        title(sprintf('BTy: Frame=%04d, #features=%d, Range=%d', i, size(motion,1), round(max(motion(:,2))-min(motion(:,2)))));
        %text(size(motion,2),max(motion(:,2)),strcat(sprintf('Fr_%4d',i)),'HorizontalAlignment','right', 'FontSize' ,14);
        set(gca, 'YScale', 'log')  
        print(sprintf('%sYBeforeOR_%06d', dirnameOutMotion, i), '-dpng')
        
    end
    
    mean_x=mean(motion(:,1)); std_x=std(motion(:,1));
    mean_y=mean(motion(:,2)); std_y=std(motion(:,2));
    
    mode_x=mode(motion(:,1));
    mode_y=mode(motion(:,2));
    
    %% RANSAC Outliers
    index1=getOutliersRANSAC(motion(:,1), 1000, 1);
    index2=getOutliersRANSAC(motion(:,2), 1000, 1);
    
%     %% outlier removal
%     index1=getOutliers(motion(:,1));
%     index2=getOutliers(motion(:,2));
%     
    
    index=union(index1, index2);    
    motion(index, :)=[];
    
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
   
    
    mean_ix=mean(motion(:,1));
    mean_iy=mean(motion(:,2));
    
    mode_ix=mode(motion(:,1));
    mode_iy=mode(motion(:,2));
    
    

    
    
    
    x=1;

 
end

function TF=getOutliers(A)
    meanA=mean(A);
    stdA=std(A);
    %TF=zeros(size(A));
    TF=[];
    
    for i=1:size(A,1)
        if abs(meanA-A(i))>1
            TF=[TF; i];
        end
    end
end

function outlierIndex=getOutliersRANSAC(A, iteration, threshold)
    maxInliers=0;
    bestInliersSet=[];

    for k=1:iteration

        %% get 4 random number
        randomIndex = randi([1 size(A,1)],1,4);
        randomNumbers=A(randomIndex, 1);

        %% get mean of random numbers
        meanNum=mean(randomNumbers);

        %% get difference of all numbers and mean and reset h
        meanNumAll=zeros(size(A)); h=meanNumAll;
        meanNumAll(:)=meanNum;
        A_diff=abs(A-meanNumAll);

        %% find indexs which are close to mean
        A_valid_indexes=find(A_diff<=threshold);
        h(A_valid_indexes)=1;

        
        %% update maxInliers and best Inliers set
        if size(A_valid_indexes,1)>maxInliers
            bestInliersSet=h;
            maxInliers=size(A_valid_indexes,1);
        end
        
    end
    
    outlierIndex=find(h==0);
    
end
