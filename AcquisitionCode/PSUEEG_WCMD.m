function [ PSUEEG ] = PSUEEG_WCMD( PSUEEG,CMD )
% send a stop command to the PSUEEG
% then close the com port
fwrite(PSUEEG.s,CMD);  %% if needed stop any acquistion on the board
end

