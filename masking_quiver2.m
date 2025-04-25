%{
GUT_FLOW_VECTOR_OVERLAY
------------------------
This script overlays quiver arrows (velocity vectors) on a gut motility image,
where arrow colors encode direction (angle), using the twilight colormap.
It also displays a reference pie chart for angular color interpretation.

INPUTS:
- One image frame (.tif) from Exp_26 gut motility dataset
- One optical flow file (.mat) with variables `vx` and `vy` from the same frame

PARAMETERS:
- start_loc, end_loc : numerical suffix to define file naming and region (used for offset naming)
- quiver_skip        : [40, 20] downsampling for vector field
- smoothing          : movmean window of 50 frames
- velocity threshold : 0.2 (minimum magnitude to plot)
- color mapping      : based on angle in degrees [-180, 180]

OUTPUTS:
- Interactive overlay plot (can be saved manually)
- Angular colorwheel showing hue-to-angle mapping

DEPENDENCIES:
- `masking` function (threshold-based segmentation)
- `quiver_skip` function (vector field decimation)
- `twilight` colormap (360 RGB entries)
%}

clear;

% Define frame index and file paths
end_loc = 8310;
start_loc = 7680;
re_loc = (end_loc - start_loc) / 10;

% Load mask and optical flow data
mask = masking(['E:\Spandan\PSC Desktop Backup\New_Analysis\Experiments\Exp_26\Cropped_short\im00' num2str(re_loc) '.tif']);
flow = load(['E:\Spandan\PSC Desktop Backup\New_Analysis\Experiments\Exp_26\Op_flow1\' num2str(end_loc) '.mat']);
vx = movmean(flow.vx, 50);
vy = movmean(flow.vy, 50);

% Apply mask to flow
vx_masked = vx .* mask;
vy_masked = vy .* mask;

% Downsample vector field
[vxnew, vynew] = quiver_skip(vx_masked, vy_masked, 40, 20);
vel = sqrt(vxnew.^2 + vynew.^2);

% Filter low-magnitude vectors
thres = 0.2;
valid = vel > thres;
vxt = vxnew(valid);
vyt = vynew(valid);

% Compute angles and assign color
[x_span, y_span] = deal(size(vx, 2), size(vx, 1));
[X, Y] = meshgrid(1:x_span, 1:y_span);
X = X(valid);
Y = Y(valid);
ang = atan2(vyt, vxt) * (180 / pi);
cmap = twilight(360);
[~, ~, ind] = histcounts(ang, size(cmap, 1));

% Load and normalize background image
I1 = imread(['E:\Spandan\PSC Desktop Backup\New_Analysis\Experiments\Exp_26\Cropped_short\im00' num2str(re_loc) '.tif']);
I1 = I1 / 2.5;

% Plot image and overlay quiver arrows
figure;
imshow(I1); hold on;
for i = 1:length(vxt)
    quiver(X(i), Y(i), vxt(i), vyt(i), 35, ...
        'LineWidth', 0.5, ...
        'Color', cmap(ind(i), :), ...
        'MaxHeadSize', 1.0, ...
        'AlignVertexCenters', 1);
end
set(gca, 'Clipping', 'off');
title('Flow Direction Overlay', 'FontWeight', 'bold');

%% Optional: Angular Colorwheel
x = ones(1, 180);
h = pie(x); colormap(gca, cmap);
for hc = 1:2:length(h) % pie segments
    set(h(hc), 'EdgeColor', 'none');
end
for hc = 2:2:length(h) % pie text labels
    if mod(hc, 30) ~= 0
        delete(h(hc));
    else
        set(h(hc), 'String', num2str(hc));
    end
end
title('Angular Color Mapping (360°)', 'FontWeight', 'bold');