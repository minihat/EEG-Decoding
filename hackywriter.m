% This is a demo to show that Matlab can communicate with pong python
% script using an extremely hacky method (writes to hackytransferfile.txt)

% Set the update_rate parameter
update_rate = 4; %Hz

update_period = 1/update_rate;
a = 0;
while true
fileID = fopen('hackytransferfile.txt','w');
rand = randi([-1,1]);
fprintf(fileID, '%d', rand);
type hackytransferfile.txt
fclose(fileID);
pause(update_period)
a = a + 1
disp(a)
end
