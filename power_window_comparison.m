%{
ANALYZE_TREATMENT_EFFECTS
--------------------------
This script loads power metrics from TTX gut motility experiments across
multiple treatments (N7-cut, saline control, and varying serotonin concentrations),
splits each movie into two time windows, and compares early vs. late intervals
using the Wilcoxon signed-rank test. The script then visualizes differences via
boxplots and paired line plots.

INPUTS:
- Data is loaded using `pooling_window()` which pulls power metrics for:
    - N7-cut: Movies 14,15,20,22,29,37
    - Saline: Movies 9,10,19,21,28,36
    - Serotonin (1μM, 10μM, 100μM): Multiple movie IDs each

PARAMETERS:
- `save_fig` : whether to save figures (not implemented here)
- `var`      : which metric to analyze ('power')
- `conc`     : current treatment ('N7', 'sal', or 'sero')
- `peri_path`: base path to load processed data files

OUTPUTS:
- Statistical comparisons between early and late time windows (Wilcoxon tests)
- Boxplots comparing power across time windows and treatments
- Overlaid paired scatter lines to visualize within-movie change

NOTES:
- Time windows: first and last 15 minutes of each movie
- Data structure: [N_samples x 3] array per window per condition
- Aggregated into p1_win1, p2_win1, p3_win1 (for early windows)
            and p1_win2, p2_win2, p3_win2 (for late windows)
- Test comparisons are: 
    - N7 vs Baseline (early and late)
    - Serotonin across doses (early vs late)

DEPENDENCIES:
- pooling_window.m
- Data must already be processed and saved as .mat files in `peri_path`
%}



% compare_treatment_effects
% --------------------------
% Modular function to compare early vs late window motility metrics
% across experimental treatments (N7 cut, saline control, serotonin).
% 
% USAGE:
% compare_treatment_effects('power', {'N7','sal','sero'})
% 
% INPUTS:
% var        : string, metric to analyze ('power', 'width', etc.)
% groups     : cell array of strings, treatments to include (e.g. {'N7','sal','sero'})


function power_window_comparison(var, groups)
    % Set paths
    peri_path = 'E:\Spandan\PSC Desktop Backup\New_Analysis\regularity_latest';
    save_fig = 'no';

    % Define experimental groups and movie indices
    group_data = struct(...
        'N7',   [14, 15, 20, 22, 29, 37], ...
        'sal',  [9, 10, 19, 21, 28, 36], ...
        '100',  [7, 13, 27, 32, 33, 40], ...
        '10',   [8, 12, 24, 26, 35, 39], ...
        '1',    [6, 18, 23, 30, 34, 38] ...
    );

    all_data_win1 = {}; all_data_win2 = {};

    for g = 1:length(groups)
        conc = groups{g};
        if strcmpi(conc, 'sero')
            conc_label = {'100','10','1'};
        else
            conc_label = {conc};
        end

        for cl = 1:length(conc_label)
            c = conc_label{cl};
            movie_ids = group_data.(c);
            dat1 = []; dat2 = [];

            for i = 1:length(movie_ids)
                [win1, win2] = pooling_window(peri_path, movie_ids(i), var, conc);
                dat1 = [dat1, win1];
                dat2 = [dat2, win2];
            end

            all_data_win1{end+1} = transpose(dat1(1,:));
            all_data_win2{end+1} = transpose(dat2(1,:));
        end
    end

    % Remove baseline N7 duplicate from serotonin if present
    if length(all_data_win1) > length(groups)
        all_data_win1(2) = [];
        all_data_win2(2) = [];
    end

    % Statistical test (early vs late)
    num_groups = length(all_data_win1);
    for i = 1:num_groups
        [pval, h] = signrank(all_data_win1{i}, all_data_win2{i});
        fprintf('Group %d: p = %.4f | Significant = %d\n', i, pval, h);
    end

    % Boxplot Visualization
    figure;
    combined_data = cell(num_groups * 2, 1);
    for i = 1:num_groups
        combined_data{2*i-1} = all_data_win1{i};
        combined_data{2*i}   = all_data_win2{i};
    end

    all_combined = cell2mat(combined_data);
    group_labels = repmat(1:(2*num_groups), size(all_data_win1{1}, 1), 1);

    boxplot(all_combined, group_labels(:), 'Whisker', 1.5, 'Widths', 0.1, 'BoxStyle', 'outline', 'Color', 'k');
    hold on;
    ylabel(['Avg. ' var],'fontsize',20,'FontWeight','bold');
    set(gca, 'fontsize', 20, 'FontWeight', 'bold');

    % Scatter overlay and paired lines
    x = zeros(length(combined_data{1}), length(combined_data));
    y = zeros(size(x));
    for i = 1:length(combined_data)
        h = scatter(rand(size(combined_data{i}))*0.1 + i, combined_data{i}, 30, 'filled', 'MarkerEdgeColor','k', 'MarkerFaceAlpha',.7, 'MarkerEdgeAlpha',1);
        x(:,i) = get(h, 'XData');
        y(:,i) = get(h, 'YData');
    end

    for i = 1:length(combined_data)/2
        for j = 1:length(x(:,1))
            line([x(j,2*i-1), x(j,2*i)], [y(j,2*i-1), y(j,2*i)], 'Color', [0.4660 0.6740 0.1880 0.5], 'LineWidth', 1, 'LineStyle', '--');
        end
    end

end
