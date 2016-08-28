function [MSD,timelabel] = getMSD(tLng,pm,pathnr,varargin)
%
%
% function to calculate the MSD (means squared displacement / distance)
%
%

% create output vars 
MSD = [];
timelabel = [];

if ~isempty(pm{pathnr,3})
    timelabel = pm{pathnr,3}(1:end-1,1);
    
    % get centroid position for each cell(mask) in the path
    centroids = getPathCentroids(tLng,pm,pathnr);
    % number of positions 
    N = size(centroids,1);
    % reinit var MSD 
    MSD = zeros(N-1,1);
    % loop over (N-1) positions
    for n = 1:(N-1)
        % loop over all possible pairs with distance n
        for i=1:(N-n)
            MSD(n) =  MSD(n) + sum((centroids(i+n,:) - centroids(i,:)).^2);
        end
        % normalize the MSD
        MSD(n) = MSD(n) / (N-n);
    end
end

