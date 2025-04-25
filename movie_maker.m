%{
BATCH_GUT_FLOW_VISUALIZATION
-----------------------------
This script processes a sequence of gut motility image frames and corresponding optical flow
data to create and save directionally color-coded quiver overlays for each frame.

Each arrow visualizes motion direction and magnitude, colored by angle using the twilight colormap.

INPUT:
- TIFF images:    'Exp_26_cropped_short\' (one .tif file per frame)
- Optical flow:   'Exp_26_of_short\'       (matching .mat files with `vx`, `vy`)

PARAMETERS:
- Threshold for velocity magnitude: 0.2
- Smoothing window: 50 (applied using `movmean`)
- Quiver subsampling: [40, 20] (via `quiver_skip`)
- Background mask threshold: median + 10
- Largest region used for mask (via `bwareaopen`)

OUTPUT:
- TIFF plots with overlayed colored vectors, saved to:
  'E:\Spandan\PSC Desktop Backup\Codes\Final Codes\Frames_v2\plot#.tif'

DEPENDENCIES:
- `sort_nat` for filename ordering
- `quiver_skip` for decimating vector field
- `twilight` for angular colormap

%}

clear all;

data_folder = 'E:\Spandan\PSC Desktop Backup\';

% Get image and flow file lists
img_folder = fullfile(data_folder, 'Exp_26_cropped_short');
flow_folder = fullfile(data_folder, 'Exp_26_of_short');
save_folder = fullfile(data_folder, 'Codes\Final Codes\Frames_v2');

img_files = dir(fullfile(img_folder, '*.tif'));
flow_files = dir(fullfile(flow_folder, '*.mat'));

img_names = sort_nat({img_files.name});
flow_names = sort_nat({flow_files.name});

% Colormap
cmap = twilight(360);

parfor k = 1:length(img_names)
    % Load image
    I = imread(fullfile(img_folder, img_names{k}));
    yo = I > median(I, 'all') + 10;
    ya = conv2(yo, ones(1), 'same');
    filt_im = bwlabeln(bwareaopen(ya, 1000));
    props = regionprops(filt_im);
    ind_largest = find(max([props.Area]));
    mask = (filt_im == ind_largest);

    % Load flow
    flow = load(fullfile(flow_folder, flow_names{k}));
    vx = movmean(flow.vx, 50);
    vy = movmean(flow.vy, 50);
    vx = vx .* mask;
    vy = vy .* mask;

    % Quiver downsampling
    [vxnew, vynew] = quiver_skip(vx, vy, 40, 20);
    vel = sqrt(vxnew.^2 + vynew.^2);

    % Threshold by speed
    valid = vel > 0.2;
    vxt = vxnew(valid); vyt = vynew(valid);

    % Coordinates
    [X, Y] = meshgrid(1:size(vx,2), 1:size(vx,1));
    X = X(valid); Y = Y(valid);

    % Compute angle and color index
    ang = atan2(vyt, vxt) * (180 / pi);
    color_idx = mod(round(ang + 180), 360) + 1;

    % Show and overlay vectors
    I_disp = I / 2.5;
    figure('Visible', 'off'); imshow(I_disp); hold on;

    for i = 1:length(vxt)
        quiver(X(i), Y(i), vxt(i), vyt(i), 30, ...
            'LineWidth', 2.0, ...
            'Color', cmap(color_idx(i), :), ...
            'MaxHeadSize', 1.0, ...
            'AlignVertexCenters', 1);
    end

    set(gca, 'Clipping', 'off');
    saveas(gcf, fullfile(save_folder, ['plot', num2str(k), '.tif']), 'tiffn');
    close;
end