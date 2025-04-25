
%{
WIDTH_KYMOGRAPH_FROM_IMAGE_STACK
--------------------------------
This script loads a full motility movie (TIFF stack), extracts width over time by
applying segmentation on each frame, rescales the results into real-world units (mm),
and visualizes the smoothed gut width as a kymograph.

INPUTS:
- TIFF stack: full gut motility movie (e.g., 'Exp_26_cropped_short.tif')
  Each frame is assumed to be a 2D grayscale image of gut tissue

PARAMETERS:
- L        : real gut length in mm (used for scaling y-axis)
- Fs       : sampling rate in Hz (used for x-axis in seconds)
- span     : number of frames to keep in the smoothed kymograph
- smoothing: Gaussian filter with sigma = [0.25, 1]

OUTPUTS:
- Width kymograph plot (gut position vs. time, color-coded by width in mm)
- Optionally: smoothed `wid_smo` matrix, `x_ax`, `y_ax` for export

DEPENDENCIES:
- `masking` function to extract gut boundaries
- `bfopen` (Bio-Formats) to read multi-page TIFFs

NOTES:
- Width is computed by summing each mask column (ignoring NaNs)
- Spatial scaling converts pixels to mm based on known gut length
- Only the first 90 time frames are plotted for visualization
%}



clear all;

%% Load TIFF stack using Bio-Formats
filepath = 'E:\Spandan\PSC Desktop Backup1\Exp_26_cropped_short.tif'; 
img_data = bfopen(filepath);
temp = img_data{1,1}(:,1);  % Only image content

% Stack into 3D array
numIm = length(temp);
for i = 1:numIm
    im_all(:,:,i) = temp{i};
end

%% Apply masking and compute width per frame
for i = 1:size(im_all, 3)
    mask = masking(im_all(:,:,i));
    wid(:,i) = sum(mask, 1, "omitnan");  % Gut width = number of pixels in mask column
end

%% Rescale width to mm
L = 24.15; Fs = 3; span = 90;
len_gut = size(wid,1);
wid_scaled = wid * (L / len_gut);  % Convert pixel length to mm
wid_smo = imgaussfilt(wid_scaled, [0.25, 1]);  % Smooth width matrix
wid_smo = wid_smo(:, 1:(1+span));  % Crop to first 90 timepoints

%% Plot kymograph
T = size(wid_smo, 2);
x_ax = (0:T-1) * (1 / Fs); 
y_ax = linspace(0, len_gut, len_gut) * (L / len_gut);

figure(1); hold on;
h2 = imagesc(wid_smo);  % Default X and YData updated below
set(h2, 'XData', x_ax, 'YData', y_ax);

colormap(summer); 
colorbar();
set(gca, 'XTick', 0:6:30, 'XTickLabel', 0:6:30);
set(gca, 'YTick', 4:4:y_ax(end), 'YTickLabel', 4:4:y_ax(end));
set(gca, 'FontSize', 20, 'FontWeight', 'bold');
xlabel('Time (s)', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('Gut Position (mm)', 'FontSize', 20, 'FontWeight', 'bold');
title('Local Gut Width (mm)', 'FontSize', 20, 'FontWeight', 'bold');
axis tight;


