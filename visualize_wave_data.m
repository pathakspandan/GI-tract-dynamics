function visualize_wave_data(phases, metric_list, variable, cmap, shapes, selected_metrics)
%{
visualize_wave_data loads, processes, and visualizes wave frequency data 
across experimental phases for different metrics.

INPUTS:
- phases: cell array of strings indicating experimental phases 
          (e.g., {'p1','p2','p3'})
- metric_list: cell array of metric types (e.g., {'ap', 'pa', 'sw', 'tot'})
- variable: string, used for filtering data in `removal_control` 
            (e.g., 'N7', 'sal')
- cmap: colormap matrix [N x 3] used for coloring scatter points
- shapes: character array specifying marker shape per group 
          (e.g., ['o'; 'p'; 'd'])
- selected_metrics: cell array of groupings to compare, where each group 
                    is a cell array of metric_phase combinations 
                    (e.g., {'ap_p1', 'ap_p2'})

OUTPUTS:
- No returned variables. The function directly generates the following plots:
    - One figure with subplots, one for each comparison group in 
      `selected_metrics`
    - Each subplot contains:
        • Boxplots of selected metric data across phases
        • Overlayed scatter points for individual data points
        • Paired lines connecting matched data points (if applicable)

USAGE EXAMPLE:
    phases = {'p1', 'p2', 'p3'};
    metric_list = {'ap', 'pa', 'sw', 'tot'};
    variable = 'N7';
    cmap = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; ...
            0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560];
    shapes = ['o'; 'p'; 'd'; 's'];
    selected_metrics = {
        {'ap_p1', 'ap_p2', 'ap_p3'},
        {'tot_p2', 'tot_p3'}
    };
    visualize_wave_data(phases, metric_list, variable, cmap, shapes, selected_metrics);

NOTES:
- Assumes a fixed base path for loading: 
  'E:\Spandan\PSC Desktop Backup\Codes\Statistics_Matrices\'
- Uses `removal_control` to preprocess each dataset before visualization
%}

    base_path = 'E:\\Spandan\\PSC Desktop Backup\\Codes\\Statistics_Matrices\\';
    data_struct = struct();

    % Load and clean data
    for m = 1:length(metric_list)
        metric = metric_list{m};
        for p = 1:length(phases)
            phase = phases{p};
            fname = sprintf('%s%s_%s.mat', base_path, ['n_' upper(metric)], phase);
            tmp = load(fname);
            data_field = getfield(tmp, phase);
            data_struct.(sprintf('%s_%s', metric, phase)) = removal_control(data_field, variable);
        end
    end

    % Visualization
    figure;
    for set_id = 1:length(selected_metrics)
        subplot(1, length(selected_metrics), set_id);
        current_set = selected_metrics{set_id};
        allData = [];
        labels = {};
        for i = 1:length(current_set)
            parts = strsplit(current_set{i}, '_');
            allData = [allData, data_struct.(current_set{i})(:)];
            labels{end+1} = [upper(parts{1}) '-' upper(parts{2})];
        end

        % Boxplot
        h = boxplot(allData, 'Whisker', 1.5, 'Widths', 0.3, ...
                    'BoxStyle', 'outline', 'Color', 'k');
        hold on;
        set(h, 'linewidth', 1.5);        
        ylim([0 30]);
        ylabel('Waves/ Min.', 'fontsize', 20, 'FontWeight', 'bold');
        spread = 0.2; xCenter = 1:size(allData, 2);

        clear x y
        for i = 1:size(allData, 2)
            h = scatter(rand(size(allData(:, i))) * spread - (spread / 2) + xCenter(i), ...
                        allData(:, i), 50, cmap(i,:), 'filled', ...
                        shapes(i), 'MarkerEdgeColor', 'k', ...
                        'MarkerFaceAlpha', .7, 'MarkerEdgeAlpha', 0.5, ...
                        'linewidth', 0.5);
            x(:, i) = get(h, 'Xdata');
            y(:, i) = get(h, 'Ydata');
        end

        lw = 1;
        for i = 1:size(allData, 1)
            if mod(size(allData, 2), 2) == 0
                for j = 1:2:size(allData, 2)
                    line([x(i, j), x(i, j+1)], [y(i, j), y(i, j+1)], ...
                         'Color', [0.4660 0.6740 0.1880 0.5], ...
                         'LineWidth', lw, 'LineStyle', '--');
                end
            end
        end
        set(gca, 'XTickLabel', labels, 'fontsize', 16, 'FontWeight', 'bold');
        title(sprintf('Comparison %d', set_id), 'FontWeight', 'bold');
    end
end



% % Example Usages
% phases = {'p1', 'p2', 'p3'};
% metric_list = {'ap', 'pa', 'sw', 'tot'};
% variable = 'N7';
% cmap = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560];
% shapes = ['o';'p';'d';'s'];
% 
% selected_metrics = {
%     {'ap_p1', 'ap_p2', 'ap_p3'},
%     {'tot_p2', 'tot_p3'},
% };
% 
% visualize_wave_data(phases, metric_list, variable, cmap, shapes, selected_metrics);
