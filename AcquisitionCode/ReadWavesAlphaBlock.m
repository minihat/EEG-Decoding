function [Waves] = ReadWavesAlphaBlock()
% TestWave
%PlayAudio
WaveDir = './AlphaBlock/';
%%
WaveFileName = 'CloseEyesRest.wav';
[y,Fs] = audioread(strcat(WaveDir,WaveFileName));
Waves.FS = Fs;
Waves.Closed = y;
WaveFileName = 'EyesOpen.wav';
[y,Fs] = audioread(strcat(WaveDir,WaveFileName));
Waves.Opened = y;
%%
IndsToUse = randperm(40);
%%
for ind = 1:40
    cow = sprintf('%.3d.wav',IndsToUse(ind));
    [y,Fs] = audioread(strcat(WaveDir,cow));
    Waves.y{ind}=y;
end
return 
%%
%sound(Waves(1).y,Waves(1).Fs);
