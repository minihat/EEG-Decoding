function [ nPoints ] = PSUEEG_PointsAvailable_Mouse( PSUEEG )
%% first check if it is reading 
bReading = strcmp(PSUEEG.status, 'RDATAC');
%% if got here then it is reading
% first check how many bytes are available
iBA = get(PSUEEG.s,'BytesAvailable');
nPoints = floor(iBA/PSUEEG.control.BPS);
end
