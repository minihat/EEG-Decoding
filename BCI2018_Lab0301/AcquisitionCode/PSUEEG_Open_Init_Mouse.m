function [ PSUEEG ] = PSUEEG_Open_Init_Mouse( ComPortName,nSPS )
%------------------------------------
% Initialize values 
%------------------------------------
control.Bcounter = 3; % 3 Bytes Counter for each sample;
control.Bstatus = 3; % 3 Bytes Status for ADS; 
control.Baccel = 0; % No acc on Mouseboard
control.Bothers = 0; % No oxygen sensor and other functions;

control.channels= 8; % channel number of each ADS
control.NADS = 1; % number of ADS
control.NAcc = 0; % numer of Acc axis

% Bytes Per Sample
control.BPS = control.Bcounter+control.NADS*(control.Bstatus+3*control.channels)+3*control.Baccel+control.Bothers;

control.datapackage=zeros(control.BPS,1,'uint32');

control.SPS=125 * 2^nSPS;
control.iBA = 0;
control.Counter=0;
control.Status=0;
% ***************Sample is of form******************* %
% Byte1,2,3 are counters, 
% 4,5,6 are status of ADS,7-30 are data from ADS,
% *************************************************** %
% channle data of ADS1 and ADS2, 
% one channle data consists 3 bytes: HB,MB,and LB  
chans_ADS = [(3:10)];
control.ADSHB = 3*(chans_ADS-1)+1;
control.ADSMB = 3*(chans_ADS-1)+2;
control.ADSLB = 3*(chans_ADS-1)+3;

% ********digital to analog value transform********** %
% for ADS
control.ADSoffset = 2^23; % the first bit is sign bit
ADSVRef = 4.5;
control.ADSscaling = ADSVRef/(control.ADSoffset-1);
% assumes that 2.4 volts, converted to microvolts, no gain; %1/(2^23-1)*2400000/6;
% *************************************************** %

%% initialize the commands
% 27 bytes sent to msp430 USB
cmd.basecmd = zeros([27 1],'uint8');

% different cmd values
cmd.Init = cmd.basecmd; cmd.Init(1)=2;
cmd.STOP = cmd.basecmd; cmd.STOP(1)=3;
cmd.RDATAC = cmd.basecmd; cmd.RDATAC(1)=4;
%
cmd.WREG = cmd.basecmd; cmd.WREG(1)=24;
cmd.RREG = cmd.basecmd; cmd.RREG(1)=7;
%
cmd.SDATAC = cmd.basecmd; cmd.SDATAC(1)=6;
cmd.POWERUP = cmd.basecmd; cmd.POWERUP(1)=9;

%------------------------------------
% Configure serial Port
%------------------------------------
%s = serial(strcat('COM',num2str(nComPort)));
%comList = 
s = serial(ComPortName);
display(s);
set(s, 'BaudRate', 128000, 'StopBits', 1);
set(s, 'Terminator', 'LF', 'Parity', 'none');
set(s, 'FlowControl', 'none');

ipBufSize = 10*control.SPS*control.BPS; % 10 seconds worth of data
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
display( 'board initialized');

%% now check registers of ADS;
% 26 register values to read. 
fwrite(s,cmd.RREG);  
PSUEEG.CurrentRegisters = fread(s, 26, 'uint8');
display('registers checked');

PSUEEG.status = 'idle';

%% now return these things
PSUEEG.s = s;
PSUEEG.cmd = cmd;
PSUEEG.control = control;

end

