% Extracting spatial-domain i.e. wave characteristics from a motility map

% INPUT 
% vy2avg: Motility map of mean vy(dorsal-ventral)-motion as a function of time
% Fs: Sampling Rate (in frames per second)  
% re_len: Spatial span of the anterior-posterior(AP) gut axis in mm.
% n: The specific phase of treatment for chosing time-windows
% n_phase: Number of distinct phases corresponding that experiment
% area_thres: Minimum size threshold (in pixels) for identifying a wave-region
% save_name: Name under which the resultant data-file would be stored

% OUTPUT
% Data file storing the following motility metrics for individual treatment windows
% n_switch: Number of directional switching of lateral waves
% n_AP: Number of AP (anterior-posterior) waves
% n_PA: Number of PA waves
% n_mix: Number of mixed waves
% nwav: Total number of lateral waves (AP+PA+mixed)
% len: Duration of the treatment window in minutes


function perist_new(vy2avg,Fs,re_len,n,n_phase,area_thres,save_name)       
    
    len_gut = size(vy2avg,1);   % length of the gut (in pixels)
    vy2avg(isnan(vy2avg))=0;   % setting NaN values to zero   
    Len = size(vy2avg,2);     % Length of the signal i.e. # of frames in each phase    
    vy2avg = vy2avg*(re_len*Fs/len_gut);     % changing velocities from px/f to mm/s
    
    bar = floor(Len/n_phase);
    vy = vy2avg(:,(n-1)*bar+1:bar*n);
    clear vy2avg;

    % Mean subtraction from each row of the motility map(i.e. gut location)
    vy = mean_subtract(vy);
    vy_smo = imgaussfilt(vy,2);                 % Gaussian smoothing of motility map    
    n_part = 2; len_part = floor(size(vy,2)/n_part);  

    % Using the top 30-percentile speed thresholding for choosing the high speed
    % regions within the motility map

    % The file has to be downloaded and the local address has to be changed accordingly 
    fle = load('E:\\Spandan\\Codes\\spd_thrld_70ptile.mat');    
    speed_thresh = median(fle.thr);
    speed_thresh = speed_thresh*(re_len*Fs/len_gut); % changing the speed threshold value from px/f to mm/s
    clear fle;

    % Storing motility metrics for 2 consecutive 15min. windows
    n_switch = zeros(1,2);
    n_AP = zeros(1,2);
    n_PA = zeros(1,2);
    n_mix = zeros(1,2);
    nwav = zeros(1,2);
    len = zeros(1,2);
    

    for j = 1:2
        if j == 1
            v_part = vy_smo(:,1:len_part);
        elseif j == 2
            v_part = vy_smo(:,len_part+1:end);  
        end 
        
        logc = abs(v_part)>speed_thresh;        % Applying speed threshold to DV motility map
        filt_im = bwlabeln(bwareaopen(logc,area_thres));   % Applying area threshold to the speed-thresholded region
        box = regionprops(filt_im, 'Area', 'BoundingBox'); 
        spat_span = zeros(size(box));       % Array for storing spatial span of lateral waves 
        pos = zeros(size(box));             % Array for storing lateral wave location in time
        n_wv = length(box);                 % Total number of lateral waves
        dir = zeros(size(box));             % Array for storing lateral wave movement direction        
    
        CC = bwconncomp(logc); stat = regionprops(CC,'Image');
        numPixels = cellfun(@numel,CC.PixelIdxList);  
        [~,idx] = maxk(numPixels,n_wv);    % Regions with area above the given threshold (sorted by area-size)
        idx = sort(idx);                   % sorting waves temporally (from earliest to latest)
    
        for i = 1:n_wv
            yo = stat(idx(i)).Image;   % selecting individual wave regions
            [pf, spatial_span, ~, ~] = wave_skeleton(yo,re_len,len_gut,Fs);   % Finding direction and spatial extent of the lateral wave     
            spat_span(i) = spatial_span; 
            stats = box(i).BoundingBox;
            pos(i) = stats(1)/(60*Fs); dir(i) = pf;
        end
         
        len_id = find(spat_span>re_len/5);    % Only select the waves traveling more than 1/5th of the total gut length

        n_wv = length(len_id); 
        new_dir = dir(len_id);
    
        n_ap = length(new_dir(new_dir>0));         % number of AP waves satisfying the spatial extent criteria   
        n_pa = length(new_dir(new_dir<0));        % number of PA waves satisfying the spatial extent criteria   
        n_mx = n_wv - n_ap - n_pa;       % number of mixed waves satisfying the spatial extent criteria         
        
        % Calculating the number of directional switching of the lateral waves
        if (isempty(len_id) == 0)
            zcd = dsp.ZeroCrossingDetector;
            n_sw = zcd(new_dir);
            release(zcd);  
        else
            n_sw = 0;
        end

        len(j) = size(v_part,2)/(Fs*60);
        n_switch(j) = n_sw; n_AP(j) = n_ap; n_PA(j) = n_pa;
        n_mix(j) = n_mx; nwav(j) = n_wv;
        
    end
    save(save_name,'n_switch','n_AP','n_PA','n_mix','nwav','len');
end

