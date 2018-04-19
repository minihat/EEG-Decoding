function [out] = PSUEEG_ClearPort(ComName)
%  Sometimes the com port is stuck
%  if not properly cleared
%  if no ComName is given, then it clears all

out = 1;
if nargin<1
    delete(instrfindall);
else
    delete(instrfind('Port',ComName));
end

end

