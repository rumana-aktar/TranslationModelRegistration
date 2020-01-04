function outlierIndex=getOutliersRANSAC(A, iteration, threshold)
    maxInliers=0;
    bestInliersSet=[];

    for k=1:iteration

        %% get 4 random number
        randomIndex = randi([1 size(A,1)],1,2);
        randomNumbers=A(randomIndex, 1);

        %% get mean of random numbers
        meanNum=mean(randomNumbers);

        %% get difference of all numbers and mean and reset h
        meanNumAll=zeros(size(A)); h=meanNumAll;
        meanNumAll(:)=meanNum;
        A_diff=abs(A-meanNumAll); %% difference should be close to 0

        %% find indexs which are close to mean
        A_valid_indexes=find(A_diff<=threshold);
        h(A_valid_indexes)=1;

        
        %% update maxInliers and best Inliers set
        if size(A_valid_indexes,1)>maxInliers %|| maxInliers>=6
            bestInliersSet=h;
            maxInliers=size(A_valid_indexes,1);
            maxInliers;
            
%             if maxInliers>=6
%                 break;
%            end
        end
        
    end
    
    outlierIndex=find(bestInliersSet==0);
    
end
