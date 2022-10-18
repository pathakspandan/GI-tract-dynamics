% Extracting frequency space characteristics from a motility map

% INPUT 
% vy: Motility map of mean vy(dorsal-ventral)-motion as a function of time
% Fs: Sampling Rate (in frames per second)   
% f_span : Frequency span around the peak for calculating the area (along
% one-direction)

% OUTPUT
% per_power: Relative Rhythmic Power contribution from the peak
% fre: Peak Frequency from the given motility map
% norm_peak: Normalized value of the peak power w.r.t total power
% prom: Prominence value of the power spectrum peak
% Width: Width of the power spectrum peak
% ptot: Total power embedded within the power spectrum

function [per_power,fre,norm_peak,prom,width,ptot] = regularity(vy,Fs,f_span)      
   
    % Power spectral density (PSD) of y-motion
    [pow,f] = periodogram(transpose(vy),[],[],Fs); p_mean = mean(pow,2);     
    
     
    % Calculation of total power from the PSD
    ptot = bandpower(p_mean,f,[0 Fs/2],'psd');  

    [pks,locs,w,p]=findpeaks(p_mean,f);    % Find all peak locations of PSD
  
    [peak_val,id] = max(pks); 
    fre = locs(id);                % Find global peak and corresponding frequency  
  
    % Calculation of power contribution from the peak
    pband = bandpower(p_mean,f,[fre - f_span  fre + f_span],'psd');
    per_power = 100*(pband/ptot);       
    
    prom = p(id); width = w(id);
    norm_peak = peak_val/ptot;

end


