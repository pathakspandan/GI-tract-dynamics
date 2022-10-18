% Mean velocity subtraction for all gut locations

% INPUT 
% kymo: Motility map of mean vy(dorsal-ventral)-motion as a function of time

% OUTPUT
% out_mat = Mean-subtracted motility map

function out_mat = mean_subtract(kymo)    
    N = size(kymo,1);    
    for i = 1:N
        kymo(i,:) = kymo(i,:) - mean(kymo(i,:));
    end
    out_mat = kymo;
end
    