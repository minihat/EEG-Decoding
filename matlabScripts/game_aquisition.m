%% Test the PSUEEG functions
clear all;
close all;
clc;
delete(instrfindall);
%% 
serList = seriallist
%%
comPortName = '5';
    %----------------------------------------------------------------
    % opening the board and reading the register then close it
    bTestBoard = false;
if bTestBoard
    psuEEG = PSUEEG16_Open_Init(comPortName,5);% sps = 1k.
    psuEEGclosed = PSUEEG16_StopClose(psuEEG);
    % display Reg values
   display(psuEEG.CurrentRegisters(1:26)');
end

%% Now Open the Port
psuEEG = PSUEEG16_Open_Init(comPortName,5); 
% now start acquiring data
PSUEEG16_StartAcq( psuEEG );
% set up to allow pausing
pause('on');
pause(1);

% set up commands
nTrials = 1000;
% Right = 1 Left = 9
Data.TrialType = mod(randperm(nTrials),2);

tic
for ind = 1:nTrials
    t0 = clock;
    data = [];
    while etime(clock, t0) < .98
        [psuEEG,NewData] = PSUEEG16_ReadData(psuEEG);
        data = [data NewData.Channels];
    end
toc;
fileID = fopen('hackytransferfile.txt','w');
output = classify_trial(data);
output = 2*((mod(ind,10)<5)-0.5);
fprintf('out=%d\n',output);
fprintf(fileID, '%d', output);
%type hackytransferfile.txt
fclose(fileID);
toc
end    

psuEEGclosed = PSUEEG16_StopClose(psuEEG);
