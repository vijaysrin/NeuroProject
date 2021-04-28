clear all
close all
clc

load('p2_subject1Pre.mat');
whos subject1Pre.noMI.hdr.triggers

%% Get Data from File
labels = subject1Pre.MI(1).hdr.emgLabels;
signal = subject1Pre.MI(1).emg;
triggers = subject1Pre.MI(1).hdr.triggers;
fs = subject1Pre.MI(1).hdr.fs;
%disp(length(signal(:,1)));
time = 0:1/fs:length(signal(:,1))/fs-1/fs;

%% Find thresholds for triggers
[rows_zero, cols_zero, values_zero] = find(signal(:,1) == 0);
end_val = rows_zero(1);
signal_trunc = signal(1:end_val,1:4);



[rows_start_a,cols_start_a,values_start_a] = find(triggers==101|triggers==201);
timings_start_act = triggers(rows_start_a);

[rows_end_a,cols_end_a,values_end_a] = find(triggers==102|triggers==202);
%disp(triggers);
timings_end_act = triggers(rows_end_a);



trigger_plot = zeros(length(signal), 1) - 4000;


%% get active and resting parts of signal
for x = 1:length(rows_start_a)
    start = rows_start_a(x);
    ending = rows_end_a(x);
    trigger_plot(start:ending) = -3500;
end

[final_act_timings, final_act_values] = find(trigger_plot==-3500);
[final_rest_timings, final_rest_values] = find(trigger_plot==-4000);

signal_act = signal(final_act_timings);
signal_rest = signal(final_rest_timings);


%disp(trigger_plot);
%% Plot the raw signal
figure('units','normalized','Position',[0.1,0.1,0.5,0.5])
plot(time(1:end_val-1), signal(1:end_val-1,1:4));
hold on
plot(time(1:end_val-1), trigger_plot(1:end_val-1));
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('Run 1 Subject 1 Raw EMG Data with Triggers')
legend([labels 'Triggers'])
%saveas(gcf, 'sub1_raw_emg.png');

%% PSD Plots
figure('units','normalized','Position',[0.1,0.1,0.5,0.5])
h = spectrum.welch;
SOIf=psd(h,signal_rest,'Fs',fs); % calculates and plot the one sided PSD
plot(SOIf); % Plot the one-sided PSD. 
temp =get(gca);
temp.Children(1).Color = 'b';
hold on
h = spectrum.welch; % creates the Welch spectrum estimator
SOIf=psd(h,signal_act,'Fs',fs); % calculates and plot the one sided PSD
plot(SOIf); % Plot the one-sided PSD. 
temp2 =get(gca);
temp2.Children(1).Color = 'r';
legend('Resting', 'Active');
saveas(gcf, 'PSD_unfiltered.png');