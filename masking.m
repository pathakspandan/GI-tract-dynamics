function y = masking(I)
% MASKING Creates a mask from an input image based on adaptive thresholding and size filtering.
%
% This function performs the following steps:
%   1. Thresholds the image at a value 5 units above its median intensity.
%   2. Applies a smoothing filter via 2D convolution.
%   3. Removes small connected components (<1000 pixels).
%   4. Identifies and retains only the largest connected region.
%   5. Converts the binary mask into a NaN-masked format, where background is NaN.
%
% INPUT:
%   I : 2D numeric array
%       The input image matrix (grayscale intensity or filtered image).
%
% OUTPUT:
%   y : 2D numeric array
%       A NaN-masked image where:
%           - Foreground pixels of the largest region = 1
%           - Background pixels = NaN
%
% USAGE EXAMPLE:
%   im = imread('example.tif');
%   mask = masking(im);
%   imagesc(mask); colormap gray;  % Visualize masked region
%
% NOTES:
% - The function assumes that the object of interest has intensities significantly
%   higher than the median background plus a threshold offset of 5.
% - `bwareaopen` filters out small regions before selecting the largest blob.

    yo = I > median(I, 'all') + 5;
    windowSize = 1; 
    kernel = ones(windowSize) / windowSize ^ 2;

    ya = conv2(yo, kernel, 'same');
    filt_im = bwlabeln(bwareaopen(ya, 1000));
    props = regionprops(filt_im);
    ind = find(max([props.Area]));

    mask_nan = double(filt_im == ind);
    mask_nan(mask_nan == 0) = nan;
    y = mask_nan;
end