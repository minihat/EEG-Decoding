% This is a demo to show that Matlab can communicate with pong python
% script using an extremely hacky method (writes to hackytransferfile.txt)

% Set the update_rate parameter
update_rate = 4; %Hz

update_period = 1/update_rate;
a = 0;
figure;
bStop = uicontrol('Style', 'togglebutton', 'String', 'Stop',...
        'Position', [20 20 50 20]);
sldLR = uicontrol('Style', 'slider',...
        'Min',-1,'Max',1,'Value',0,...
        'Position', [400 20 120 20]); 
sldLR.SliderStep = [1 1];
    
%
    
fileID = fopen('hackytransferfile.txt','w');
while bStop.Value<1
%rand = randi([-1,1]);
fileID = fopen('hackytransferfile.txt','w');
%fseek(fileID, 0, 0);
fprintf(fileID, '%d', round(sldLR.Value));
%type hackytransferfile.txt
fclose(fileID);
pause(update_period);
a = a + 1;
%fprintf('a=%d\n',a);
end
