function [ PSUEEG ] = PSUEEG16_Stop( PSUEEG )
% ********************
% Jerry171024
% ********************
% send a stop command to the PSUEEG
% then close the com port
fwrite(PSUEEG.s,PSUEEG.cmd.STOP);  %% if needed stop any acquistion on the board
PSUEEG.status = 'idle';
end

