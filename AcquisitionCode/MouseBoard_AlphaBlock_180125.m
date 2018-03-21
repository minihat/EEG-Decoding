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

psuEEG = PSUEEG_Open_Init_Mouse(comPortName,4);% sps = 1k.
psuEEGclosed = PSUEEG_StopClose(psuEEG);
% display Reg values
display(psuEEG.CurrentRegisters(1:26)');
%% Now read in the files
Waves = ReadWavesAlphaBlock();

%% Now Open the Port
psuEEG = PSUEEG_Open_Init_Mouse(comPortName,4); 
% now start acquiring data
psuEEG = PSUEEG_StartAcq( psuEEG );
% set up to allow pausing
pause('on');
pause(1);
sound(Waves.Closed,Waves.FS);
pause(5); %sample 1s data for testing
[psuEEG,NewData0]=PSUEEG_ReadData_Mouse(psuEEG);
Data.InitialPeriod = NewData0;
%
%% set up commands
for ind = 1:10
    pause(3);
    sound(Waves.y{ind},Waves.FS);
    pause(7);
    display(ind);
    [psuEEG,NewData]=PSUEEG_ReadData_Mouse(psuEEG);
    Data.AlphaBlockData{ind}.PSUEEGData = NewData;
end    
%%
sound(Waves.Opened,Waves.FS);
%psuEEG = PSUEEG_StopClose(psuEEG);
% read data
% release COM
psuEEGclosed = PSUEEG_StopClose(psuEEG);
%%
save('BCI_AlphaBlock_Bruce_180125.mat','Data');
% plot data 

