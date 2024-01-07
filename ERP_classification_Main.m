%% ERP classification %%


clc
clear
%% load data

% load data (no_Reconstruct data,Reconstruct-T ,Reconstruct-NT,
% Reconstruct- NT_vs_T, Reconstruct- T_vs_NT) and label


% % load no_resyn data
% DataName_1 = strcat('D:\ERP_REconstruct_2\sub',num2str(subnum),'\200_',experiment,'\Sub',num2str(subnum),'_data_resample_epoch.mat');
% EEG_1 = load(DataName_1);
% data_NoResync = EEG_1.EEG.data;
% 
% % load Resyn data
% DataName_2 = strcat('D:\ERP_REconstruct_2\sub',num2str(subnum),'\200_',experiment,'\Sub',num2str(subnum),'_data_enhancement_epoch.mat');
% EEG_2 = load(DataName_2);
% data_Resync = EEG_2.EEG.data;
% 
% % load Resyn data - NT
% DataName_3 = strcat('D:\ERP_REconstruct_2\sub',num2str(subnum),'\200_',experiment,'\Sub',num2str(subnum),'_data_enhancement_NT_epoch.mat');
% EEG_3 = load(DataName_3);
% data_Resync_nt = EEG_3.EEG.data;
% 
% % load Resyn data - NT_vs_T
% DataName_4 = strcat('D:\ERP_REconstruct_2\sub',num2str(subnum),'\200_',experiment,'\Sub',num2str(subnum),'_data_enhancement_NT_vs_T_epoch.mat');
% EEG_4 = load(DataName_4);
% data_Resync_nt_vs_t = EEG_4.EEG.data;
% 
% % load Resyn data - T_vs_NT
% DataName_5 = strcat('D:\ERP_REconstruct_2\sub',num2str(subnum),'\200_',experiment,'\Sub',num2str(subnum),'_data_enhancement_T_vs_NT_epoch.mat');
% EEG_5 = load(DataName_5);
% data_Resync_t_vs_nt = EEG_5.EEG.data;
% 
% 
% % load label
% LabelName = strcat('D:\ERP_REconstruct_2\sub',num2str(subnum),'\200_',experiment,'\Sub',num2str(subnum),'_label.mat');
% label = load(LabelName);
% label = label.label;

% other parameters
chan = EEG_1.EEG.nbchan;
SamplingRate = EEG_1.EEG.srate; 
srate = SamplingRate;
segment1 = 1*SamplingRate+0.1*SamplingRate;
segment2 = 0.1*SamplingRate;
chanselectNum = [1:59];

chanSelect = size(chanselectNum,2);




% count number of different types of data
T_num = 0;
NT_num = 0;
for i = 1 : max(size(label))
    if label(i) == 1
        NT_num = NT_num+1;
    end
end

T_num = max(size(label)) - NT_num;

% prepara for classification      
data_NoResync = data_NoResync(chanselectNum,:,:); % 
data_Resync = data_Resync(chanselectNum,:,:); % 
data_Resync_nt = data_Resync_nt(chanselectNum,:,:);
data_Resync_nt_vs_t = data_Resync_nt_vs_t(chanselectNum,:,:);
data_Resync_t_vs_nt = data_Resync_t_vs_nt(chanselectNum,:,:);

PCA_parameter = 7;
ch_num = 6; 
cnt = 1;
ct = 1;
for i = 1:max(size(label))
    if label(i) == 1% 
        EEG_nonTarget_NoResync(cnt,:,:) = data_NoResync(:,:,i);
        EEG_nonTarget_Resync(cnt,:,:) = data_Resync(:,:,i);
        EEG_nonTarget_Resync_NT(cnt,:,:) = data_Resync_nt(:,:,i);
        EEG_nonTarget_Resync_NT_vs_T(cnt,:,:) = data_Resync_nt_vs_t(:,:,i);
        EEG_nonTarget_Resync_T_vs_NT(cnt,:,:) = data_Resync_t_vs_nt(:,:,i);
        cnt = cnt+1;
    else
        EEGTargetNoResync(ct,:,:) = data_NoResync(:,:,i);% Target EEG dataset
        EEGTargetResync(ct,:,:) = data_Resync(:,:,i);
        EEGTargetResync_NT(ct,:,:) = data_Resync_nt(:,:,i);
        EEGTargetResync_NT_vs_T(ct,:,:) = data_Resync_nt_vs_t(:,:,i);
        EEGTargetResync_T_vs_NT(ct,:,:) = data_Resync_t_vs_nt(:,:,i);
        ct = ct+1;
    end
end

cross_k = 4;

Train_proportion = 0.5;

cross_k = 4;
for c=1:cross_k
    alphabet = [1,2]; prob = [(Train_proportion) (1-Train_proportion)];
    T_label_generation = CVgeneration(alphabet,prob,T_num);
    NT_label_generation = CVgeneration(alphabet,prob,NT_num);
    clearvars  EEG_nonTarget_NoResync_test EEG_nonTarget_Resync_test EEG_nonTarget_Resync_NT_test EEG_nonTarget_Resync_NT_vs_T_test EEG_nonTarget_Resync_T_vs_NT_test
    clearvars EEGTargetNoResync_test EEGTargetResync_test EEGTargetResync_NT_test EEGTargetResync_NT_vs_T_test EEGTargetResync_T_vs_NT_test
    clearvars EEG_nonTarget_NoResync_train EEG_nonTarget_Resync_train EEG_nonTarget_Resync_NT_train EEG_nonTarget_Resync_NT_vs_T_train EEG_nonTarget_Resync_T_vs_NT_train
    clearvars EEGTargetNoResync_train EEGTargetResync_train EEGTargetResync_NT_train EEGTargetResync_NT_vs_T_train EEG_nonTarget_Resync_T_vs_NT_train EEGTargetResync_T_vs_NT_train
    
    clearvars trainData_1 testData_1 trainData_2 testData_2 trainData_3 testData_3 class_final
    clearvars trainData_t trainData_nt trainData test_label train_label_1 position_1 POSTERIOR_final
    clearvars class_1 POSTERIOR_test_1 class_2 POSTERIOR_test_2 value_1 value_2 position_2
    % NT
    ct = 1;cd = 1;
    for i=1:NT_num
        if NT_label_generation(i)==1
            % NoResync
            EEG_nonTarget_NoResync_test(ct,:,:) = EEG_nonTarget_NoResync(i,:,:);
            % Resync_T
            EEG_nonTarget_Resync_test(ct,:,:) = EEG_nonTarget_Resync(i,:,:);
            % Resync_NT
            EEG_nonTarget_Resync_NT_test(ct,:,:) = EEG_nonTarget_Resync_NT(i,:,:);
            % Resync_NT_vs_T
            EEG_nonTarget_Resync_NT_vs_T_test(ct,:,:) = EEG_nonTarget_Resync_NT_vs_T(i,:,:);
            % Resync_T_vs_NT
            EEG_nonTarget_Resync_T_vs_NT_test(ct,:,:) = EEG_nonTarget_Resync_T_vs_NT(i,:,:);
            ct = ct+1;
        else
            % NoResync
            EEG_nonTarget_NoResync_train(cd,:,:) = EEG_nonTarget_NoResync(i,:,:); 
            % Resync_T
            EEG_nonTarget_Resync_train(cd,:,:) = EEG_nonTarget_Resync(i,:,:); 
            % Resync_NT
            EEG_nonTarget_Resync_NT_train(cd,:,:) = EEG_nonTarget_Resync_NT(i,:,:); 
            % Resync_NT_vs_T
            EEG_nonTarget_Resync_NT_vs_T_train(cd,:,:) = EEG_nonTarget_Resync_NT_vs_T(i,:,:); 
            % Resync_T_vs_NT
            EEG_nonTarget_Resync_T_vs_NT_train(cd,:,:) = EEG_nonTarget_Resync_T_vs_NT(i,:,:); 
            cd = cd+1;
        end
    end
    % T
    ct = 1;cd = 1;
    for i=1:T_num
        if T_label_generation(i)==1
            % NoResync
            EEGTargetNoResync_test(ct,:,:) = EEGTargetNoResync(i,:,:);
            % Resync_T
            EEGTargetResync_test(ct,:,:) = EEGTargetResync(i,:,:);
            % Resync_NT 
            EEGTargetResync_NT_test(ct,:,:) = EEGTargetResync_NT(i,:,:);
            % Resync_NT_vs_T
            EEGTargetResync_NT_vs_T_test(ct,:,:) = EEGTargetResync_NT_vs_T(i,:,:);
            % Resync_T_vs_NT
            EEGTargetResync_T_vs_NT_test(ct,:,:) = EEGTargetResync_T_vs_NT(i,:,:);
            ct = ct+1;
        else
           % NoResync  
           EEGTargetNoResync_train(cd,:,:) = EEGTargetNoResync(i,:,:); 
           % Resync_T 
           EEGTargetResync_train(cd,:,:) = EEGTargetResync(i,:,:); 
           % Resync_NT 
           EEGTargetResync_NT_train(cd,:,:) = EEGTargetResync_NT(i,:,:);
           % Resync_NT_vs_T
           EEGTargetResync_NT_vs_T_train(cd,:,:) = EEGTargetResync_NT_vs_T(i,:,:);
           % Resync_T_vs_NT
           EEGTargetResync_T_vs_NT_train(cd,:,:) = EEGTargetResync_T_vs_NT(i,:,:);
           cd = cd+1; 
        end
    end

    trainData_1 = cat(1,EEGTargetResync_train,EEG_nonTarget_Resync_NT_train);
    testData_1 = cat(1,EEGTargetNoResync_test,EEG_nonTarget_NoResync_test);
    trainData_2 = cat(1,EEGTargetResync_T_vs_NT_train,EEG_nonTarget_Resync_NT_vs_T_train);
    testData_2 = cat(1,EEGTargetResync_test,EEG_nonTarget_Resync_NT_test);
    trainData_3 = cat(1,EEGTargetResync_T_vs_NT_train,EEG_nonTarget_Resync_NT_vs_T_train);
    testData_3 = cat(1,EEGTargetResync_T_vs_NT_test,EEG_nonTarget_Resync_NT_vs_T_test);

    EEG_nonTarget_NoResync_train = permute(EEG_nonTarget_NoResync_train,[2,3,1]);
    EEG_nonTarget_NoResync_test = permute(EEG_nonTarget_NoResync_test,[2,3,1]);
    EEGTargetNoResync_train = permute(EEGTargetNoResync_train,[2,3,1]);
    EEGTargetNoResync_test = permute(EEGTargetNoResync_test,[2,3,1]);

    EEG_nonTarget_Resync_train = permute(EEG_nonTarget_Resync_train,[2,3,1]);
    EEG_nonTarget_Resync_test = permute(EEG_nonTarget_Resync_test,[2,3,1]);
    EEGTargetResync_train = permute(EEGTargetResync_train,[2,3,1]);
    EEGTargetResync_test = permute(EEGTargetResync_test,[2,3,1]);

    EEG_nonTarget_Resync_NT_train = permute(EEG_nonTarget_Resync_NT_train,[2,3,1]);
    EEG_nonTarget_Resync_NT_test = permute(EEG_nonTarget_Resync_NT_test,[2,3,1]);
    EEGTargetResync_NT_train = permute(EEGTargetResync_NT_train,[2,3,1]);
    EEGTargetResync_NT_test = permute(EEGTargetResync_NT_test,[2,3,1]);
    
    EEG_nonTarget_Resync_NT_vs_T_train = permute(EEG_nonTarget_Resync_NT_vs_T_train,[2,3,1]);
    EEG_nonTarget_Resync_NT_vs_T_test = permute(EEG_nonTarget_Resync_NT_vs_T_test,[2,3,1]);
    EEGTargetResync_NT_vs_T_train = permute(EEGTargetResync_NT_vs_T_train,[2,3,1]);
    EEGTargetResync_NT_vs_T_test = permute(EEGTargetResync_NT_vs_T_test,[2,3,1]);

    EEG_nonTarget_Resync_T_vs_NT_train = permute(EEG_nonTarget_Resync_T_vs_NT_train,[2,3,1]);
    EEG_nonTarget_Resync_T_vs_NT_test = permute(EEG_nonTarget_Resync_T_vs_NT_test,[2,3,1]);
    EEGTargetResync_T_vs_NT_train = permute(EEGTargetResync_T_vs_NT_train,[2,3,1]);
    EEGTargetResync_T_vs_NT_test = permute(EEGTargetResync_T_vs_NT_test,[2,3,1]);   
    
    trainData_1 = permute(trainData_1,[2,3,1]);
    testData_1 = permute(testData_1,[2,3,1]);

    trainData_2 = permute(trainData_2,[2,3,1]);
    testData_2 = permute(testData_2,[2,3,1]);

    trainData_3 = permute(trainData_3,[2,3,1]);
    testData_3 = permute(testData_3,[2,3,1]);   
    
    %% enhanced
    trainData_t = cat(3,EEGTargetNoResync_train,EEGTargetResync_train,EEGTargetResync_T_vs_NT_train);
    trainData_nt = cat(3,EEG_nonTarget_NoResync_train,EEG_nonTarget_Resync_NT_train,EEG_nonTarget_Resync_NT_vs_T_train);
    trainData = cat(3,trainData_t,trainData_nt);
    
    train_label_1(1,max(size(trainData)))=0;
    
    for i=1:max(size(trainData_t))
        train_label_1(i)=1;
    end
    
    test_label(1,max(size(testData_2)))=0;
    for i=1:max(size(EEGTargetResync_test))
        test_label(i)=1;
    end
    
 [class_1,POSTERIOR_test_1,class_2,POSTERIOR_test_2] = sthcp(trainData_t,trainData_nt,trainData,testData_2,testData_3,ch_num,train_label_1,max(size(trainData)),max(size(testData_2)));
   
 % final decision 
for i = 1:max(size(test_label))
    [value_1(i) position_1(i)] = max(POSTERIOR_test_1(i,:));
    [value_2(i) position_2(i)] = max(POSTERIOR_test_2(i,:));
end
class_final = position_1;
POSTERIOR_final = value_1;

for i = 1:max(size(test_label))
    if value_2(i) >= value_1(i)
        class_final(i) = position_2(i);
        POSTERIOR_final(i) = value_2(i);
    end
end    
        
for i = 1:max(size(test_label))
    if class_final(i)==1
        class_final(i) = 0;
    else
        class_final(i) = 1;
    end
end
        
for i = 1:max(size(test_label))
    if class_final(i)==0
        POSTERIOR_final(i) = 1-POSTERIOR_final(i);
    end
end

 
 
 
 % final decision 
    acc_num=0;
    for i=1:max(size(test_label))
        if class_final(i)==test_label(i)
            acc_num=acc_num+1;
        end
    end
    [TP, FP, TN, FN] = calError(test_label,class_final);
    Precision = TP/(TP+FP);
    Recall = TP/(TP+FN);
    FPR = FP/(TN+FP);
    FNR = FN/(TP+FN); 
    ACC = acc_num/size(test_label,2);
    F_score = (2 * Precision * Recall)/( Precision + Recall );

    [X_1,Y_1,T,AUC] = perfcurve(test_label,POSTERIOR_final,'1'); 
    
    TPR_all(c,:) = Recall;
    FPR_all(c,:) = FPR;
    FNR_all(c,:) = FNR;
    ACC_all(c,:) = ACC;
    F_score_all(c,:) = F_score;
    AUC_all(c,:) = AUC;
end

TPR_final = mean(TPR_all);
FPR_final = mean(FPR_all);
FNR_final = mean(FNR_all);
ACC_final = mean(ACC_all);
AUC_final = mean(AUC_all);












































