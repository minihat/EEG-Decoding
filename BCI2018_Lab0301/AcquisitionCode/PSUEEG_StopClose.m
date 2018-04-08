function [ PSUEEG ] = PSUEEG_StopClose( PSUEEG )
% send a stop command to the PSUEEG
% then close the com port
fwrite(PSUEEG.s,PSUEEG.cmd.STOP);  %% if needed stop any acquistion on the board
% flush the buffer
pause(.1);
iBA = get(PSUEEG.s,'BytesAvailable')
if (iBA>0)
    rawjunk = fread(PSUEEG.s, iBA, 'uint8'); %read data from PSUEEG.s and make it in m*n matrix
end
pause(.1);
iBA2 = get(PSUEEG.s,'BytesAvailable')
if iBA2>0
    rawjunk2 = fread(PSUEEG.s, iBA2, 'uint8'); %read data from PSUEEG.s and make it in m*n matrix
end
display iBA iBA2;
%[PSUEEG,NewData2]=PSUEEG_ReadData(PSUEEG);
% read the registers
fwrite(PSUEEG.s,PSUEEG.cmd.RREG);  
PSUEEG.CurrentRegisters = fread(PSUEEG.s, 47, 'uint8');
display( 'registers checked');
% close the port
fclose(PSUEEG.s);

end

