function [ PSUEEG, NewData ] = PSUEEG_ReadData_Mouse( PSUEEG )
%% first check if it is reading 
bReading = strcmp(PSUEEG.status, 'RDATAC');
%% if got here then it is reading
% first check how many bytes are available
iBA = get(PSUEEG.s,'BytesAvailable');
nPoints = floor(iBA/PSUEEG.control.BPS);
display(nPoints);

if (nPoints<1)
    NewData.nPoints = 0;
    NewData.Counter = [];
    NewData.Status = [];
    NewData.Channels = [];
    return;
else
    NewData.nPoints = nPoints;
    NewData.Counter = zeros(1,nPoints,'int32'); 

    NewData.Status = zeros(1,nPoints,'int32');
%     display(nPoints);
    NewData.Channels = zeros(nPoints,PSUEEG.control.channels,'double');
end
%% now read the data
raweegdata = fread(PSUEEG.s, nPoints*PSUEEG.control.BPS, 'uint8');
%read data from PSUEEG.s and make it in m*n matrix

raw_re = reshape(raweegdata, PSUEEG.control.BPS, []); 
%reshape raweegdata to psueeg.control.bps row
NewData.Counter = bitshift(raw_re(1,:),16) + ...
    bitshift(raw_re(2,:),08) + raw_re(3,:);

NewData.Status = bitshift(raw_re(4,:),16) + ...
    bitshift(raw_re(5,:),08) + raw_re(6,:);

NewData.Channels = bitshift(raw_re(PSUEEG.control.ADSHB,:),16) + ...
    bitshift(raw_re(PSUEEG.control.ADSMB,:),8) + raw_re(PSUEEG.control.ADSLB,:);

x = find(NewData.Channels(:,:)>8388607);
NewData.Channels(x) = (-1)*(2^24 - NewData.Channels(x));
NewData.Channels = NewData.Channels*PSUEEG.control.ADSscaling;
end

