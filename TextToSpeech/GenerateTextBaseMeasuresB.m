%% GenerateTextBaseMeasures
% generates audio (.wav) files for BCI recordings.  
% For setting up and doing base measurements, need commands:
fs = 16000;
Dir = './InitialTest/';
if ~isfolder(Dir)
    mkdir(Dir);
end
%% Eyes Open
flRoot = 'EyesOpen';
wav = tts('Eyes Open',fs);
audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
%% Eyes Closed
flRoot = 'EyesClosed';
wav = tts('Eyes Closed',fs);
audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
%% Rest
flRoot = 'Rest';
wav = tts('Rest',fs);
audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
%% Grit Teeth
flRoot = 'GritTeeth';
wav = tts('Grit Teeth',fs);
audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
%% Blink
flRoot = 'Blink';
wav = tts('Blink',fs);
audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;
%% Roll Eyes
flRoot = 'RollEyes';
wav = tts('Roll Eyes',fs);
audiowrite(strcat(Dir,flRoot,'.wav'),wav,fs) ;

