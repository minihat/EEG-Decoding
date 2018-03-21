%% GenerateTextBaseMeasures
% generates audio (.wav) files for BCI recordings.  
% For setting up and doing base measurements, need commands:
fs = 16000;
%% Eyes Open 
wav = tts('Eyes Open',fs);
audiowrite('EyesOpen.wav',wav,fs) ;
%% Eyes Closed
wav = tts('Eyes Closed',fs);
audiowrite('EyesClosed.wav',wav,fs) ;
%% Rest
wav = tts('Rest',fs);
audiowrite('Rest.wav',wav,fs) ;
%% Grit Teeth
wav = tts('Grit Teeth',fs);
audiowrite('GritTeeth.wav',wav,fs) ;
%% Blink
wav = tts('Blink',fs);
audiowrite('Blink.wav',wav,fs) ;
%% Roll Eyes
wav = tts('Roll Eyes',fs);
audiowrite('Roll Eyes.wav',wav,fs) ;

