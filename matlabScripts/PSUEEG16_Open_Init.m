function [ PSUEEG ] = PSUEEG16_Open_Init( nComPort,nSPS )
% ********************
% Jerry171024
% ********************
% Open a PSU_EEG port
%  nComPort = number of the com port (i.e. 3 => COM3 )
%  nSPS is index for samples per second:
%    1 =>  250
%    2 =>  500
%    3 => 1000
%    4 => 2000
%    5 => 4000
%    6 => 8000
%%
%------------------------------------
% Initialize values - needs to be updated for more than 8 channel board  
%------------------------------------
control.Bcounter = 3; % 3 Bytes Counter for each sample;
control.Bstatus = 3; % 3 Bytes Status for each ADS; 
control.Baccel = 2; % 2 ByteS for each axis of Acc, X,Y,Z;
control.Bothers = 0; % for oxygen sensor and other functions;

control.channels=8; % channel number of each ADS
control.NADS = 2; % number of ADS
control.NAcc = 3; % numer of Acc axis

% Bytes Per Sample
control.BPS = control.Bcounter+control.NADS*(control.Bstatus+3*control.channels)+3*control.Baccel+control.Bothers;

control.datapackage=zeros(control.BPS,1,'uint32');

control.SPS=125 * 2^nSPS;
control.iBA = 0;
control.Counter=0;
control.Status=0;
control.channeldata32=zeros(control.NADS*control.channels,1,'uint32');
control.channeldata=zeros(control.NADS*control.channels,1,'double');

% ***************Sample is of form******************* %
% Byte 1,2,3 are counters, 
%      4,5,6 are status of ADS1,7-30 are data from ADS1,
%      31-33 are status of ADS2,34-57 are data from ADS2,
%      58,59 are AccX, 60,61 are AccY, 62,63 are AccZ;
% *************************************************** %
% channle data of ADS1 and ADS2, 
% one channle data consists 3 bytes: HB,MB,and LB  
chans_ADS = [(3:10),(12:19)];
control.ADSHB = 3*(chans_ADS-1)+1;
control.ADSMB = 3*(chans_ADS-1)+2;
control.ADSLB = 3*(chans_ADS-1)+3;
% data from Acc, one axis data consists 2bytes: HB and LB.
chans_Acc = (30:32);
control.AccHB = 2*(chans_Acc-1);
control.AccLB = 2*(chans_Acc-1)+1;

% ********digital to analog value transform********** %
% for ADS
control.ADSoffset = 2^23; % the first bit is sign bit
ADSVRef = 4.5E3; % 4.5 mV
% e.g 2.4 volts, converted to microvolts, no gain; %1/(2^23-1)*2400000/6;
control.ADSscaling = ADSVRef/(control.ADSoffset-1);
% for Acc
% +-2g default boundary. improve this by setting Accscaling through cmd
control.Accscaling = 6.1E-5; %0.061mg/b = 2/(2^15-1)
% *************************************************** %

% user manual: 29bytes input from PC and sent to msp430 USB
% cmd[1] is the command

% SERIAL_NO:     0
% DEVICE_LIST:   1
% READ_STATUS:   2  
% FORMAT:        3
% WRITE_STATUS:  4
% RDATAC:        5
% DEVICE_TYPES:  6  
% WREG_RDATAC:   7
% READ_ADSID:    8

% The following cmds are only for 2 ADS1299 and setup the 2 ADS together

% STOP:          10
% SDATAC:        11
% RESET:         12
% WREG:          13

% WREG2 is specific for one ADS channel open/close switch
% WREG2:         20
cmd.basecmd = zeros([29 1],'uint8');
% different cmd values
cmd.Init = cmd.basecmd; cmd.Init(1)=2;
cmd.STOP = cmd.basecmd; cmd.STOP(1)=10;
cmd.RDATAC = cmd.basecmd; cmd.RDATAC(1)=5;
%try RDATAC with 2ADS and 1Acc
%cmd.RDATAC(2)=3; 
%
cmd.WREG = cmd.basecmd; cmd.WREG(1)=24;
cmd.RREG = cmd.basecmd; cmd.RREG(1)=31;
%try RREG with 2ADS and 1Acc
%cmd.RREG(2)=3; 
%
cmd.SDATAC = cmd.basecmd; cmd.SDATAC(1)=6;
cmd.POWERUP = cmd.basecmd; cmd.POWERUP(1)=9;
cmd.SN = cmd.basecmd; cmd.SN(1)=17;
cmd.WREG1 = cmd.basecmd; cmd.WREG1(1)=25;
cmd.WREG2 = cmd.basecmd; cmd.WREG2(1)=26;
cmd.WREG2OC = cmd.WREG2; cmd.WREG2OC(4)= 17;
cmd.WREG2CC = cmd.WREG2; cmd.WREG2CC(4)= 23;

%%
%------------------------------------
% Configure serial Port
%------------------------------------
s = serial(strcat('COM',num2str(nComPort)));
display(s);
set(s, 'BaudRate', 128000, 'StopBits', 1);
set(s, 'Terminator', 'LF', 'Parity', 'none');
set(s, 'FlowControl', 'none');

ipBufSize = 30*control.SPS*control.BPS; % 10 seconds worth of data
set(s, 'InputBufferSize',ipBufSize);
%% now open the serial port
fopen(s);
while  strcmp(s.Status,'closed')
    fopen(s);
end
display( 'serial port opened');
%% initialize the board
fwrite(s,cmd.STOP);  % if needed stop any acquistion on the board
% flush the com buffer
control.iBA = get(s,'BytesAvailable');
if (control.iBA~=0)
    bOut = fread(s,control.iBA);
end
display( 'board initialized');

%% now check registers 24*2 + 1;
% one ADS has 24 register values to read. read CTRL from Acc
fwrite(s,cmd.RREG);  
PSUEEG.CurrentRegisters = fread(s, 49, 'uint8');
display('registers checked');

PSUEEG.status = 'idle';
%% Verbose
control.Verbose = false;

%% now return these things
PSUEEG.s = s;
PSUEEG.cmd = cmd;
PSUEEG.control = control;

end

