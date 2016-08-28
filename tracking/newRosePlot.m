function h = newRosePlot(angle,rMax,nbins,color) 
%
%
%
%
%
%
%
 

if ~exist('color','var')
    color = [0 1 0];
end

[t,r] = rose(angle,nbins);

% set plot's max radial ticks

h = polar(0, rMax);
delete(h)
set(gca, 'Nextplot','add')

%  draw patches instead of lines: polar(t,r)
[x,y] = pol2cart(t,r);
h = patch(reshape(x,4,[]), reshape(y,4,[]),'g');
set(h,'FaceColor',color);
%alpha(h, 0.2)    
% 
% ax = axis();
% ax(3) = 0;
% axis(ax);