function [ PSUEEG, NewData ] = PSUEEG16_ReadData( PSUEEG )
% ********************
% Jerry171024
% ********************
% read the data from the PSUEEG and fill out the structure NewData
%     NewData.nPoints
%     NewData.Counter (1*nPoints)
%     NewData.Status (2*nPoints)
%     NewData.Channels ((2*8)*nPoints)
%     NewData.Acc (3*nPoints)
%% first check if it is reading 
bReading = strcmp(PSUEEG.status, 'RDATAC');
%% if got here then it is reading
% iBA = number of available bytes in USB cache
iBA = get(PSUEEG.s,'BytesAvailable');
% nPoints: number of whole data packages
nPoints = floor(iBA/PSUEEG.control.BPS);
if PSUEEG.control.Verbose
    display(nPoints);
end

if (nPoints<1)
    NewData.nPoints = 0;
    NewData.Counter = [];
    NewData.Status = [];
    NewData.Channels = [];
    NewData.Acc = [];
    return;
else
    NewData.nPoints = nPoints;
    NewData.Counter = zeros(1,nPoints,'int32'); %0 matrix: npoints row and one column with int32 datatype
    NewData.Status = zeros(PSUEEG.control.NADS,nPoints,'int32');
    NewData.Channels = zeros(PSUEEG.control.NADS*PSUEEG.control.channels,nPoints,'double');
    NewData.Acc = zeros(PSUEEG.control.NAcc,nPoints,'double');
end
%% now read the data
  % try using the fixed point quantizer to do twos complement on the data
  % using bin2num!!!!!!
Rawdatapackage = fread(PSUEEG.s, nPoints*PSUEEG.control.BPS, 'uint8'); %read data from PSUEEG.s and make it in m*n matrix
raw_re = reshape(Rawdatapackage, PSUEEG.control.BPS, []); %reshape raweegdata to psueeg.control.bps row

% Bitshift of 3 bytes counter
NewData.Counter = bitshift(raw_re(1,:),16) + ...
    bitshift(raw_re(2,:),08) + raw_re(3,:);
% Bitshift of 3 bytes ADS1 status
NewData.Status = bitshift(raw_re(4,:),16) + ...
    bitshift(raw_re(5,:),08) + raw_re(6,:);
% Bitshift of 3 bytes ADS2 status
NewData.Status = bitshift(raw_re(31,:),16) + ...
    bitshift(raw_re(32,:),08) + raw_re(33,:);
% Bitshift of data from ADS1 and ADS2
NewData.Channels = bitshift(raw_re(PSUEEG.control.ADSHB,:),16) + ...
    bitshift(raw_re(PSUEEG.control.ADSMB,:),8) + raw_re(PSUEEG.control.ADSLB,:);
% Bitshift of data from Acc
%NewData.Acc = bitshift(raw_re(PSUEEG.control.AccHB,:),8) + raw_re(PSUEEG.control.AccLB,:);
NewData.Acc = bitshift(raw_re(PSUEEG.control.AccLB,:),8) + raw_re(PSUEEG.control.AccHB,:); %This should be wrong

%2's complement of ADS data
x = find(NewData.Channels(:,:)>8388607); % 2^23 = 8388608 
% if NewData.Channels is larger than 8388607 it is negative.
NewData.Channels(x) = (-1)*(2^24 - NewData.Channels(x));
NewData.Channels = NewData.Channels*PSUEEG.control.ADSscaling;

%2's complement of Acc data
y = find(NewData.Acc(:,:)>32767); % 2^15 = 32768
NewData.Acc(y) = (-1)*(2^16 - NewData.Acc(y));
NewData.Acc = NewData.Acc*PSUEEG.control.Accscaling;

end

