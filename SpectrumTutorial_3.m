%% Spectral Estimation Tutorial 3 
%  Bruce J. Gluckman
%  revised 2/2016 (2/1210)
%
%  It is also helpful to read the Matlab help files for:
%     fft,dpss
%
%  Overall objectives are to compare spectral estimation using fourier
%  techniques:
%    Periodorogram
%    Hanning Window
%    Multitaper methods (Thomson 1982)
%
%% Want to work with band limited data - make bandpass
%
%  generally, we will want to investigate band limited data
%  so we will use an IIR bandpass filter
%  use digital IIR butterworth filter - it is OK
%
SPS = 512;      %data rate, samples-per-second
%
fMin = 2; 
fMax = 60;
Wn = [fMin  fMax]/(SPS/2);
% make an n=5th order butterworth bandpass filter
[bButter,aButter]=butter(5,Wn);
freqz(bButter,aButter,4*SPS/2,SPS);
title('Frequency response of the bandpass filter');

%% make raw data
%  band limited noise (2-60 Hz)
%  discrete, with acquisition rate of 512 SPS
%  sinusoids at 10 and 25 Hz
%
Tmax = 100;  % chose as 2^m
Time = 1/SPS:1/SPS:Tmax;
NPTS = length(Time);
F1 = 10;
F2 = 25;
twopi=2*pi;
Y = sin(twopi*F1*Time)+sin(twopi*F2*Time)+3*randn(size(Time));
Y = filtfilt(bButter,aButter,Y);
labels={'Y1'};
%% Plot Raw Data
figure;
RawData.a(1) = subplot(2,1,1)
range1 = 1:10*SPS;
range2 = SPS:2*SPS;
plot(Time(range1),Y(range1));
xlim([0 10]);
title({'Raw time series for analysis:','sin(2\pi*F_1*t)+sin(2\pi*F_2*t)+3*rand'});
xlabel('time (s)');
ylabel('Y');
RawData.a(2) = subplot(2,1,2);
title('Signal and ideal sinusoidal parts');
plot(Time(range2),Y(range2),'b',...
    Time(range2),sin(twopi*F1*Time(range2)),'--r',...
    Time(range2),sin(twopi*F2*Time(range2)),'--g');
legend({'Y','sin(2\pi*F_1*t)','sin(2\pi*F_2*t)'});
xlim([1 2])
xlabel('time (s)');
ylabel('Y');
RealPower = sum(Y.*Y);
%
%% now compute periodogram spectral estimator
%
NPTS_Win = 1024;
TWin = NPTS_Win/SPS;
deltaF = 1/TWin;
Fn = SPS/2;
F = [0:deltaF:Fn , -Fn+deltaF:deltaF:-deltaF];
rangeF = (1:NPTS_Win/2+1);
pY = fft(Y,NPTS_Win);
% note that
spY = pY.*conj(pY);
figure;
subplot(2,1,1);
semilogy(F(rangeF),spY(rangeF));
title('Periodogram for Y on 2 second window')
xlabel('Frequency (Hz)');
ylabel('PSD');
xlim([0 100]);
subplot(2,1,2);
semilogy(F(rangeF),spY(rangeF));
xlim([0 15]);
xlabel('Frequency (Hz)');
ylabel('PSD');
%% Variance of Spectral Estimator Away from Lines

iWinStart = SPS:NPTS_Win/2:NPTS-NPTS_Win;
range_offset = 1:NPTS_Win;
Spectogram_Per = zeros(length(iWinStart),length(rangeF));
WindowTimes = Time(iWinStart);
%
for j = 1:length(iWinStart)
    range_now = iWinStart(j)+range_offset;
    pY = fft(Y(range_now),NPTS_Win);
    spY = pY.*conj(pY);
    Spectogram_Per(j,:) = spY(rangeF);
end;
%% Compute Statistics for 10 Hz Line and 15-20 Hz Noise
%
index10 = 10/deltaF+1;
index15 = 15/deltaF+1;
index20 = 20/deltaF+1;

[Pprob10,pow10hbins] = hist(Spectogram_Per(:,index10));
Pprob10 = Pprob10/length(WindowTimes);
[Pproblog10,logpow10hbins] = hist(log10(Spectogram_Per(:,index10)));
Pproblog10 = Pproblog10/length(WindowTimes); 
[f10,pow10] = ecdf(Spectogram_Per(:,index10));
[flog10,logpow10] = ecdf(log10(Spectogram_Per(:,index10)));
%
[Pprob15to20,pow15to20hbins] = hist(reshape(Spectogram_Per(:,index15:index20),1,[]));
Pprob15to20 = Pprob15to20/(length(WindowTimes)*(index20-index15+1));
[Pproblog15to20,logpow15to20hbins] = hist(log10(reshape(Spectogram_Per(:,index15:index20),1,[])));
Pproblog15to20 = Pproblog15to20/(length(WindowTimes)*(index20-index15+1));
[f15to20,pow15to20] = ecdf(reshape(Spectogram_Per(:,index15:index20),1,[]));
[flog15to20,logpow15to20] = ecdf(log10(reshape(Spectogram_Per(:,index15:index20),1,[])));
% compute mean and variance
MeanP10 = mean(Spectogram_Per(:,index10));
VarP10 = var(Spectogram_Per(:,index10));
%
MeanP15to20 = mean(reshape(Spectogram_Per(:,index15:index20),1,[]));
VarP15to20 = var(reshape(Spectogram_Per(:,index15:index20),1,[]));



%% Plotting Statistics for 10 Hz Line 
figure;
subplot(3,1,1);

semilogy(WindowTimes,Spectogram_Per(:,index10),'m');
title('Power in 10 Hz line measured in 2 s windows');
xlabel('Time (s)');
ylabel('Power');

subplot(3,2,3);

plot(pow10hbins,Pprob10,'m');
xlabel('Power');
ylabel('PDF');

subplot(3,2,4);
stairs(logpow10hbins,Pproblog10,'m');
xlabel('log10(Power)');
ylabel('PDF');

    
subplot(3,2,5);
stairs(pow10,f10,'m'); xlabel('Power');
ylabel('CDF');

subplot(3,2,6);
stairs(logpow10,flog10,'m');
xlabel('log10(Power)');
ylabel('CDF');
% display mean and variance
disp('statistics on power at 10 Hz');
fprintf('mean = %d \n RMS %d \n RMS/mean %d\n',MeanP10,sqrt(VarP10),sqrt(VarP10)/MeanP10);

%% Plotting Statistics for 15-20 Hz Noise
%
figure;
subplot(3,1,1);

semilogy(WindowTimes,Spectogram_Per(:,index15),'g');
title({'Power at 15 Hz (noise) measured in 2 s windows','(Stats for 15-20Hz)'});
xlabel('Time (s)');
ylabel('Power');

subplot(3,2,3);
stairs(pow15to20hbins,Pprob15to20,'g');
xlabel('Power');
ylabel('PDF');

subplot(3,2,4);
stairs(logpow15to20hbins,Pproblog15to20,'g');
xlabel('log10(Power)');
ylabel('PDF');

    
subplot(3,2,5);
stairs(pow15to20,f15to20,'g'); 
xlabel('Power');
ylabel('CDF');

subplot(3,2,6);
stairs(logpow15to20,flog15to20,'g'); 
xlabel('log10(Power)');
ylabel('CDF');
disp('statistics on power at 15-20 Hz');
fprintf('mean = %d \n RMS %d \n RMS/mean %d\n',MeanP15to20,sqrt(VarP15to20),sqrt(VarP15to20)/MeanP15to20);
