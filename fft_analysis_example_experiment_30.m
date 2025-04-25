%{
This script analyzes motility kymograph data from a multi-phase gut motility experiment.
It performs:
 - Preprocessing: NaN removal, mean subtraction, spatial scaling to mm/s
 - Spectral analysis: temporal bandpower, spatial bandpower, and frequency-domain PSD
 - Visualization: frequency spectra, bandpower over time, and along gut length
 - Optional: comparison with theoretical models (Damped Brownian, Planck-like)

Example use case:
    Experiment number: 30
    Phases analyzed: 
        p1 – Baseline
        p2 – N7 cut
        p3 – 1µM 5HT
    File path: E:\Spandan\PSC Desktop Backup\kymo_files\
    Sampling frequency: 3 Hz
    Gut length: 24.12 mm

Figures produced:
    Figure 1 – PSD vs Frequency for all 3 phases
    Figure 2 – Bandpower vs Time (with smoothed curves)
    Figure 3 – Bandpower vs Gut Position (mm)
    Figure 4 – PSD comparison with Planck-like model (background removal)
%}

clear;

%% ------------------------- PARAMETERS & LOADING ------------------------
n = 30;                  % Experiment number
m = 3;                   % Number of experimental phases
re_len = 24.12;          % Real gut length in mm
Fs = 3;                  % Sampling frequency in Hz
file_path = 'E:\Spandan\PSC Desktop Backup\kymo_files';

v = cell(1, m);          % Store velocity matrices

for i = 1:m
    mat = load(fullfile(file_path, ['expt' num2str(n) '_p' num2str(i) '.mat']));
    v{i} = mat.vy2avg;
end

num_rows = size(v{1}, 1);  % Gut length in pixels

% Preprocessing: scale, clean, subtract mean
for i = 1:m
    v{i} = Fs * double(v{i}) * re_len / num_rows;
    v{i}(isnan(v{i})) = 0;
    v{i} = mean_subtract(v{i});
end

%% --------------------- BANDPOWER & SPECTRAL ANALYSIS -------------------
bp = cell(1, m); bandpow = cell(1, m); p_mean = cell(1, m); f = cell(1, m);

for i = 1:m
    bp{i} = bandpower(v{i});
    bandpow{i} = bandpower(v{i}');  % spatial (gut-wise)
    [pow, f{i}] = periodogram(v{i}', [], [], Fs);
    p_mean{i} = mean(pow, 2);
end

%% --------------------- PSD vs Frequency Plot ---------------------------
figure(1); hold on;
colors = {[0.4660 0.6740 0.1880], [0.6350 0.0780 0.1840], [0 0.4470 0.7410]};
labels = {'Baseline', 'N7 cut', '1µM 5HT'};

for i = 1:m
    id = find(f{i} <= 1.0, 1, 'last');
    plot(f{i}(1:id), movmean(p_mean{i}(1:id), 1), ...
        'Color', colors{i}, 'LineWidth', 2);
end

xticks(linspace(0,1.0,6));
xticklabels({'0','0.2','0.4','0.6','0.8','1.0'});
legend(labels, 'Location', 'best');
xlabel('Frequency (Hz)', 'FontWeight', 'bold', 'FontSize', 16);
ylabel('PSD (mm/s)^2/Hz', 'FontWeight', 'bold', 'FontSize', 16);
set(gca, 'FontSize', 16, 'FontWeight', 'bold');

%% ------------------ Bandpower vs Time Plot -----------------------------
figure(2); hold on;
T = cell(1, m); start_time = 0;

for i = 1:m
    len = size(v{i}, 2);
    T{i} = (1:len) / (Fs * 60) + start_time;
    start_time = T{i}(end);
end

for i = 1:m
    plot(T{i}, movmean(double(bp{i}), 40), 'LineWidth', 2, 'Color', colors{i}); hold on;
    plot(T{i}, movmean(double(bp{i}), 200), 'LineWidth', 2, 'Color', 'k');
end

xticks(linspace(0,95,10));
xticklabels({'0','10','20','30','40','50','60','70','80','90'});
legend(labels, 'Location', 'north');
xlabel('Time (min.)', 'FontWeight', 'bold', 'FontSize', 16);
ylabel('Power (mm/s)^2', 'FontWeight', 'bold', 'FontSize', 16);
set(gca, 'FontSize', 16, 'FontWeight', 'bold');

%% --------------- Bandpower vs Gut Location Plot ------------------------
figure(3); hold on;
x_axis = linspace(0, re_len, num_rows);  % gut position in mm
for i = 1:m
    plot(x_axis, bandpow{i}, 'Color', colors{i}, 'LineWidth', 2);
end

legend(labels, 'Location', 'best');
xlabel('Gut position (mm)', 'FontWeight', 'bold', 'FontSize', 16);
ylabel('Power (mm/s)^2', 'FontWeight', 'bold', 'FontSize', 16);
set(gca, 'FontSize', 16, 'FontWeight', 'bold');

%% ------------ Damped Brownian Motion: Theoretical PSD ------------------
% Optional: visual comparison with idealized noise spectrum
figure;
freq = 0:0.001:2.5; gamma = 10; sigma = 1.0;
S = sigma^2 ./ (2*gamma^2 + 2*pi^2*freq.^2);
plot(freq, S, 'LineWidth', 2);
xlabel('Frequency (Hz)', 'FontWeight', 'bold', 'FontSize', 16);
ylabel('PSD (A.U.)', 'FontWeight', 'bold', 'FontSize', 16);
title('Damped Brownian Motion PSD');
set(gca, 'FontSize', 14, 'FontWeight', 'bold');

%% -------------- PSD Background Removal Using Planck Model --------------
% Generate Planck-like background from baseline frequency axis
freq = f{1}; k = 10; c = 0.014;
planck = c * (k * freq).^3 ./ (exp(k * freq) - 1);

p_diff = cellfun(@(p) abs(movmean(p, 10) - planck), p_mean, 'UniformOutput', false);

% Visualize original and background-subtracted PSD
figure;
for i = 1:m
    subplot(m,2,2*i-1);
    plot(freq, movmean(p_mean{i},10), 'LineWidth', 1); xlim([0 1]); ylim([0 0.09]);
    title(labels{i}); set(gca, 'FontSize', 12, 'FontWeight', 'bold');

    subplot(m,2,2*i);
    plot(freq, p_diff{i}, 'LineWidth', 1); xlim([0 1]); ylim([0 0.09]);
    set(gca, 'FontSize', 12, 'FontWeight', 'bold');
end

% Shared axis labels and title
han = axes('visible', 'off');
han.Title.Visible = 'on'; han.XLabel.Visible = 'on'; han.YLabel.Visible = 'on';
xlabel(han, 'Frequency (Hz)', 'FontWeight', 'bold', 'FontSize', 13);
ylabel(han, 'PSD (mm/s)^2/Hz', 'FontWeight', 'bold', 'FontSize', 13);
title(han, 'PSD Background Removal', 'FontWeight', 'bold', 'FontSize', 14);