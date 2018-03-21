%% Spectral Estimation for EEG
%  Bruce J. Gluckman\ - modified by Ken Hall 2/7/18
%  revised 2/2016 (original 1/26/09)
%
%  It is also helpful to read the Matlab help files for:
%     fft
%
%% make some raw data
%{
SPS = 256;      %data rate, samples-per-second
%
Tmax = 1;  % chose as 2^m
Time = 1/SPS:1/SPS:Tmax;
NPTS = length(Time);
F1 = 12;
F2 = 33;
twopi=2*pi;
Y1 = sin(twopi*F1*Time);
Y2 = 3 * sin(twopi*F2*Time);
Y3 = 4 * randn(size(Time));
Y4 = Y1 + Y2 + Y3 ;
%}


%% Import EEG Data
SPS = 1000;
Tmax = 10;
Time = 1/SPS:1/SPS:Tmax;
NPTS = length(Time);
disp(NPTS)

%% Set up filter
fMin = 2; 
fMax = 60;
Wn = [fMin  fMax]/(SPS/2);
% make an n=5th order butterworth bandpass filter
[bButter,aButter]=butter(5,Wn);
freqz(bButter,aButter,4*SPS/2,SPS);
title('Frequency response of the bandpass filter');

Y1_av = zeros(1,10000);
Y2_av = zeros(1,10000);
Y3_av = zeros(1,10000);
Y4_av = zeros(1,10000);
Y5_av = zeros(1,10000);
Y6_av = zeros(1,10000);
Y7_av = zeros(1,10000);
Y8_av = zeros(1,10000);

for i=1:1:10
Y1 = abs(Bruce_Data.AlphaBlockData{1,i}.PSUEEGData.Channels(1,1:10000));
Y2 = abs(Bruce_Data.AlphaBlockData{1,i}.PSUEEGData.Channels(2,1:10000));
Y3 = abs(Bruce_Data.AlphaBlockData{1,i}.PSUEEGData.Channels(3,1:10000));
Y4 = abs(Bruce_Data.AlphaBlockData{1,i}.PSUEEGData.Channels(4,1:10000));
Y5 = abs(Bruce_Data.AlphaBlockData{1,i}.PSUEEGData.Channels(5,1:10000));
Y6 = abs(Bruce_Data.AlphaBlockData{1,i}.PSUEEGData.Channels(6,1:10000));
Y7 = abs(Bruce_Data.AlphaBlockData{1,i}.PSUEEGData.Channels(7,1:10000));
Y8 = abs(Bruce_Data.AlphaBlockData{1,i}.PSUEEGData.Channels(8,1:10000));

Y1 = filtfilt(bButter,aButter,Y1);
Y2 = filtfilt(bButter,aButter,Y2);
Y3 = filtfilt(bButter,aButter,Y3);
Y4 = filtfilt(bButter,aButter,Y4);
Y5 = filtfilt(bButter,aButter,Y5);
Y6 = filtfilt(bButter,aButter,Y6);
Y7 = filtfilt(bButter,aButter,Y7);
Y8 = filtfilt(bButter,aButter,Y8);

Y1_av = Y1_av + Y1;
Y2_av = Y2_av + Y2;
Y3_av = Y3_av + Y3;
Y4_av = Y4_av + Y4;
Y5_av = Y5_av + Y5;
Y6_av = Y6_av + Y6;
Y7_av = Y7_av + Y7;
Y8_av = Y8_av + Y8;    
end

Y1 = Y1_av/10;
Y2 = Y2_av/10;
Y3 = Y3_av/10;
Y4 = Y4_av/10;
Y5 = Y5_av/10;
Y6 = Y6_av/10;
Y7 = Y7_av/10;
Y8 = Y8_av/10;

NPTS_Win = 10000;
TWin = NPTS_Win/SPS;
deltaF = 1/TWin;
Fn = SPS/2;
F = [0:deltaF:Fn , -Fn+deltaF:deltaF:-deltaF];
rangeF = (1:NPTS_Win);
p = bandpower(Y1,F(rangeF),[8,12],'psd');
disp(p)

figure;
fig1.a(1) = subplot(8,1,1);
plot(Time,Y1);
ylabel('Y1');
%
title('Raw EEG Data');
%
fig1.a(2) = subplot(8,1,2);
plot(Time,Y2);
ylabel('Y2');
fig1.a(3) = subplot(8,1,3);
plot(Time,Y3);
ylabel('Y3');
fig1.a(4) = subplot(8,1,4);
plot(Time,Y4);
ylabel('Y4');
fig1.a(5) = subplot(8,1,5);
plot(Time,Y5);
ylabel('Y5');
fig1.a(6) = subplot(8,1,6);
plot(Time,Y6);
ylabel('Y6');
fig1.a(7) = subplot(8,1,7);
plot(Time,Y7);
ylabel('Y7');
fig1.a(8) = subplot(8,1,8);
plot(Time,Y8);
ylabel('Y8');


%
xlabel('Time (s)');
linkaxes(fig1.a,'x');

%% Now compute the FFT
%
% note that NPTS = 2^n by construction, as long as we chose 
fY1 = fft(Y1,NPTS,2);
fY2 = fft(Y2,NPTS,2);
fY3 = fft(Y3,NPTS,2);
fY4 = fft(Y4,NPTS,2);
fY5 = fft(Y5,NPTS,2);
fY6 = fft(Y6,NPTS,2);
fY7 = fft(Y7,NPTS,2);
fY8 = fft(Y8,NPTS,2);
%
% now these fourier transforms are complex values, and scrambled in a way
% peculariar to the fft - specifically, the fft is done on blocks NPTS=2^n long
% with total window length TWindow = NPTS*dt = NPTS/SPS
% so the output has resolution deltaF=1/TWindow
% and max or minimal frequency at the Nyquist frequency Fn=SPS/2
% so the full range of values goes from -Fn<=F<=Fn
% Counting zero, this should lead to NPTS+1 values, but we only get out
% NPTS values, and in what order?
% It should be realized that the result for -Fn must equal that for Fn
% It is still scrambled:
% The first value is at the F=0, it progresses through Fn, then switches to
% -Fn/2+deltaF and goes up to -deltaF
%
deltaF = 1/Tmax;
Fn = SPS/2;
F = [0:deltaF:Fn , -Fn+deltaF:deltaF:-deltaF];
%disp(F)
% Now plot the magnitude of these spectra (recall they are complex
%
%norm = SPS/2;
norm = 1
figure;
fig2.a(1) = subplot(8,1,1);
plot(F,abs(fY1)/norm);
ylabel('abs(fY1)/f_N');
grid on;
%
title('Fourier Analysis');
%
fig2.a(2) = subplot(8,1,2);
plot(F,abs(fY2)/norm);
ylabel('abs(fY2)/f_N');
grid on;
fig2.a(3) = subplot(8,1,3);
plot(F,abs(fY3)/norm);
ylabel('abs(fY3)/f_N');
grid on;
fig2.a(4) = subplot(8,1,4);
plot(F,abs(fY4)/norm);
ylabel('abs(Y4)/f_N');
grid on;
fig2.a(5) = subplot(8,1,5);
plot(F,abs(fY5)/norm);
ylabel('abs(Y5)/f_N');
grid on;
fig2.a(6) = subplot(8,1,6);
plot(F,abs(fY6)/norm);
ylabel('abs(Y6)/f_N');
grid on;
fig2.a(7) = subplot(8,1,7);
plot(F,abs(fY7)/norm);
ylabel('abs(Y7)/f_N');
grid on;
fig2.a(8) = subplot(8,1,8);
plot(F,abs(fY8)/norm);
ylabel('abs(Y8)/f_N');
grid on;
%
xlabel('Frequency (Hz)');
linkaxes(fig2.a,'xy');
xlim([-100 100]);
%ylim([0 5]);
%
%% Better plotting - plot positive frequencies
%  notice that the negative amplitude is the same as the positive
%  amplitudes this follows from the data being REAL
%
%  plot positive frequencies
%
%  it is also better to plot the POWER, defined by the 
%  magnitude squared (actually gotten from multiplying by the complex
%  congugate
%
range = 1:length(F)/2+1;
pfY1 = fY1.*conj(fY1)/(norm*norm);
pfY2 = fY2.*conj(fY2)/(norm*norm);
pfY3 = fY3.*conj(fY3)/(norm*norm);
pfY4 = fY4.*conj(fY4)/(norm*norm);
pfY5 = fY5.*conj(fY5)/(norm*norm);
pfY6 = fY6.*conj(fY6)/(norm*norm);
pfY7 = fY7.*conj(fY7)/(norm*norm);
pfY8 = fY8.*conj(fY8)/(norm*norm);
figure;
fig3.a(1) = subplot(8,1,1);
plot(F(range),log10(pfY1(range)));
ylabel('logpower(fY1)/{f_N}^2');
%
title('Fourier Analysis - semilog');
%
fig3.a(2) = subplot(8,1,2);
plot(F(range),log10(pfY2(range)));
ylabel('logpower(fY2)/{f_N}^2');
fig3.a(3) = subplot(8,1,3);
plot(F(range),log10(pfY3(range)));
ylabel('logpower(fY3)/{f_N}^2');
fig3.a(4) = subplot(8,1,4);
plot(F(range),log10(pfY4(range)));
ylabel('logpower(fY4)/{f_N}^2');
fig3.a(5) = subplot(8,1,5);
plot(F(range),log10(pfY5(range)));
ylabel('logpower(fY5)/{f_N}^2');
fig3.a(6) = subplot(8,1,6);
plot(F(range),log10(pfY6(range)));
ylabel('logpower(fY6)/{f_N}^2');
fig3.a(7) = subplot(8,1,7);
plot(F(range),log10(pfY7(range)));
ylabel('logpower(fY7)/{f_N}^2');
fig3.a(8) = subplot(8,1,8);
plot(F(range),log10(pfY8(range)));
ylabel('logpower(fY8)/{f_N}^2');
%
xlabel('Frequency (Hz)');
linkaxes(fig3.a,'xy');
%ylim([0 .01]);
xlim([-100 100]);
%% Now vectorize to make much easier
%
Y = [Y1-mean(Y1); Y2-mean(Y2); Y3-mean(Y3); Y4-mean(Y4); Y5-mean(Y5); Y6-mean(Y6); Y7-mean(Y7); Y8-mean(Y8);];
%  Note that I've demeaned the signals!
%  ALSO NOTE - for a matrix, define which dimension you mean to transform
fY = fft(Y,NPTS,2);
pfY = fY.*conj(fY);
figure;
yLabels = {'logpower(fy1)','logpower(fy2)','logpower(fy3)','logpower(fy4)','logpower(fy5)','logpower(fy6)','logpower(fy7)','logpower(fy8)'};
% need to pick the minimum and maximum - excluding zero
pmin=min(min(pfY(:,2:NPTS)))/10;
pmax=100*max(max(pfY(:,2:NPTS)));
for i=1:8
    fig4.a(i) = subplot(8,1,i);
    if (i == 1)
        title('Fourier Analysis - vectorized');
    end
    semilogy(F(range),pfY(i,range));
    ylim([pmin pmax]);
    ylabel(yLabels(i));
end
xlabel('Frequency (Hz)');
linkaxes(fig4.a,'x');


%% Relation between signal variance and Fourier Power? 
var_Y = var(Y');
sum_pfY = sum(pfY');
figure; 
plot(var_Y,sum_pfY,'ro');
xlabel('variance(Y)');
ylabel('sum power');
title('variance and Fourier Power');
%% Total Variance = Total Power (with normalization)
%
% Find normalization
% use A/B finds least squares fit between them
%
slope = mean(sum_pfY/var_Y)
% what is this value?  square of NPTS!
plot(var_Y, var_Y, 'g--',...
    var_Y,sum_pfY/(NPTS*NPTS),'ro',...
    'MarkerSize',10);
xlabel('variance(Y)');
ylabel('sum power/(npts^2)');
title('variance and Fourier Power');

