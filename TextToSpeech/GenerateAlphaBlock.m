%% GenerateTextBaseMeasures
% generates audio (.wav) files for BCI recordings.  
% For setting up and doing base measurements, need commands:
fs = 16000;
Dir = './AlphaBlock/';
if ~isfolder(Dir)
    mkdir(Dir);
end
%% Eyes Open
flRoot = 'EyesOpen';
wav = tts('Eyes Open',fs);
audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
%% Close Eyes and Rest
flRoot = 'CloseEyesRest';
wav = tts('Close Eyes and Rest',fs);
audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
%% Now generate a long 4xN list of math operations from among four types:
%  Add 2 digit integers
%  Subtract 2 digit integers
%  Multiply 2 digit integers
%  Divide 2 digit intergers
N = 10;
%% Addition 
for ind = 1:N
    flRoot = sprintf('%.3d', ind);
    A = floor(100*rand());
    B = floor(100*rand());
    cmd = sprintf('%d plus %d',A,B);
    wav = tts(cmd,fs);
    audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
end
%% Subtraction
for ind = 1:N
    flRoot = sprintf('%.3d', N+ind);
    A = floor(100*rand());
    B = floor(100*rand());
    cmd = sprintf('%d minus %d',A+B,B);
    wav = tts(cmd,fs);
    audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
end
%% Multiplication
for ind = 1:N
    flRoot = sprintf('%.3d', 2*N+ind);
    if (rand()>0.5)
        A = floor(30*rand());
        B = floor(5*rand())+1;
    else
        A = floor(5*rand())+1;
        B = floor(30*rand());
    end
    cmd = sprintf('%d times %d',A,B);
    wav = tts(cmd,fs);
    audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
end
%% Division
for ind = 1:N
    flRoot = sprintf('%.3d', 3*N+ind);
    if (rand()>0.5)
        A = floor(30*rand());
        B = floor(5*rand())+1;
    else
        A = floor(5*rand())+1;
        B = floor(29*rand())+1;
    end
    cmd = sprintf('%d divided by %d',A*B,B);
    wav = tts(cmd,fs);
    audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
end
