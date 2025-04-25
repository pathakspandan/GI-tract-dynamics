%{
This script computes frequency-based motility metrics across multiple
experimental movies from different treatment windows and saves the results
for each window.

FUNCTION:
- Loads all `.mat` motility files in a selected folder (recursively)
- Parses experiment ID from filename (e.g., "expt14_p2.mat" → "14")
- Determines number of treatment windows (1, 2, or 3) based on ID
- Retrieves corresponding real gut length (`re_len`) from a lookup table
- Applies `regularity_latest()` to extract frequency metrics
- Saves output as "reg_exp<ID>_p<phase>.mat"

INPUT:
- Folder containing motility .mat files (selected via prompt)

OUTPUT:
- .mat file per treatment window, storing:
    - per_power, fre, norm_peak, prom, width, ptot

NOTES:
- Fs = 3 Hz (sampling frequency)
- f_span = 0.04 Hz (frequency window around the spectral peak)
%}

clear;

% Select root directory
path = uigetdir('E:\Spandan\New_Analysis\kymo_files');
files = dir(fullfile(path, '**', '*.mat'));
names = {files.name};

% Lookup: experiment ID → gut length (re_len)
re_len_map = containers.Map( ...
    {'6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','32','33','34','35','36','37','38','39','40'}, ...
    [24.12,24.12,23.51,23.51,24.11,22.45,22.45,22.52,24.81,24.81,24.20,24.23,24.50,24.52,...
     23.66,26.22,24.51,24.51,24.51,24.16,24.15,24.15,20.44,20.84,22.30,21.06,24.84,24.06,...
     24.92,19.66,17.78,25.14,24.36,22.35]);

% Experiments by number of phases
three_phase_ids = {'9','10','19','21','28','36'};
two_phase_ids = {'14','15','20','22','29','37'};

% Loop through all files
for i = 1:length(names)
    name = names{i};
    
    % Extract experiment ID
    exp_id = regexp(name, 'expt(\d+)', 'tokens', 'once');
    if isempty(exp_id)
        warning("Filename does not match expected format: %s", name);
        continue;
    end
    exp_id = exp_id{1};

    % Determine number of phases
    if ismember(exp_id, three_phase_ids)
        j = 1:3;
    elseif ismember(exp_id, two_phase_ids)
        j = 1:2;
    else
        j = 1;
    end
    n_ph = length(j);

    % Get real gut length
    if ~isKey(re_len_map, exp_id)
        warning("Unknown experiment ID: %s. Skipping.", exp_id);
        continue;
    end
    re_len = re_len_map(exp_id);

    % Loop through phases for current experiment
    for k = j
        % Construct save name
        phase_str = extractBetween(name, 'p', '.mat');
        save_name = "reg_exp" + exp_id + "_p" + phase_str + k;

        % Load motility file
        filepath = fullfile(path, name);
        v = load(filepath);
        vy = v.vy2avg; clear v;

        % Compute frequency-based motility metrics
        [per_power, fre, norm_peak, prom, width, ptot] = regularity_latest(vy, 3, re_len, k, n_ph, 0.04);

        % Save results
        save(save_name, 'per_power', 'fre', 'norm_peak', 'prom', 'width', 'ptot');
    end
end