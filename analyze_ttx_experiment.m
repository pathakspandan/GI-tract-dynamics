function analyze_ttx_experiment(config)

% ANALYZE_TTX_EXPERIMENT Modular analysis of TTX gut motility data across multiple phases
%
% This function performs batch analysis of dorsoventral velocity kymographs
% from TTX experiments, computing frequency-based motility metrics and visualizing
% changes in bandpower over time across multiple experimental phases.
%
% INPUT:
%   config : struct with the following fields:
%       .month              - string: experiment month (e.g., '09')
%       .date               - string: experiment date (e.g., '11')
%       .phase_files        - cell array of strings: .mat filenames for each phase
%       .gap_mins           - vector of numeric gaps (in minutes) between phases
%       .n_parts            - vector of ints: number of time windows per phase
%       .re_len             - (optional) gut length in mm (default: 19.79)
%       .Fs                 - (optional) sampling frequency in Hz (default: 3)
%       .f_span             - (optional) frequency window around peak (default: 0.04)
%       .area_thresh        - (optional) minimum size threshold for wave detection (default: 100)
%       .smoothing_window   - (optional) window size for smoothing (default: 180)
%       .plot_ylim          - 2-element vector [min, max] for y-axis limits of power plot
%       .legend_labels      - cell array of strings: labels for each phase in the plot
%       .save_flag          - 0 or 1: if 1, saves regularity and peristalsis data
%
% OUTPUT:
%   - A figure showing smoothed bandpower (mm/s)^2 vs. time (minutes),
%     with separate curves for each phase and vertical lines marking transitions.
%   - If `save_flag == 1`, saves the following files per phase:
%       > Regularity data: 'reg_TTX_<month><date>_<phase_file>.mat'
%       > Peristalsis data: 'sv_TTX_<month><date>_<phase_file>.mat'
%
% NOTE:
%   - This function does not return any variables to the workspace.
%   - Assumes all .mat files contain a variable like `vy2avg` (2D velocity matrix).
%
% EXAMPLE USAGE:
%   config.month = '09';
%   config.date = '11';
%   config.phase_files = {'TTX_091123_p1.mat', 'TTX_091123_p2.mat', 'TTX_091123_p3.mat'};
%   config.n_parts = [2, 2, 12];
%   config.gap_mins = [910, 27];
%   config.plot_ylim = [0 1e-3];
%   config.legend_labels = {'Baseline', 'TTX', '3-hour wash'};
%   config.save_flag = 0;
%   analyze_ttx_experiment(config);

% Defaults
if ~isfield(config, 're_len'), config.re_len = 19.79; end
if ~isfield(config, 'Fs'), config.Fs = 3; end
if ~isfield(config, 'f_span'), config.f_span = 0.04; end
if ~isfield(config, 'area_thresh'), config.area_thresh = 100; end
if ~isfield(config, 'smoothing_window'), config.smoothing_window = 180; end

n_phases = length(config.phase_files);
v_all = cell(1, n_phases);
bp_all = cell(1, n_phases);
T_all = cell(1, n_phases);

% Load, preprocess, and compute metrics
for i = 1:n_phases
    file_path = fullfile('E:\Spandan\TTX\Experiments', ...
        ['TTX_Experiments_', config.month, '_', config.date], config.phase_files{i});
    mat = load(file_path);
    field = fieldnames(mat); v = mat.(field{1});
    v(isnan(v)) = 0; v = mean_subtract(double(v));

    % Save if required
    reg_file = fullfile('E:\Spandan\TTX\Regularity_Data', ...
        ['reg_TTX_', config.month, config.date, '_', config.phase_files{i}]);
    per_file = fullfile('E:\Spandan\TTX\Peristaltic_Data', ...
        ['sv_TTX_', config.month, config.date, '_', config.phase_files{i}]);

    [~,~,~,~,~,~] = windowing(config.save_flag, reg_file, v, config.n_parts(i), ...
        config.Fs, config.re_len, config.f_span);
    [~,~,~,~,~,~] = peristaltic_windowing(config.save_flag, per_file, v, ...
        config.n_parts(i), config.Fs, config.re_len, config.area_thresh);

    % Scale and store bandpower
    L = size(v,1);
    v = v * config.Fs * config.re_len / L;
    v_all{i} = v;
    bp_all{i} = bandpower(v);
end

% Time axes with gaps
for i = 1:n_phases
    len = size(v_all{i}, 2);
    T = (1:len) / (config.Fs * 60);  % in minutes
    if i > 1
        gap_total = sum(config.gap_mins(1:i-1)) / 60; % convert to minutes
        T = T + T_all{i-1}(end) + gap_total;
    end
    T_all{i} = T;
end

% Plot
figure;
hold on;
colors = lines(n_phases);

for i = 1:n_phases
    plot(T_all{i}, movmean(double(bp_all{i}), config.smoothing_window), ...
        'LineWidth', 1.5, 'Color', colors(i,:));
end

% Add vertical lines at phase boundaries
for i = 1:n_phases-1
    xline(T_all{i}(end), '--', 'LineWidth', 1.5);
    xline(T_all{i+1}(1), '--', 'LineWidth', 1.5);
end

% Style
ylim(config.plot_ylim);
xlim([0 T_all{end}(end)]);
xlabel('Time (min.)','fontweight','bold','FontSize',16);
ylabel('Power (mm/s)^2','fontweight','bold','FontSize',16);
legend(config.legend_labels, 'Location', 'north east');
set(gca, 'FontSize', 16, 'FontWeight', 'bold');
end


% Example Usage
% config.month = '09';
% config.date = '11';
% config.phase_files = {'TTX_091123_p1.mat', 'TTX_091123_p2.mat', 'TTX_091123_p3.mat'};
% config.n_parts = [2, 2, 12];
% config.gap_mins = [910, 27];
% config.plot_ylim = [0 1e-3];
% config.legend_labels = {'Baseline', 'TTX', '3-hour wash'};
% config.save_flag = 0;
% 
% analyze_ttx_experiment(config);