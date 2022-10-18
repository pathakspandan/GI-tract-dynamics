% Calculating motility metrics (in frequency space) across all movies and
% different treatments

% INPUT 
% Just use the right file address storing all the motility files upon
% prompt

% OUTPUT
% Data file storing motility metrics for individual treatment windows

clear all;
% This address has to be changed accorrdingly
path = uigetdir('E:\\Spandan\\New_Analysis\\kymo_files'); 
files = dir(fullfile(path,'**','*.mat'));
files = struct2cell(files);
names = files(1,:);

for i = 1:length(names)
    name = char(names(i));
    if string(name(5)) == '9'
        j = 1:3;
    elseif string(name(5)) == '1' && string(name(6)) == '0'
        j = 1:3;
    elseif string(name(5)) == '1' && string(name(6)) == '9'
        j = 1:3;
    elseif string(name(5)) == '2' && string(name(6)) == '1'
        j = 1:3;
    elseif string(name(5)) == '2' && string(name(6)) == '8'
        j = 1:3;
    elseif string(name(5)) == '3' && string(name(6)) == '6'
        j = 1:3;
        
    elseif string(name(5)) == '1' && string(name(6)) == '4' && string(name(end-4)) == '2'
        j = 1:2;
    elseif string(name(5)) == '1' && string(name(6)) == '5' && string(name(end-4)) == '2'
        j = 1:2;
    elseif string(name(5)) == '2' && string(name(6)) == '0' && string(name(end-4)) == '2'
        j = 1:2;
    elseif string(name(5)) == '2' && string(name(6)) == '2' && string(name(end-4)) == '2'
        j = 1:2;
    elseif string(name(5)) == '2' && string(name(6)) == '9' && string(name(end-4)) == '2'
        j = 1:2;
    elseif string(name(5)) == '3' && string(name(6)) == '7' && string(name(end-4)) == '2'
        j = 1:2;
        
        
    else
        j = 1;
    end   
    n_ph = length(j);
    
    for k = j(1):j(end)
        if name(5) == '6'
            re_len = 24.12;
            save_name = 'reg_exp'+string(name(5))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '7'
            re_len = 24.12;
            save_name = 'reg_exp'+string(name(5))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '8'
            re_len = 23.51;
            save_name = 'reg_exp'+string(name(5))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '9'
            re_len = 23.51;
            save_name = 'reg_exp'+string(name(5))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '1' && name(6) == '0'
            re_len = 24.11;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '1' && name(6) == '1'
            re_len = 22.45;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '1' && name(6) == '2'
            re_len = 22.45;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '1' && name(6) == '3'
            re_len = 22.52;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '1' && name(6) == '4'
            re_len = 24.81;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '1' && name(6) == '5'
            re_len = 24.81;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '1' && name(6) == '6'
            re_len = 24.20;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '1' && name(6) == '7'
            re_len = 24.23;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '1' && name(6) == '8'
            re_len = 24.50;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '1' && name(6) == '9'
            re_len = 24.52;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '2' && name(6) == '0'
            re_len = 23.66;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '2' && name(6) == '1'
            re_len = 26.22;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '2' && name(6) == '2'
            re_len = 24.51;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '2' && name(6) == '3'
            re_len = 24.51;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '2' && name(6) == '4'
            re_len = 24.51;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '2' && name(6) == '5'
            re_len = 24.16;
           save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '2' && name(6) == '6'
            re_len = 24.15;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '2' && name(6) == '7'
            re_len = 24.15;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);        
        elseif name(5) == '2' && name(6) == '8'
            re_len = 20.44;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '2' && name(6) == '9'
            re_len = 20.84;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '3' && name(6) == '0'
            re_len = 22.30;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '3' && name(6) == '2'
            re_len = 21.06;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '3' && name(6) == '3'
            re_len = 24.84;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '3' && name(6) == '4'
            re_len = 24.06;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '3' && name(6) == '5'
            re_len = 24.92;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);  
        elseif name(5) == '3' && name(6) == '6'
            re_len = 19.66;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '3' && name(6) == '7'
            re_len = 17.78;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '3' && name(6) == '8'
            re_len = 25.14;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '3' && name(6) == '9'
            re_len = 24.36;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        elseif name(5) == '4' && name(6) == '0'
            re_len = 22.35;
            save_name = 'reg_exp'+string(name(5))+string(name(6))+'_p'+string(name(end-4))+string(k);
        end        
    
        filepath = string(path)+'\\'+string(name);  
        v = load(filepath); % loading data file corresponding to the treatment window  
        vy = v.vy2avg;   % Motility map of mean vy(dorsal-ventral)-motion as a function of time
        clear v;

         [per_power,fre,norm_peak,prom,width,ptot] = regularity_latest(vy,3,re_len,k,n_ph,0.04);
         % Fs (frame-rate) = 3Hz. and f_span (frequency-span around the peak) = 0.04 Hz. have been chosen for analysis. 

         save(save_name, 'per_power','fre','norm_peak','prom','width','ptot');
    end
    
end
