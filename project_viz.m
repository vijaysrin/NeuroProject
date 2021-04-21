clear all
close all
clc

load('p2_subject1Pre.mat');
whos subject1Pre.noMI.hdr.triggers

labels = subject1Pre.MI(1).hdr.emgLabels;
signal = subject1Pre.MI(1).emg;
fs = subject1Pre.MI(1).hdr.fs;
%disp(length(signal(:,1)));
time = 0:1/fs:length(signal(:,1))/fs-1/fs;

disp(length(subject1Pre.MI(1).hdr.triggers));
disp(length(signal));

figure('units','normalized','Position',[0.1,0.1,0.5,0.5])
plot(time, signal);