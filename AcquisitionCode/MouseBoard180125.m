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

%% first try the open command
psuEEG = PSUEEG_Open_Init_Mouse(comPortName,4); 
% now start acquiring data
psuEEG = PSUEEG_StartAcq( psuEEG );
% set up to allow pausing
pause('on');
pause(1); %sample 1s data for testing
psuEEG = PSUEEG_Stop(psuEEG);
% read data
[psuEEG,NewData5]=PSUEEG_ReadData_Mouse(psuEEG);
% release COM
psuEEGclosed = PSUEEG_StopClose(psuEEG);
%-------------------------------------------------------------
% plot data 
figure; 
subplot(2,1,1);
plot(NewData5.Counter-NewData5.Counter(1),NewData5.Channels(1,:)); 
subplot(2,1,2);
plot(NewData5.Counter-NewData5.Counter(1),NewData5.Channels(2,:)); 

