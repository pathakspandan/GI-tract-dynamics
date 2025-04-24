function [per_power, fre, norm_peak, prom, width, ptot] = windowing(save_flag, save_name_regul, vy, n_parts, Fs, re_len, f_span)  
%WINDOWING Analyzes gut motility signals by computing peristaltic metrics over time windows.
%
% This function divides the input velocity signal `vy` into `n_parts` 
% non-overlapping time windows and computes several motility features 
% for each window using a frequency-domain analysis. It optionally saves 
% a subset of the results to a .mat file.
%
% Inputs:
%   save_flag       - String, set to '1' to save results, otherwise do not save
%   save_name_regul - String, name of the file to save results if save_flag is '1'
%   vy              - 2D matrix of velocities (pixels/frame), size: [length, time]
%   n_parts         - Number of time windows to divide the data into
%   Fs              - Sampling frequency in Hz (frames per second)
%   re_len          - Real length of gut in mm
%   f_span          - Frequency range to analyze (e.g., [0.01 0.3] Hz)
%
% Outputs:
%   per_power   - Peristaltic power in each time window
%   fre         - Dominant frequency in each time window
%   norm_peak   - Normalized spectral peak in each time window
%   prom        - Peak prominence in the power spectrum
%   width       - Width of the spectral peak
%   ptot        - Total power in the spectrum over the frequency range

    len_part = floor(size(vy,2)/n_parts);
    len_gut = size(vy,1);  % Length of the gut in pixels
    
    vy = vy * (re_len * Fs / len_gut);  % Convert from px/frame to mm/s

    % Initialize outputs
    per_power = zeros(1, n_parts);
    fre       = zeros(1, n_parts);
    norm_peak = zeros(1, n_parts);
    prom      = zeros(1, n_parts);
    width     = zeros(1, n_parts);
    ptot      = zeros(1, n_parts);

    % Compute motility metrics for each time window
    for i = 1:n_parts
        v_part = vy(:, (i-1)*len_part+1:i*len_part);
        [pp, fr, np, prm, wdt, ptt] = regularity(v_part, Fs, f_span); 
        per_power(i) = pp; fre(i) = fr; norm_peak(i) = np;
        prom(i) = prm; width(i) = wdt; ptot(i) = ptt;
    end

    % Optionally save selected metrics
    if strcmpi(save_flag, '1') == 1    
        save(save_name_regul, 'per_power', 'fre', 'ptot');
    end
end