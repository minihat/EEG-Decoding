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
%*******************************************
%*******************************************
%  Set UP RECORDING PARAMETERS HERE
%*******************************************
% 
nTrials = 15;
bRest_Not_Tap = true;
FileNameRoot = 'Data';

%% Create the Figure
Figure = Make_ERDERS_TapFigure();
%Figure.Cir.Visible = 'on';
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
%% Section that Takes the Data
% first generate the file name
OutputFileName = GenerateFileNameWDate(FileNameRoot);
% Now Open the Port

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
% Right = 1 Left = 9
Data.TrialType = mod(randperm(nTrials),2);
PointsWithin = 1:4;
%Data.TNT = mod(randperm(nTrials),2);
%action = [];
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
    pause(5);
    PointsWithin(3) = PSUEEG_PointsAvailable_Mouse(psuEEG);
    %if (Data.TNT(ind)>0)
        bRest_Not_Tap = true;
     %   action = [action; bRest_Not_Tap];
    
   % else
    %    bRest_Not_Tap = false;
     %   action = [action; bRest_Not_Tap];
    %end
    if bRest_Not_Tap
        Figure.Rest.Visible = 'on';  
    else
        Figure.Tap.Visible = 'on'; 
    end
    PointsWithin(4) = PSUEEG_PointsAvailable_Mouse(psuEEG);
    pause(1);
    if bRest_Not_Tap
        Figure.Rest.Visible = 'off';
    else
        Figure.Tap.Visible = 'off';
    end
    pause(1+rand()*2);
    display(ind);
    [psuEEG,NewData]=PSUEEG_ReadData_Mouse(psuEEG);
    Data.ERDTrialData(ind).PSUEEGData = NewData;
    Data.ERDTrialData(ind).TimePoints = PointsWithin;
end    
%
%sound(Waves.Opened,Waves.FS);
%psuEEG = PSUEEG_StopClose(psuEEG);
% read data
% release COM
psuEEGclosed = PSUEEG_StopClose(psuEEG);
%
save(OutputFileName,'Data');
%% plot data 

