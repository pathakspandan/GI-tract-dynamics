%{
This script calculates lateral wave metrics for all motility movies
stored in a specified folder. It is used to analyze phase-wise gut motility
using dorsoventral velocity kymographs.

FUNCTION:
- Loops over all `.mat` files in a selected folder (recursively)
- Determines experiment ID from filename (e.g., "expt14_p2.mat" → "14")
- Infers number of experimental phases (1, 2, or 3) based on experiment ID
- Selects the appropriate real gut length (in mm) for each experiment
- Loads and processes velocity maps (vy2avg)
- Flips y-axis if needed (older datasets)
- Computes lateral wave metrics using `perist_new` and saves result

INPUT:
- Folder path with motility .mat files (prompted interactively)

OUTPUT:
- Saves metrics per treatment window with naming convention:
    "sv_exp<experiment_id>_p<phase_index><replicate>.mat"
- Computation uses: Fs = 3 Hz, Area Threshold = 100 pixels

USAGE:
- Run this script and select the folder containing .mat files when prompted
- Example file: "expt14_p2.mat" → experiment ID = 14, phase = 2
%}

clear;

% Select directory containing motility .mat files
path = uigetdir('E:\Spandan\New_Analysis\kymo_files');
files = dir(fullfile(path, '**', '*.mat'));
names = {files.name};

% Lookup table: experiment ID → gut length (mm)
re_len_map = containers.Map( ...
    {'6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','32','33','34','35','36','37','38','39','40'}, ...
    [24.12,24.12,23.51,23.51,24.11,22.45,22.45,22.52,24.81,24.81,24.20,24.23,24.50,24.52,...
     23.66,26.22,24.51,24.51,24.51,24.16,24.15,24.15,20.44,20.84,22.30,21.06,24.84,24.06,...
     24.92,19.66,17.78,25.14,24.36,22.35]);

% Define sets of experiments by number of treatment windows
three_phase_ids = {'9','10','19','21','28','36'};
two_phase_ids = {'14','15','20','22','29','37'};

% Loop through all .mat files
for i = 1:length(names)
    name = names{i};
    
    % Extract experiment ID from filename
    exp_id = regexp(name, 'expt(\d+)', 'tokens', 'once');
    if isempty(exp_id), warning('Invalid filename format: %s', name); continue; end
    exp_id = exp_id{1};

    % Determine number of treatment windows
    if ismember(exp_id, three_phase_ids)
        j = 1:3;
    elseif ismember(exp_id, two_phase_ids)
        j = 1:2;
    else
        j = 1;
    end

    % Determine real gut length from lookup table
    if isKey(re_len_map, exp_id)
        re_len = re_len_map(exp_id);
    else
        warning(['Unknown experiment ID: ' exp_id ', skipping.']);
        continue;
    end

    for k = j
        % Construct save name: e.g., "sv_exp14_p2.mat"
        phase_str = extractBetween(name, 'p', '.mat');
        save_name = "sv_exp" + exp_id + "_p" + phase_str + k;

        % Load motility map
        filepath = fullfile(path, name);
        v = load(filepath);
        vy2avg = v.vy2avg;
        clear v;

        % Flip y-axis for legacy experiments imaged from opposite side
        if any(strcmp(exp_id, {'6','7','8','9'}))
            vy2avg = flip(vy2avg, 1);
        end

        % Run wave metric computation
        perist_new(vy2avg, 3, re_len, k, length(j), 100, save_name);
    end
end