clear all
close all
clc

load('p2_subject1Post.mat');

labels = [subject1Post.MI(1).hdr.emgLabels; subject1Post.MI(2).hdr.emgLabels; subject1Post.MI(3).hdr.emgLabels];
signal = [subject1Post.MI(1).eeg; subject1Post.MI(2).eeg; subject1Post.MI(3).eeg];
triggers = [subject1Post.MI(1).hdr.triggers; subject1Post.MI(2).hdr.triggers; subject1Post.MI(3).hdr.triggers];
fs = subject1Post.MI(1).hdr.fs;
%disp(length(subject1Pre.MI(1).emg(:,1)));
time = 0:1/fs:length(signal(:,1))/fs-1/fs;


[rows_start_1,cols_start_1,values_start_1] = find(triggers==101);
timings_start_act = triggers(rows_start_1);

[rows_end_1,cols_end_1,values_end_1] = find(triggers==102);
%disp(triggers);
timings_end_act = triggers(rows_end_1);


[rows_start_2,cols_start_2,values_start_2] = find(triggers==201);

[rows_end_2,cols_end_2,values_end_2] = find(triggers==202);


trigger_plot_1 = zeros(length(signal), 1);
trigger_plot_2 = zeros(length(signal), 1);

for x = 1:length(rows_start_1)
    start = rows_start_1(x);
    ending = rows_end_1(x);
    trigger_plot(start:ending) = 1;
end

for x = 1:length(rows_start_2)
    start = rows_start_2(x);
    ending = rows_end_2(x);
    trigger_plot(start:ending) = 1;
end

Rise1 = find(triggers==101); % gets the starting points of stimulations
Fall1 = find(triggers==102); % gets the ending points of stimulations
Rise2 = find(triggers==201); % gets the starting points of stimulations
Fall2 = find(triggers==202); % gets the ending points of stimulations
WSize = 0.1;
Olap = 0.25;
WSize = floor(WSize*fs);
nOlap = floor(Olap*WSize);  % overlap of successive frames, half of WSize
hop = WSize-nOlap;	    % amount to advance for next data frame




nx = length(signal);	            % length of input vector
len = fix((nx - (WSize-hop))/hop);	%length of output vector = total frames
MAV = deal(zeros(1,len));
feat_labels_1 = deal(zeros(1,len));
feat_labels_2 = deal(zeros(1,len));
%MAV = movmean(signal, WSize);
%disp(MAV);

for i = 1:len
    segment = signal(((i-1)*hop+1):((i-1)*hop+WSize),4);
    MAV(i) = sum(abs(segment)) / WSize;
    feat_labels_1(i) = sum(arrayfun(@(t) ((i-1)*hop+1) >= Rise1(t) && ((i-1)*hop+WSize) <= Fall1(t), 1:length(Rise1)));
    feat_labels_2(i) = sum(arrayfun(@(t) ((i-1)*hop+1) >= Rise2(t) && ((i-1)*hop+WSize) <= Fall2(t), 1:length(Rise2)));
end

feat_labels_1(feat_labels_1==1) = 1000;
feat_labels_2(feat_labels_2==1) = 1000;
%disp(feat_labels_1);
%disp(size(MAV));
plot((1:length(MAV)), MAV, 'g');
hold on
plot((1:length(feat_labels_1)), feat_labels_1, 'b');
hold on
plot((1:length(feat_labels_2)), feat_labels_2, 'r');

MAV_class1 = MAV(find(feat_labels_1==1000));
MAV_rest1 = MAV(find(feat_labels_1 == 0 & feat_labels_2 == 0));
MAV_Data_Class1vsRest = [MAV_class1 MAV_rest1];
MAV_Labels_Class1vsRest = [ones(1,length(MAV_class1)) 2*ones(1,length(MAV_rest1))];

MAV_class2 = MAV(find(feat_labels_1==1000));
MAV_rest2 = MAV(find(feat_labels_1 == 0 & feat_labels_2 == 0));
MAV_Data_Class2vsRest = [MAV_class2 MAV_rest2];
MAV_Labels_Class2vsRest = [ones(1,length(MAV_class2)) 2*ones(1,length(MAV_rest2))];

MAV_Data_Class1vsClass2 = [MAV_class1 MAV_class2];
MAV_Labels_Class1vsClass2 = [ones(1,length(MAV_class1)) 2*ones(1,length(MAV_class2))];

k = 10; % for k-fold cross validation
c1 = cvpartition(length(MAV_Labels_Class1vsRest),'KFold',k);
c1_acc_avg = 0;
c2 = cvpartition(length(MAV_Labels_Class2vsRest),'KFold',k);
c2_acc_avg = 0;
c3 = cvpartition(length(MAV_Labels_Class1vsClass2),'KFold',k);
c3_acc_avg = 0;
i=1;
% loop over all k-folds and avergae the performance
for i=1:k
    [TstMAVFC1Rest TstMAVErrC1Rest] = classify(MAV_Data_Class1vsRest(c1.test(i))',MAV_Data_Class1vsRest(c1.training(i))',MAV_Labels_Class1vsRest(c1.training(i)));
    [TstCM_MAV_C1rest dum1 TstAcc_MAV_C1rest dum2] = confusion(MAV_Labels_Class1vsRest(c1.test(i)), TstMAVFC1Rest);
    c1_acc_avg = c1_acc_avg + TstAcc_MAV_C1rest;
    [TstMAVFC2Rest TstMAVErrC2Rest] = classify(MAV_Data_Class2vsRest(c2.test(i))',MAV_Data_Class2vsRest(c2.training(i))',MAV_Labels_Class2vsRest(c2.training(i)));
    [TstCM_MAV_C2rest dum1 TstAcc_MAV_C2rest dum2] = confusion(MAV_Labels_Class2vsRest(c2.test(i)), TstMAVFC2Rest);
    c2_acc_avg = c2_acc_avg + TstAcc_MAV_C2rest;
    [TstMAVFC1C2 TstMAVErrC1C2] = classify(MAV_Data_Class1vsClass2(c3.test(i))',MAV_Data_Class1vsClass2(c3.training(i))',MAV_Labels_Class1vsClass2(c3.training(i)));
    [TstCM_MAV_C1C2 dum1 TstAcc_MAV_C1C2 dum2] = confusion(MAV_Labels_Class1vsClass2(c3.test(i)), TstMAVFC1C2);
    c3_acc_avg = c3_acc_avg + TstAcc_MAV_C1C2;
end

c1_acc_avg = c1_acc_avg / 10;
disp(c1_acc_avg);
c2_acc_avg = c2_acc_avg / 10;
disp(c2_acc_avg);
c3_acc_avg = c3_acc_avg / 10;
disp(c3_acc_avg);
