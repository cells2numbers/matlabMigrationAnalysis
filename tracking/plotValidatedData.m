function h = plotValidatedData(data,para1,para2,labelName)
%
%
%
%
%
%
%
%
% tim becker 08.2012 

% for single parameter plots we can plot the std 
STD = 1;

if ~exist('labelName','var')
    labelName = {'Area','Brightness','Length','Compactness','Orientation',...
        'Speed','Migration','\Delta Area','\Delta Brightness',...
        '\Delta Length','\Delta Compactness','\Delta Orientation'};
end

% optional only one parameter is plotted and the x-axis shows the
% time of the experiment
if ~exist('para2','var')
    yLabelName = labelName{para1};
    xLabelName = 'tim in frames';
    
    x = 1:size(data.mean,1);
    
    
    if para1 < 8
        y = data.mean(:,para1);
        yStd = data.std(:,para1);
    else
        y = data.dmean(:,para1-7);
        yStd = data.dstd(:,para1 - 7);
    end
    
else % two parameters are given
    
    xLabelName = labelName{para1};
    yLabelName = labelName{para2};
    
    if para1 < 9
        x = data.mean(:,para1);
        %xStd = data.std(:,para1);
    else
        x = data.dmean(:,para1-7);
        %xStd = data.dstd(:,para1-7);
    end
    
    if para2 < 9
        y = data.mean(:,para2);
        yStd = data.std(:,para2);
    else
        y = data.dmean(:,para2 - 7);
        yStd = data.dstd(:,para2 - 7);
    end
    
end

if ~exist('para2','var')
      plot(x,y);
    if STD
      hold on;
        plot(x,y-yStd,'--');
        plot(x,y+yStd,'--');
        hold off;
    end
else
    plot(x,y);
end

xlabel(xLabelName);
ylabel(yLabelName);