%%
% Funtion which plot the dispersion and central values of the given vectors
% of the populations.
% Dispersion measurements: 
%   inter quartile range
%   mean absolute deviation
%   range
%   standard deviation
%   variance
% Central measurements:
%   mean
%   median
%   mode
% Others: 
%   maximum
%   minimum
%
% Paramenters:
%   measurementControl = array with the measurements of Control Subjects
%   measurementMCS     = array with the measurements of MCS patients
%   measurementVS      = array with the measurements of VS patients
%
% Return the subplot with the plot of each population vector, and the
% struct with the corresponding values:
%   FC = Plot of the measurements of Control subjects
%   FM = Plot of the measurements of MCS patients
%   FV = Plot of the measurements of VS patients
%   sC = Struct with the computed values for Control subjects
%   sM = Struct with the computed values for MCS patients
%   sV = Struct with the computed values for VS patients

function [FC, FM, FV, sC, sM, sV] =  pintarResultadosDispersionSlicingWindow( measurementControl, measurementMCS, measurementVS )
    sC.iqr    = iqr(measurementControl,2);     % inter quartile range
    sC.mad    = mad(measurementControl,0,2);   % mean absolute deviation
    sC.range  = range(measurementControl,2);   % Range
    sC.std    = std(measurementControl,0,2);   % Standard deviation
    sC.var    = var(measurementControl,0,2);   % Variance
    sC.mean   = mean(measurementControl,2);    % Mean
    sC.median = median(measurementControl,2);  % Median
    sC.mode   = mode(measurementControl,2);    % Mode
    sC.max    = max(measurementControl,[],2);  % Maximum
    sC.min    = min(measurementControl,[],2);  % Minimum
    
    sM.iqr    = iqr(measurementMCS,2);     % inter quartile range
    sM.mad    = mad(measurementMCS,0,2);   % mean absolute deviation
    sM.range  = range(measurementMCS,2);   % Range
    sM.std    = std(measurementMCS,0,2);   % Standard deviation
    sM.var    = var(measurementMCS,0,2);   % Variance
    sM.mean   = mean(measurementMCS,2);    % Mean
    sM.median = median(measurementMCS,2);  % Median
    sM.mode   = mode(measurementMCS,2);    % Mode
    sM.max    = max(measurementMCS,[],2);  % Maximum
    sM.min    = min(measurementMCS,[],2);  % Minimum
    
    sV.iqr    = iqr(measurementVS,2);     % inter quartile range
    sV.mad    = mad(measurementVS,0,2);   % mean absolute deviation
    sV.range  = range(measurementVS,2);   % Range
    sV.std    = std(measurementVS,0,2);   % Standard deviation
    sV.var    = var(measurementVS,0,2);   % Variance
    sV.mean   = mean(measurementVS,2);    % Mean
    sV.median = median(measurementVS,2);  % Median
    sV.mode   = mode(measurementVS,2);    % Mode
    sV.max    = max(measurementVS,[],2);  % Maximum
    sV.min    = min(measurementVS,[],2);  % Minimum

    FC = figure;
    subplot(3,4,1)
    plot(sC.iqr, 'Linestyle', 'none', 'Marker', 'h', 'Color', 'b');
    title('interquartile range')
    subplot(3,4,2)
    plot(sC.mad, 'Linestyle', 'none', 'Marker', 'p', 'Color', 'b');
    title('Mean Absolute deviation')
    subplot(3,4,3)
    plot(sC.range, 'Linestyle', 'none', 'Marker', 'o', 'Color', 'b');
    title('Range')
    subplot(3,4,4)
    plot(sC.var, 'Linestyle', 'none', 'Marker', '*', 'Color', 'b');
    title('Variance')
    subplot(3,4,5)
    plot(sC.std, 'Linestyle', 'none', 'Marker', '*', 'Color', 'b');
    title('Standard deviation')
    subplot(3,4,6)
    plot(sC.mean, 'Linestyle', 'none', 'Marker', '+', 'Color', 'b');
    title('Mean')
    subplot(3,4,7)
    plot(sC.median, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'b');
    title('Median')
    subplot(3,4,8)
    plot(sC.mode, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'b');
    title('Mode')
    subplot(3,4,9)
    plot(sC.max, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'b');
    title('Maximum')
    subplot(3,4,10)
    plot(sC.min, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'b');
    title('Minimum')
    subplot(3,4,11)
    errorbar(sC.mean,sC.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'b')
    title('mean/std')
    subplot(3,4,12)
    errorbar(1:length(sC.mean),sC.mean,(sC.mean - sC.min), (sC.max-sC.mean), 'Linestyle', 'none', 'Marker', '+', 'Color', 'b')
    title('minimum - mean - maximum')
    
    FM = figure;
    subplot(3,4,1)
    plot(sM.iqr, 'Linestyle', 'none', 'Marker', 'h', 'Color', 'g');
    title('interquartile range')
    subplot(3,4,2)
    plot(sM.mad, 'Linestyle', 'none', 'Marker', 'p', 'Color', 'g');
    title('Mean Absolute deviation')
    subplot(3,4,3)
    plot(sM.range, 'Linestyle', 'none', 'Marker', 'o', 'Color', 'g');
    title('Range')
    subplot(3,4,4)
    plot(sM.var, 'Linestyle', 'none', 'Marker', '*', 'Color', 'g');
    title('Variance')
    subplot(3,4,5)
    plot(sM.std, 'Linestyle', 'none', 'Marker', '*', 'Color', 'g');
    title('Standard deviation')
    subplot(3,4,6)
    plot(sM.mean, 'Linestyle', 'none', 'Marker', '+', 'Color', 'g');
    title('Mean')
    subplot(3,4,7)
    plot(sM.median, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'g');
    title('Median')
    subplot(3,4,8)
    plot(sM.mode, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'g');
    title('Mode')
    subplot(3,4,9)
    plot(sM.max, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'g');
    title('Maximum')
    subplot(3,4,10)
    plot(sM.min, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'g');
    title('Minimum')
    subplot(3,4,11)
    errorbar(sM.mean,sM.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'g')
    title('mean/std')
    subplot(3,4,12)
    errorbar(1:length(sM.mean),sM.mean,(sM.mean - sM.min), (sM.max-sM.mean), 'Linestyle', 'none', 'Marker', '+', 'Color', 'g')
    title('minimum - mean - maximum')
    
    FV = figure;
    subplot(3,4,1)
    plot(sV.iqr, 'Linestyle', 'none', 'Marker', 'h', 'Color', 'r');
    title('interquartile range')
    subplot(3,4,2)
    plot(sV.mad, 'Linestyle', 'none', 'Marker', 'p', 'Color', 'r');
    title('Mean Absolute deviation')
    subplot(3,4,3)
    plot(sV.range, 'Linestyle', 'none', 'Marker', 'o', 'Color', 'r');
    title('Range')
    subplot(3,4,4)
    plot(sV.var, 'Linestyle', 'none', 'Marker', '*', 'Color', 'r');
    title('Variance')
    subplot(3,4,5)
    plot(sV.std, 'Linestyle', 'none', 'Marker', '*', 'Color', 'r');
    title('Standard deviation')
    subplot(3,4,6)
    plot(sV.mean, 'Linestyle', 'none', 'Marker', '+', 'Color', 'r');
    title('Mean')
    subplot(3,4,7)
    plot(sV.median, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'r');
    title('Median')
    subplot(3,4,8)
    plot(sV.mode, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'r');
    title('Mode')
    subplot(3,4,9)
    plot(sV.max, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'r');
    title('Maximum')
    subplot(3,4,10)
    plot(sV.min, 'Linestyle', 'none', 'Marker', 'x', 'Color', 'r');
    title('Minimum')
    subplot(3,4,11)
    errorbar(sV.mean,sV.std, 'Linestyle', 'none', 'Marker', '+', 'Color', 'r')
    title('mean/std')
    subplot(3,4,12)
    errorbar(1:length(sV.mean),sV.mean,(sV.mean - sV.min), (sV.max-sV.mean), 'Linestyle', 'none', 'Marker', '+', 'Color', 'r')
    title('minimum - mean - maximum')
end