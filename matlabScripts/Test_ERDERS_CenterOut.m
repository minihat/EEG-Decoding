%% Test ERDERS_CenterOut
hfig=Make_ERDERS_CenterOut_1D();
%%
pos = hfig.UPosition.Position;
stepSize = [0.05 0 0 0];
for ind = 1:25
    pos = pos + 0.5*(-1+(rand()>0.5))*stepSize;
    hfig.UPosition.Position = pos;
    pause(.1);
end
 
