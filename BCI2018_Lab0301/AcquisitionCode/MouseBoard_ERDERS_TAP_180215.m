%% Test the PSUEEG functions
clear all;
close all;
clc;
%% 
serList = seriallist
%%
comPortName = 'COM4';
    %----------------------------------------------------------------
    % opening the board and reading the register then close it
    bTestBoard = false;
    if bTestBoard
    psuEEG = PSUEEG_Open_Init_Mouse(comPortName,4);% sps = 1k.
    psuEEGclosed = PSUEEG_StopClose(psuEEG);
    % display Reg values
    display(psuEEG.CurrentRegisters(1:26)');
end
%% Create the Figure
Figure = Make_ERDERS_TapFigure();
Figure.Cir.Visible = 'on';
display('Arrange the Figure and Matlab Windows Appropriately');
%% Instructions:
display('Read The following Instructions:');
display('1) Attend to the center of the figure annoted by the circle');
display('2) When the circle appears, rest and prepare for directional cue');
display('3) Remember which direction the arrow cue points');
display('4) When TAP appears, tap you index finger three times');
display('      on the side directed by the arrow');
display('Then REST');
display('');
%% Now Open the Port
psuEEG = PSUEEG_Open_Init_Mouse(comPortName,4); 
% now start acquiring data
psuEEG = PSUEEG_StartAcq( psuEEG );
% set up to allow pausing
pause('on');
pause(1);
%sound(Waves.Closed,Waves.FS);
pause(5); %sample 1s data for testing
[psuEEG,NewData0]=PSUEEG_ReadData_Mouse(psuEEG);
Data.InitialPeriod = NewData0;
%
% set up commands
nTrials = 30;
% Right = 1 Left = 9
Data.TrialType = mod(randperm(nTrials),2);
PointsWithin = 1:4;

for ind = 1:nTrials
    Figure.Cir.Visible = 'on';
    pause(3);
    Figure.Cir.Visible = 'off';
    PointsWithin(1) = PSUEEG_PointsAvailable_Mouse(psuEEG);
    if (Data.TrialType(ind)>0)
        Figure.RA.Visible = 'on';
        pause(0.5);
        Figure.RA.Visible = 'off';
    else
        Figure.LA.Visible = 'on';
        pause(0.5);
        Figure.LA.Visible = 'off';
    end
    PointsWithin(2) = PSUEEG_PointsAvailable_Mouse(psuEEG);
    pause(3);
    PointsWithin(3) = PSUEEG_PointsAvailable_Mouse(psuEEG);
    Figure.Tap.Visible = 'on';
    PointsWithin(4) = PSUEEG_PointsAvailable_Mouse(psuEEG);
    pause(1);
    Figure.Tap.Visible = 'off';
    pause(1+rand()*2);
    display(ind);
    [psuEEG,NewData]=PSUEEG_ReadData_Mouse(psuEEG);
    Data.ERDTrialData{ind}.PSUEEGData = NewData;
    Data.ERDTrialData{ind}.TimePoints = PointsWithin;
end    
%
%sound(Waves.Opened,Waves.FS);
%psuEEG = PSUEEG_StopClose(psuEEG);
% read data
% release COM
psuEEGclosed = PSUEEG_StopClose(psuEEG);
%%
save('BCI_ERDERS_Tap_180215 Third.mat','Data');
% plot data 

