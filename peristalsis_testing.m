%{
LATERAL_WAVE_ANALYSIS
----------------------
This script processes a motility kymograph of the gut (y-velocity over time),
extracts wave-like regions based on speed and spatial filtering, computes
lateral wave directionality, counts AP/PA/mixed waves, and detects directional switches.

INPUTS:
- Motility file (.mat) containing vy2avg (2D array): 
    'E:\Spandan\TTX\TTX_Experiments_05_22\TTX_052223_p1.mat'
- Speed threshold (.mat) from precomputed 70th percentile threshold:
    'spd_thrld_70ptile.mat'

PARAMETERS:
- re_len        : Real gut length in mm (default: 19.79)
- f_span        : Frequency span for area calculation (default: 0.04)
- Fs            : Sampling rate in Hz (default: 3)
- area_thres    : Minimum wave size in pixels (default: 100)
- span_thres    : Minimum wave length threshold (default: 0.2 × gut length)

OUTPUTS (per minute of movie):
- n_switch : Number of direction switches in wave direction
- n_AP     : Number of anterior-to-posterior (AP) waves
- n_PA     : Number of posterior-to-anterior (PA) waves
- n_mix    : Number of mixed (fluctuating) waves
- nwav     : Total number of spatially extended waves
%}

clear all;

%% Load and preprocess motility map
mat1 = load('E:\Spandan\TTX\TTX_Experiments_05_22\TTX_052223_p1.mat'); 
v1 = mat1.vy2avg; clear mat1;
v1(isnan(v1)) = 0; 
v1 = mean_subtract(double(v1)); 

% Metadata and conversion parameters
re_len = 19.79; f_span = 0.04; Fs = 3; area_thres = 100;
len_gut = size(v1,1);

% Convert from px/frame to mm/s
v1 = v1 * (re_len * Fs / len_gut);
v1 = mean_subtract(v1);
v1_smo = imgaussfilt(v1, 2);  % Gaussian smoothing

%% Apply thresholding using precomputed speed cutoff
fle = load('E:\Spandan\PSC Desktop Backup\Codes\spd_thrld_70ptile.mat');    
speed_thresh = median(fle.thr) * (re_len * Fs / len_gut); 
clear fle;

logc = abs(v1_smo) > speed_thresh;
filt_im = bwlabeln(bwareaopen(logc, area_thres));
box = regionprops(filt_im, 'Area', 'BoundingBox'); 
n_wv = length(box);

% Identify connected components and sort them temporally
CC = bwconncomp(logc); 
stat = regionprops(CC, 'Image');
numPixels = cellfun(@numel, CC.PixelIdxList);  
[~, idx] = maxk(numPixels, n_wv);    
idx = sort(idx);

%% Analyze each wave region to determine direction and extent
spat_span = zeros(size(box)); 
pos = zeros(size(box)); 
dir = zeros(size(box));

for i = 1:n_wv
    yo = stat(idx(i)).Image;  % Isolated wave region
    [pf, spatial_span, ~, ~] = wave_skeleton(yo, re_len, len_gut, Fs);
    spat_span(i) = spatial_span; 
    stats = box(i).BoundingBox;
    pos(i) = stats(1) / (60 * Fs); 
    dir(i) = pf;
end

%% Filter out waves shorter than 20% of gut length
span_thres = 0.2;
len_id = find(spat_span > span_thres * re_len);
n_wv = length(len_id); 
new_dir = dir(len_id);

n_ap = sum(new_dir > 0); 
n_pa = sum(new_dir < 0); 
n_mx = n_wv - n_ap - n_pa;

%% Count directional switches using zero-crossings
if ~isempty(len_id)
    zcd = dsp.ZeroCrossingDetector;
    n_sw = double(zcd(new_dir));
    release(zcd);  
else
    n_sw = 0;
end

%% Normalize all metrics to per-minute values
len = size(v1_smo, 2) / (Fs * 60);  % movie length in minutes

n_switch = n_sw / len; 
n_AP = n_ap / len; 
n_PA = n_pa / len;
n_mix = n_mx / len; 
nwav = n_wv / len;