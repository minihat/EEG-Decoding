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
InitialWaves = ReadWavesInitialTest();

%% Now Open the Port
psuEEG = PSUEEG_Open_Init_Mouse(comPortName,4); 
% now start acquiring data
psuEEG = PSUEEG_StartAcq( psuEEG );
% set up to allow pausing
pause('on');
pause(5); %sample 1s data for testing
[psuEEG,NewData0]=PSUEEG_ReadData_Mouse(psuEEG);
%% set up commands
Commands = [1,2,1,2,1,3,4,5,6];
for ind = 1:length(Commands)
    cmd = Commands(ind);
    sound(InitialWaves(cmd).y,InitialWaves(cmd).Fs);
    pause(10);
    [psuEEG,NewData]=PSUEEG_ReadData_Mouse(psuEEG);
    Data{ind}.PSUEEGData = NewData;
    Data{ind}.Command = cmd;
end    
%%
%psuEEG = PSUEEG_Stop(psuEEG);
% read data
% release COM
psuEEGclosed = PSUEEG_StopClose(psuEEG);
%%
save('BCI_Initial_Bruce180125.mat','Data');
%% plot data
NewData = Data{9}.PSUEEGData;
figure; 
subplot(2,1,1);
plot((NewData.Counter-NewData.Counter(1))/1000,NewData.Channels(1,:)); 
subplot(2,1,2);
plot((NewData.Counter-NewData.Counter(1))/1000,NewData.Channels(2,:)); 
%% 
