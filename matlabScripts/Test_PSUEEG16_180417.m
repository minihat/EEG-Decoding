%% Test the PSUEEG functions
clear all;
close all;
clc;
%% very useful thing to recall
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  delete(instrfindall)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% set(0,'defaultfigurecolor',[1 1 1]);
%% Notes on Acquisition
% PSU_EEG_BreakOut has following default configuration (spatial map)
ChanNames = {'T7','P4' ,'O3','O4','Pz','O7','O8','P3',...
             'C3','C4','Cz','T8','F4','F3','FC4','FC3'};
% ChanNames = {'FC3','C3','CP3','FC4','C4','NC','NC','CP4'};
% ChanNames = {'C1','C3','C5','FC3','NC','CP3','C2','C4',...
%     'C6','FC4','CP4','NC','PZ','Oz','NC','NC'};
% ChanNames = {'CP4','C3','C5','FC3','C6','CP3','FC4','C4',...
%     'NC','NC','NC','NC','NC','NC','NC','NC'};
%%

serList = seriallist
%%
%comPortName = 'COM3';
comNumber = 5;
    %----------------------------------------------------------------
    % opening the board and reading the register then close it
bTestBoard = false;
if bTestBoard
    psuEEG = PSUEEG16_Open_Init(comNumber,4);% sps = 1k.
    psuEEGclosed = PSUEEG16_StopClose(psuEEG);
    % display Reg values
    display(psuEEG.CurrentRegisters(1:26)');
end
%% Open and initialize the board
psuEEG = PSUEEG16_Open_Init(comNumber,4); 

%% Test all channels, 10 seconds, and plot

% now start acquiring data
psuEEG = PSUEEG16_StartAcq( psuEEG );
% wait one second to settle
pause(1);
[psuEEG,NewData0]=PSUEEG16_ReadData(psuEEG);
pause(10);
% stop the board
psuEEG=PSUEEG16_Stop(psuEEG);
[psuEEG,Data10]=PSUEEG16_ReadData(psuEEG);%%
[b,a] = butter(4,[1 35]/(psuEEG.control.SPS/2));
Data10.fData = filtfilt(b,a,Data10.Channels')';
stdData = std(Data10.fData(:));
times = (1:length(Data10.fData(1,:)))/psuEEG.control.SPS;
offset = 2*stdData;
for ind = 1:16
    Data10.fData(ind,:) =Data10.fData(ind,:) + (1-ind)*offset;
end
hFig = figure;
plot(times,Data10.fData);
%% Iteratively read and plot selected channels
ChansToPlot = [9:16];
Offset = 200;
MaxIterates = 300;
SecondsPerIterate = 3;
FilterRange = [1 35];
psuEEG = PSUEEG16_StartAcq( psuEEG );
%**************
%set up
nChans = length(ChansToPlot);
[b,a] = butter(4,FilterRange/(psuEEG.control.SPS/2));
% wait one second to settle
pause(5);
[psuEEG,DataIt]=PSUEEG16_ReadData(psuEEG);
[DataIt.fData,zi] = filter(b,a,DataIt.Channels(ChansToPlot,:),[],2);
figure;
btn = uicontrol('Style', 'togglebutton', 'String', 'Stop',...
        'Position', [20 20 50 20]);
ind = 0;
while ( ind<MaxIterates && btn.Value<1)
    ind = ind+1;
    pause(SecondsPerIterate);
    [psuEEG,DataIt]=PSUEEG16_ReadData(psuEEG);
    [DataIt.fData,zi] = filter(b,a,DataIt.Channels(ChansToPlot,:),zi,2);
    for iC = 1:nChans
        DataIt.fData(iC,:) = DataIt.fData(iC,:) + (1-iC)*Offset;
    end
    plot(DataIt.fData');
    fprintf('iterate = %5d of %d\r',ind,MaxIterates);
end
psuEEG=PSUEEG16_Stop(psuEEG);
[psuEEG,tmp]=PSUEEG16_ReadData(psuEEG);%%
%% Close board and release COM
psuEEGclosed = PSUEEG16_StopClose(psuEEG);
%%


