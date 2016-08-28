function centroids = getPathCentroids(tLng,pm,pathnr)
% centroids = getPathCentroids(tLng,pm,pathnr)
%
%  function to return the centroids of each cell belonging to a part
%
% for a cellpath with length n, a list of size nx2 is returned
%
% see also getPathSMD
%
% tim becker 1.2012



cellpath = pm{pathnr,3};

cellpathLength = size(cellpath,1);
centroids = zeros(size(cellpath));


for i=1:cellpathLength
    iFrame = cellpath(i,1);
    iCell = cellpath(i,2);
    centroids(i,:) = tLng.cell(iFrame).centroid(iCell,:);
end



