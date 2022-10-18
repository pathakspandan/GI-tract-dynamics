% Extracting frequency space characteristics for a chosen time-window from the motility map

% INPUT 
% vy2avg: Motility map of mean vy(dorsal-ventral)-motion as a function of time
% Fs: Sampling Rate (in frames per second)  
% re_len: Spatial span of the anterior-posterior(AP) gut axis in mm.
% n: The specific phase of treatment for chosing time-windows
% n_phase: Number of distinct phases corresponding that experiment
% f_span : Frequency span around the peak for calculating the area (along
% one-direction) 

% OUTPUT
% per_power: Relative Rhythmic Power contribution from the peak
% fre: Peak Frequency from the given motility map
% norm_peak: Normalized value of the peak power w.r.t total power
% prom: Prominence value of the power spectrum peak
% Width: Width of the power spectrum peak
% ptot: Total power embedded within the power spectrum

function [per_power,fre,norm_peak,prom,width,ptot] = regularity_latest(vy2avg,Fs,re_len,n,n_phase,f_span)  
    
    len_gut = size(vy2avg,1);           % length of the gut (in pixels)
    vy2avg(isnan(vy2avg))=0;            % setting NaN values to zero   
    Len = size(vy2avg,2);               % length of the signal i.e. # of frames in each phase    
    vy2avg = vy2avg*(re_len*Fs/len_gut);     % changing velocities from px/f to mm/s
    
    bar = floor(Len/n_phase);
    vy = vy2avg(:,(n-1)*bar+1:bar*n);
    clear vy2avg;

    % Mean subtraction from each row of the motility map(i.e. gut location)
    vy = mean_subtract(vy);    
    
    n_part = 2;         
    len_part = floor(size(vy,2)/n_part);

    % Storing motility metrics for 2 consecutive 15min. windows
    per_power = zeros(1,2);
    fre = zeros(1,2);
    norm_peak = zeros(1,2);
    prom = zeros(1,2);
    width = zeros(1,2);
    ptot = zeros(1,2);
    
    for i = 1:n_part
        if i == 1
            v_part = vy(:,1:len_part);
        elseif i == 2
            v_part = vy(:,len_part+1:end);  
        end
        [pp,fr,np,prm,wdt,ptt] = regularity(v_part,Fs,f_span); 
        per_power(i) = pp; fre(i) = fr; norm_peak(i) = np;
        prom(i) = prm; width(i) = wdt; ptot(i) = ptt;          
    end
end

