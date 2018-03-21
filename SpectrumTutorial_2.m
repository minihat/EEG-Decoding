%% Spectral Estimation Tutorial 2
%  Bruce J. Gluckman
%  revised 2/2016 (original 1/26/09)
%
%  It is also helpful to read the Matlab help files for:
%     fft
%
%% make some raw data
%{
SPS = 256;      %data rate, samples-per-second
%
Tmax = 100;  % chose as 2^m
Time = 1/SPS:1/SPS:Tmax;
NPTS = length(Time);
F1 = 4;
F2 = 13;
twopi=2*pi;
Y= [sin(twopi*F1*Time); ...
    0.1*Time.*sin(twopi*F2*Time);...
    4*randn(size(Time))];
Y(4,:) = sum(Y(1:3,:),1);
%    sin(twopi*F1*Time)+3*sin(twopi*F2*Time)+4*randn(size(Time))];
%}

SPS = 1000;
Tmax = 10;
Time = 1/SPS:1/SPS:Tmax;
NPTS = length(Time);
Y = zeros(4,10000);
Y(1,:) = Bruce_Data.AlphaBlockData{1,5}.PSUEEGData.Channels(1,1:10000);
Y(2,:) = Bruce_Data.AlphaBlockData{1,5}.PSUEEGData.Channels(2,1:10000);
Y(3,:) = Bruce_Data.AlphaBlockData{1,5}.PSUEEGData.Channels(3,1:10000);
Y(4,:) = Bruce_Data.AlphaBlockData{1,5}.PSUEEGData.Channels(4,1:10000);


figure;
labels1={'Y1';'Y2';'Y3';'Y4'};
for i=1:4
    subplot(4,1,i);
    plot(Time,Y(i,:));
    ylabel(labels1{i});
end;
%
%% Now compute the average spectrum for each channel
%
% use windows of width 4 seconds
% overlapped by half
window=SPS*4;
pwY = zeros(4,window/2+1);
for i=1:4
    [pwY(i,:), w]  = pwelch(Y(i,:),window,window/2,window,SPS);
end
figure;
labels2={'PSD(Y1)';'PSD(Y2)';'PSD(Y3)';'PSD(Y4)'};
for i=1:4
    subplot(4,1,i);
    semilogy(w,pwY(i,:));
    ylabel(labels2{i});
end;
%% Now compute spectrograms
%
figure;
%labels3={'PSD(Y1)';'PSD(Y2)';'PSD(Y3)';'PSD(Y4)'};
for i=1:4
    subplot(4,3,3*(i-1)+1);
    plot(Time,Y(i,:));
    xlim([0 2.0]);
    ylabel(labels1{i});
    subplot(4,3,3*(i-1)+2);
    plot(Time,Y(i,:));
    xlim([90 92.0]);
    subplot(4,3,3*(i-1)+3);
    [s,f,t,p] = spectrogram(Y(i,:),window,window/4,window,SPS);
    imagesc(f,t,log10(p));
    set(gca,'YDir','normal');
    ylim([0 25]);
    xlim([0 100]);
end



