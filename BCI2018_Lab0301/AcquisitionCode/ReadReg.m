%% Test the RREG functions
%     clear all;
% 
%     close all;
%     clc;
%%
cow = instrfind;
%%
%------------------------------------
% Configure serial Port
%------------------------------------
%s = serial(strcat('COM',num2str(nComPort)));
count = 0;
s = serial('COM3');
%display(s);
set(s, 'BaudRate', 128000, 'StopBits', 1);
set(s, 'Terminator', 'LF', 'Parity', 'none');
set(s, 'FlowControl', 'none');
ipBufSize = 10*1000;
set(s, 'InputBufferSize',ipBufSize);
%% now open the serial port
fopen(s);
while  strcmp(s.Status,'closed')
    fopen(s);
end
%% write a command to com port
clc;
count = count+1
%commandNow = 7; %114 for 'r',115 for 's', 7 for rreg, 4 for rdatac
%fwrite(s,commandNow);  %% if needed stop any acquistion on the board
commandNow = zeros([27 1],'uint8'); %114 for 'r',115 for 's', 7 for rreg, 4 for rdatac, 30 for powerup
%commandNow(1)=30;
%fwrite(s,commandNow);  %% if needed stop any acquistion on the board
commandNow(1)=7;
fwrite(s,commandNow);  %% if needed stop any acquistion on the board
% read a 10 byte response
response = fread(s, 26, 'uint8');
display(response);
%% close the com port
fclose(s);