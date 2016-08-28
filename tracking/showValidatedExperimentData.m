function [data,tLngFiles] = showValidatedExperimentData(ExpPath,plength,twindow,outlier)
%
%
%
% tim becker 08.2012

if ~exist('plength','var')
    plength = 5;
end

if ~exist('twindow','var')
    twindow = 5;
end

if ~exist('outlier','var')
    outlier = [];
end


% ExpPath can either link to a matlab file containing precomputed 
% validated data or to an experiment folder. in the latter case,
% the validated data is calculated.
if isdir(ExpPath)
    [data,tLngFiles] = getValidatedExperiment(ExpPath,plength,twindow,outlier);
else
    load(ExpPath)
end


plot(data.growthcurve);
xlabel('time in frames');
ylabel('cell number');

for iPara = 1:12
    figure();
    plotValidatedData(data,iPara);
end

%% 
fprintf('calculation entropy for difference images...\n');
for iFile=1:length(tLngFiles)
    load(tLngFiles{iFile});
    
    for iFrame=1:(tLng.time_max-1)
        I1 = imread(getFilename2(imInfos,iFrame));
        I2 = imread(getFilename2(imInfos,iFrame+1));
        IEntrop1(iFile,iFrame) = entropy(imsubtract(I2,I1));
        
        I3 = imread(getFilename2(imInfos2,iFrame));
        I4 = imread(getFilename2(imInfos2,iFrame+1));
        IEntrop2(iFile,iFrame) = entropy(imsubtract(I4,I3));
        
        
    end
    fprintf('finished for position %i \n',iFile);
end
%%
figure();
plot(mean(IEntrop1));
hold on;
plot(mean(IEntrop2),'--');
hold off;
xlabel('time in frames');
ylabel('entropy of difference images');
legend('ph1','phl');