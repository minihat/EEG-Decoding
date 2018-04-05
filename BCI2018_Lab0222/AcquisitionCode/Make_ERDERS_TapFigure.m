function [Figure] = Make_ERDERS_TapFigure()
%UNTITLED2 Summary of this function goes here
Figure.hfig = figure;
%%
Figure.Axis = subplot(1,1,1);
Figure.Axis.XAxis.Visible = 'off';
Figure.Axis.YAxis.Visible = 'off';
axis([-1 1 -1 1]);
%%
ArrowWid = 0.1;
x = 0.5+ArrowWid*[-1 1]/2;
y = [0.5 0.5];
Figure.RA = annotation('arrow',x,y);
Figure.RA.Visible = 'off';
%%
x = 0.5-ArrowWid*[-1 1]/2;
y = [0.5 0.5];
Figure.LA = annotation('arrow',x,y);
Figure.LA.Visible = 'off';
%%
Di = 0.05;
Figure.Cir = annotation('ellipse',[0.5-Di/2 0.5-Di/2 Di Di]);
Figure.Cir.Visible = 'off';
%%
Figure.Tap = annotation('textbox',[0.3 0.4 0.4 0.2],'String','TAP',...
    'FontSize',24,...
    'LineStyle','none','HorizontalAlignment','center','VerticalAlignment','middle');
Figure.Tap.Visible = 'off';
%%
Figure.Rest = annotation('textbox',[0.3 0.4 0.4 0.2],'String','REST',...
    'FontSize',24,...
    'LineStyle','none','HorizontalAlignment','center','VerticalAlignment','middle');
Figure.Rest.Visible = 'off';

end

