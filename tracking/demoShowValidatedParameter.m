
 load manualTrackTLng;

 %%
 data = getValidatedParameter(tLng,pm,fm);

 
 %%
dataIn = {data,data};

D = mergeData(dataIn);

 %%
 x = 5;
 y = 6;
 
 
 h = figure();
 ax = [ 0 data.limMax(x) 0 data.limMax(y)];
 
 
 for i=1:tLng.time_max
     scatterhist(data.compactness{i},data.speed{i});
    axis(ax);
    drawnow;
    %pause(.1)
 end
 
 