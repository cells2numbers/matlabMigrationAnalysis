function [ h ] = create_roseplot( a )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


figure();
[T,R] = rose(a,20);
h = polarplot(T,R);
title({'Number trajectories'},'FontWeight','bold','FontSize',16,...
   'Color',[0 0 1]);
pax = gca;
ticklabel = {};
for tic=0:11  
    ticklabel{tic+1} = [sprintf('%i%c',tic*30,char(176))];
end

pax.ThetaAxis.TickLabels = ticklabel;

%pax.FontSize = 14;
pax.RColor = [0 0 1];
pax.GridColor = 'black';
pax.LineWidth = 2;
pax.RAxis.Label.Rotation = 0;
pax.RAxisLocation = 80;

%pax.RAxis.Label.String = sprintf('Winkel [%c]', char(176));
pax.RAxis.Label.String = '\color[rgb]{0,0,0} \bf Angle in [\circ]';
pax.TitleFontSizeMultiplier = 1.3;
limits = pax.RAxis.Limits;

pax.RAxis.FontSize = 18;

pax.RAxis.Label.Position = [270  limits(2) * 1.13 0  ];
pax.RAxis.Color

set(h,'color','b','linewidth',1.5)


end

