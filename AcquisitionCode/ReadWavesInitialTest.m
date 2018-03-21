function [InitialWaves] = InitialWaves()
% TestWave
%PlayAudio
WaveFileNames = {'EyesOpen.wav',...
    'EyesClosed.wav',...
    'Blink.wav',...
    'RollEyes.wav',...    
    'GritTeeth.wav',...
    'Rest.wav'};
%%
WaveDir = './InitialTest/';
for ind = 1:6
    [y,Fs] = audioread(strcat(WaveDir,WaveFileNames{ind}));
    InitialWaves(ind).y = y;
    InitialWaves(ind).Fs = Fs;
    InitialWaves(ind).File = WaveFileNames(ind);
end
return 
%%
%sound(Waves(1).y,Waves(1).Fs);
