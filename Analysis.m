  
clear all
close all
clc

load('p2_subject1Pre.mat');
load('p2_subject1Post.mat');

load('p2_subject2Pre.mat');
load('p2_subject2Post.mat');

global fs;

%% SUBJECT 1
%Calculate the correlation of the EEG and EMG signals before and after
%session2. POST session 2 should be higher than PRE.
Sub1PreMI1_EEG = actSignal(subject1Pre.MI(1), 'EEG'); 
Sub1PreMI2_EEG = actSignal(subject1Pre.MI(2), 'EEG'); 
Sub1PreMI3_EEG = actSignal(subject1Pre.MI(3), 'EEG');

Sub1PreMI1_EMG = actSignal(subject1Pre.MI(1), 'EMG'); 
Sub1PreMI2_EMG = actSignal(subject1Pre.MI(2), 'EMG'); 
Sub1PreMI3_EMG = actSignal(subject1Pre.MI(3), 'EMG');

PREcorrelation1 = mean(xcorr(Sub1PreMI1_EEG, Sub1PreMI1_EMG));
PREcorrelation2 = mean(xcorr(Sub1PreMI2_EEG, Sub1PreMI2_EMG));
PREcorrelation3 = mean(xcorr(Sub1PreMI3_EEG, Sub1PreMI3_EMG));

PREcorrelationAvgSubject1 = (PREcorrelation1 + PREcorrelation2 + PREcorrelation3)/3;
display(PREcorrelationAvgSubject1);

Sub1PostMI1_EEG = actSignal(subject1Post.MI(1), 'EEG'); 
Sub1PostMI2_EEG = actSignal(subject1Post.MI(2), 'EEG'); 
Sub1PostMI3_EEG = actSignal(subject1Post.MI(3), 'EEG');

Sub1PostMI1_EMG = actSignal(subject1Post.MI(1), 'EMG'); 
Sub1PostMI2_EMG = actSignal(subject1Post.MI(2), 'EMG'); 
Sub1PostMI3_EMG = actSignal(subject1Post.MI(3), 'EMG');

POSTcorrelation1 = mean(xcorr(Sub1PostMI1_EEG, Sub1PostMI1_EMG));
POSTcorrelation2 = mean(xcorr(Sub1PostMI2_EEG, Sub1PostMI2_EMG));
POSTcorrelation3 = mean(xcorr(Sub1PostMI3_EEG, Sub1PostMI3_EMG));

POSTcorrelationAvgSubject1 = (POSTcorrelation1 + POSTcorrelation2 + POSTcorrelation3)/3;
display(POSTcorrelationAvgSubject1);

%% SUBJECT 2
Sub2PreMI1_EEG = actSignal(subject2Pre.MI(1), 'EEG'); 
Sub2PreMI2_EEG = actSignal(subject2Pre.MI(2), 'EEG'); 
Sub2PreMI3_EEG = actSignal(subject2Pre.MI(3), 'EEG');

Sub2PreMI1_EMG = actSignal(subject2Pre.MI(1), 'EMG'); 
Sub2PreMI2_EMG = actSignal(subject2Pre.MI(2), 'EMG'); 
Sub2PreMI3_EMG = actSignal(subject2Pre.MI(3), 'EMG');

PREcorrelation1 = mean(xcorr(Sub2PreMI1_EEG, Sub2PreMI1_EMG));
PREcorrelation2 = mean(xcorr(Sub2PreMI2_EEG, Sub2PreMI2_EMG));
PREcorrelation3 = mean(xcorr(Sub2PreMI3_EEG, Sub2PreMI3_EMG));

PREcorrelationAvgSubject2 = (PREcorrelation1 + PREcorrelation2 + PREcorrelation3)/3;
display(PREcorrelationAvgSubject2);

Sub2PostMI1_EEG = actSignal(subject2Post.MI(1), 'EEG'); 
Sub2PostMI2_EEG = actSignal(subject2Post.MI(2), 'EEG'); 
Sub2PostMI3_EEG = actSignal(subject2Post.MI(3), 'EEG');

Sub2PostMI1_EMG = actSignal(subject2Post.MI(1), 'EMG'); 
Sub2PostMI2_EMG = actSignal(subject2Post.MI(2), 'EMG'); 
Sub2PostMI3_EMG = actSignal(subject2Post.MI(3), 'EMG');

POSTcorrelation1 = mean(xcorr(Sub2PostMI1_EEG, Sub2PostMI1_EMG));
POSTcorrelation2 = mean(xcorr(Sub2PostMI2_EEG, Sub2PostMI2_EMG));
POSTcorrelation3 = mean(xcorr(Sub2PostMI3_EEG, Sub2PostMI3_EMG));

POSTcorrelationAvgSubject2 = (POSTcorrelation1 + POSTcorrelation2 + POSTcorrelation3)/3;
display(POSTcorrelationAvgSubject2);

%% Get Only the Act Part of the Signal

function signal_act = actSignal(run, type) %run would be like subject1Pre.MI(1)
    
    global fs;
    % Get Data from File
    labels = run.hdr.emgLabels;
    if (type == 'EMG')
        signal = run.emg;
    end
    if (type == 'EEG')
        signal = run.eeg;
    end
    triggers = run.hdr.triggers;
    fs = run.hdr.fs;
    time = 0:1/fs:length(signal(:,1))/fs-1/fs;

    % Find thresholds for triggers
    [rows_zero, cols_zero, values_zero] = find(signal(:,1) == 0);
    end_val = rows_zero(1);
    signal_trunc = signal(1:end_val,1:4);

    [rows_start_a,cols_start_a,values_start_a] = find(triggers==101|triggers==201);
    timings_start_act = triggers(rows_start_a);

    [rows_end_a,cols_end_a,values_end_a] = find(triggers==102|triggers==202);
    timings_end_act = triggers(rows_end_a);

    trigger_plot = zeros(length(signal), 1) - 4000;

    % get active and resting parts of signal
    for x = 1:length(rows_start_a)
      start = rows_start_a(x);
      ending = rows_end_a(x);
     trigger_plot(start:ending) = -3500;
    end

    [final_act_timings, final_act_values] = find(trigger_plot==-3500);
    [final_rest_timings, final_rest_values] = find(trigger_plot==-4000);

    signal_act = signal(final_act_timings);
    signal_rest = signal(final_rest_timings);

    
    signal_act = bandpass(8, 12, signal_act); %Bandpass filtering between 7 and 12 Hz. I think that is a typical range.
    signal_act = movmean(signal_act, 15); %Moving average with window size = 15 points
    %figure();
    %plot(signal_act);

end

%% Bandpass Filtering

    function filteredSignal = bandpass(fc1, fc2, signal)
    
        global fs

        % normalize the frequencies
        Wp = [fc1 fc2]*2/fs;
        
        % Butterworth bandpass filter of 4th order

        [z,p,k] = butter(4,Wp,'bandpass');
        [sos,g]=zp2sos(z,p,k);
        filteredSignal=filtfilt(sos,g,signal);
        
    end