% Extracting wave parameters from individual lateral waves

% INPUT 
% logical_matrix: Binary matrix from the motility map corresponding to the lateral wave region
% re_len: Spatial span of the anterior-posterior(AP) gut axis in mm.
% len_gut: Spatial span of the anterior-posterior(AP) gut axis in pixels.
% Fs: Sampling Rate (in frames per second)  

% OUTPUT
% pf: Peristaltic Factor (-ve value indicates Posterior to Anterior movement and +ve value indicates Anterior to Posterior movement)
% spatial_span: Spatial extent of a lateral wave (in mm.)
% time_span: Temporal extent of a lateral wave (in s.)
% speed: Speed of a lateral wave (in mm./s)

function [pf, spatial_span, time_span, speed] = wave_skeleton(logical_matrix,re_len,len_gut,Fs)    
    
    skel = bwskel(logical_matrix);    % Find the 1-D skeleton of the wave region
    [row, column] = find(skel == 1);
    row = row*(re_len/len_gut); column = column/Fs;
    x = column;
    y = row;
    
    % Calculating wave parameters (speed, spatial span, time span etc.)
    spatial_span = max(y) - min(y);
    time_span = max(x) - min(x);   
    speed = spatial_span/time_span; 
    [~,I1] = max(y); [~,I2] = min(y);
    pf = x(I1) - x(I2);    
end

