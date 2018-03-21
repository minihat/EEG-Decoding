%% Multitaper Harmonic Analysis 
%
%  Bruce J. Gluckman
%  revised 2/2016
%
%  Overall objective is to be able to apply the MT spectral estimates
%  many times i.e. to generate spectrograms, to identify lines in the
%  spectra with particular resolution, and their amplitudes
%
%  First set up the data specs
%
%  Acquisition rate (SPS)
SPS = 256;
%  window size
NPTS = 1024;
%  overlap
Step = 256;
%
%% Now create the data
%
% here create some data
% We'll use a mixture of band limited noise plus 
% two sinusoids.  The lower frequency sinusoid is
% modulated in amplitude on a much longer time scale
%
% note that sin(w1*t)sin(wmod*t)=0.5*(cos(w1-wmod)-cos(w1+wmod)).
% 
% so we expect to broaden the lower peak into two peaks separated
% by 2*Fmod
%
Tmax = 800;  
Time = 1/SPS:1/SPS:Tmax;
totalPts = length(Time);
F1 = 10;
F2 = 25;
Fmod = 0.01;
twopi=2*pi;
fMin = 2; 
fMax = 60;
Wn = [fMin  fMax]/(SPS/2);
% make an n=5th order butterworth bandpass filter
[bButter,aButter]=butter(5,Wn);
Y = 5*sin(twopi*Fmod*Time).*sin(twopi*F1*Time)+sin(twopi*F2*Time)+randn(size(Time));
Y = filtfilt(bButter,aButter,Y);
%
StartIndexes = 1:Step:length(Y)-NPTS;
NWindows = length(StartIndexes);
% note that these are the starting indexes of the windows.
%
% We can denote the Times of the windows as their start or end or midpoints
% times
%
WindowTimes = Time(StartIndexes);
%
% estimate the power in the modulated frequency
F1Power = zeros(size(WindowTimes));
F2Power = zeros(size(WindowTimes));
TotPower = zeros(size(WindowTimes));
Range0 = 0:NPTS-1;
for i=1:NWindows
    timesi = Time(StartIndexes(i)+Range0);
    cows = 5*sin(twopi*Fmod*timesi).*sin(twopi*F1*timesi);
    F1Power(i) = sum(cows.*cows);
    cows = sin(twopi*F2*timesi);
    F2Power(i) = sum(cows.*cows);
    cows = Y(StartIndexes(i)+Range0);
    TotPower(i) = sum(cows.*cows);
end
meanF2LineIdeal = mean(F2Power);
% now set up space for the results
%
NPTS_by_2 = NPTS/2;
NPTS_by_2_Plus_1 = NPTS_by_2+1;
Fstatgraph = zeros([NWindows NPTS_by_2_Plus_1]);
MT_Spectrogram = zeros([NWindows NPTS_by_2_Plus_1]);
Frequencies = 0:SPS/NPTS:SPS/2;
%
% space for the Hanning windowed spectrogram
Han_Spectrogram = zeros([NWindows NPTS_by_2_Plus_1]);

%% Compute the regular Hanning windowed spectrogram
%
%  Note that this is a single tapered spectral estimator
%  The taper (equal to the first of the Slepian tapers used below) reduces
%  the bias due spectral leakage into nearby freqeuency bins, and also
%  reduces errors by making the ends of the window equal to zero
%
Range0 = 0:NPTS-1;
hWin = hann(NPTS,'periodic')';
for iWin = 1:NWindows
    iStart=StartIndexes(iWin);
    % s = sprintf('FFT processed for window %g \r',iWin);disp(s);
     % get the data
    Range = iStart+Range0;
    phY = fft(Y(Range).*hWin,NPTS);
    sphY = phY.*conj(phY);
    Han_Spectrogram(iWin,:) = sphY(1:NPTS_by_2_Plus_1)/NPTS;
end
figure;
surf(WindowTimes,Frequencies,10*log10(abs(Han_Spectrogram')),'EdgeColor','none');
axis xy; axis tight; colormap(jet); view(0,90);
title('Spectrogram of with Hanning Windowed Data');
ylabel('Frequency');
xlabel('Time');
%% plot Hanning spectra and line stats
% 
% NOTE that we use a factor of 2 between the spectrograms and the power
% because we've thrown away the data at negative frequencies.
%
figure;
subplot(3,1,1);
IF1=F1*NPTS/SPS+1;
IF2=F2*NPTS/SPS+1;
%
plot(WindowTimes,2*Han_Spectrogram(:,IF1),'m',WindowTimes,F1Power,'g');
title('F1');
xlabel('Time (s)');
ylabel('Power');
legend('Spectral Power at F1','Power at F1');
%
subplot(3,1,2);
plot(WindowTimes,2*Han_Spectrogram(:,IF2),'m',WindowTimes,F2Power,'g');
title('F2');
xlabel('Time');
ylabel('Power');
legend('Spectral Power at F2','Power at F2');
%
subplot(3,1,3);
sphPower = 2*sum(Han_Spectrogram,2);
plot(WindowTimes,sphPower,'m',WindowTimes,TotPower,'g');
title('Total Power');
xlabel('Time');
ylabel('Power');
legend('Spectral Power','Total Power');
%
% now look at the statistics of the line at F2
stdF2hs=std(2*Han_Spectrogram(:,IF2));
meanF2hs=mean(2*Han_Spectrogram(:,IF2));
%
message = sprintf(...
    ['Single Taper (Hanning) values\n'...
    'mean line power and its STD normalized by its ideal value is\n'...
    'Mean(h_PowerLineF2)/PowerLineF2 = %g \n'...
    'std(h_PowerLine2)/PowerLineF2   = %g \n'...
    'std(h_PowerLine2)/Mean(h_PowerLineF2)   = %g \n'...
    '\nnote that this is probably because of the background noise\n'], ...
    meanF2hs/meanF2LineIdeal, stdF2hs/meanF2LineIdeal,stdF2hs/meanF2hs);
disp(message);
%
%
%% Now set up the repeatedly used MT pieces
%
mt.pval = 0.995;
mt.nw = 4;
mt.nk = round(2*mt.nw);
[mt.e,mt.v] = dpss(NPTS,mt.nw,mt.nk);
mt.pe = fft(mt.e,NPTS);
mt.spe0=mt.pe(1,:)*conj(mt.pe(1,:)');
mt.SNR_Thresh = finv(mt.pval,2,2*(mt.nk-1));
convWid = 2*mt.nw;
mt.ConvIndex = -convWid:convWid;
mt.lenConv = length(mt.ConvIndex);
mt.ConvLU = [NPTS-convWid+1:NPTS 1:convWid+1];
if mt.lenConv~=length(mt.ConvLU)
    disp('ERROR IN convolution LU');
end
mt.peSub = mt.pe(mt.ConvLU,:);
mt.SNR_Norm = ((mt.nk-1)/(NPTS))*mt.spe0;
% check that we've hit the main concentration of the taper
% conc = sum(mt.pe(mt.ConvLU,:).*conj(mt.pe(mt.ConvLU,:)),1)/NPTS;
%% Computute MT Spectrogram
%
Range0 = 0:NPTS-1;
for iWin = 1:NWindows
    iStart=StartIndexes(iWin);
    %  s = sprintf('FFT processed for window %g \r',iWin);disp(s);
     % get the data
    Range = iStart+Range0;
    Ynow = Y(Range);
    % compute the multiplication of the signal by the taper
    eY = mt.e;
    for i=1:mt.nk
        eY(:,i) = mt.e(:,i).*Ynow';
    end
    % now take FT
    peY = fft(eY,NPTS);
    % compute the first moment average to get the putative lines
    temp = peY;
    for i=1:mt.nk
        temp(:,i) = peY(:,i)*conj(mt.pe(1,i));
    end
    peYm1 = sum(temp,2)/mt.spe0;
    seYm1 = NPTS*NPTS*peYm1.*conj(peYm1);
    seYm1 = seYm1';
    % estimate the approximate residual spectral power in the noise part
    % 
    for i=1:mt.nk
        temp(:,i) = peY(:,i)-mt.pe(1,i)*peYm1;
    end
    seYresidual = NPTS*sum(temp.*conj(temp),2 )';
    % Compute the SNR
    mtSNR = mt.SNR_Norm*seYm1./seYresidual;
    SigIndexes=find(mtSNR>=mt.SNR_Thresh);
    temp = peY;
    if ~isempty(SigIndexes)
        for i=SigIndexes
            lInd = mod(i+mt.ConvIndex-1,NPTS)+1;
            temp(lInd,:) = temp(lInd,:) - peYm1(i)*mt.peSub;
        end
    end
    seYresidual = NPTS*mean(temp.*conj(temp),2)';
    seHarmFull = seYresidual;
    if ~isempty(SigIndexes)
        for i=SigIndexes
            seHarmFull(i) = seHarmFull(i) + seYm1(i);
        end
    end
    % now transfer to the save matrix
    Fstatgraph(iWin,:) =  mtSNR(1:NPTS_by_2_Plus_1);
    MT_Spectrogram(iWin,:) = seHarmFull(1:NPTS_by_2_Plus_1)/NPTS;
end
%% now plot multitaper spectrogram
%
% note that we plot these tall because otherwise the lines get lost
figure;
subplot(1,3,1);
%surf(WindowTimes,Frequencies,10*log10(abs(MT_Spectrogram')),'EdgeColor','none');
imagesc(WindowTimes,Frequencies,10*log10(abs(MT_Spectrogram')));
axis xy; axis tight; colormap(jet); 
xlabel('Time (s)');
ylabel('Frequency (Hz)');
subplot(1,3,2);
%surf(WindowTimes,Frequencies,log10(Fstatgraph'+.5),'EdgeColor','none');
imagesc(WindowTimes,Frequencies,log10(Fstatgraph'+.5));
title('log10(SNR+0.5)');
axis xy; axis tight; colormap(jet); 
ylim([0 60]);
xlabel('Time(s)');
ylabel('Frequency (Hz)');
subplot(1,3,3);
FSiggraph = 1.0*(Fstatgraph<mt.SNR_Thresh);  % this makes significant lines BLACK
imagesc(WindowTimes,Frequencies,FSiggraph');
title('Significant SNRs');
axis xy; axis tight; %colormap(gray); view(0,90);
xlabel('Time(s)');
ylabel('Frequency (Hz)');
ylim([5 30]);
% now blow it up a bit
figure;
subplot(1,3,1);
%surf(WindowTimes,Frequencies,10*log10(abs(MT_Spectrogram')),'EdgeColor','none');
imagesc(WindowTimes,Frequencies,10*log10(abs(MT_Spectrogram')));
axis xy; axis tight; colormap(jet); 
xlabel('Time (s)');
ylabel('Frequency (Hz)');
xlim([100 200]);
subplot(1,3,2);
%surf(WindowTimes,Frequencies,log10(Fstatgraph'+.5),'EdgeColor','none');
imagesc(WindowTimes,Frequencies,log10(Fstatgraph'+.5));
title('log10(SNR+0.5)');
axis xy; axis tight; colormap(jet); 
ylim([5 30]);
xlabel('Time(s)');
ylabel('Frequency (Hz)');
xlim([100 200]);
subplot(1,3,3);
FSiggraph = 1.0*(Fstatgraph<mt.SNR_Thresh);  % this makes significant lines BLACK
imagesc(WindowTimes,Frequencies,FSiggraph');
title('Significant SNRs');
axis xy; axis tight; %colormap(gray); view(0,90);
xlabel('Time(s)');
ylabel('Frequency (Hz)');
xlim([100 200]);
ylim([5 30]);

%% plot multitaper Spectra and statistics at lines
% 
% NOTE that we use a factor of 2 between the spectrograms and the power
% because we've thrown away the data at negative frequencies.
%
figure;
subplot(3,2,1);
IF1=F1*NPTS/SPS+1;
plot(WindowTimes,2*MT_Spectrogram(:,IF1),'m',WindowTimes,F1Power,'g');
%title('F1');
xlabel('Time (s)');
ylabel('Power at F1');
legend('MT Line','Power','Location','East');
%
subplot(3,2,3);
plot(WindowTimes,Fstatgraph(:,IF1));
xlabel('Time');
ylabel('SNR at F1');
%
subplot(3,2,2);
IF2=F2*NPTS/SPS+1;
plot(WindowTimes,2*MT_Spectrogram(:,IF2),'m',WindowTimes,F2Power,'g');
title('F2');
xlabel('Time');
ylabel('Power at F2');
legend('MT Line','Power','Location','East');
%
subplot(3,2,4);
plot(WindowTimes,Fstatgraph(:,IF2));
xlabel('Time');
ylabel('SNR at F2');

subplot(3,1,3);
spmtPower = 2*sum(MT_Spectrogram,2);
plot(WindowTimes,spmtPower,'m',WindowTimes,TotPower,'g');
title('Total Power');
xlabel('Time');
ylabel('Power');
legend('MT Spectral Power','Total Power');
%
stdF2Line=std(2*MT_Spectrogram(:,IF2));
meanF2Line=mean(2*MT_Spectrogram(:,IF2));
meanF2LineIdeal = mean(F2Power);
%
% now look at the statistics of the line extraction variation
message = sprintf(...
    ['mean line power and its STD normalized by its ideal value is\n'...
    'Mean(MT_PowerLineF2)/PowerLineF2 = %g \n'...
    'std(MT_PowerLine2)/PowerLineF2   = %g \n'...
    '\nnote that this is probably because of the background noise\n'], ...
    meanF2Line/meanF2LineIdeal, stdF2Line/meanF2LineIdeal);
disp(message);
%

%% Now look at statistics 
%
% presumably, the STD of the multi-taper spectral estimate should be lower 
% by a factor of sqrt(nk) from that of the single taper Hanning
% 
% But lets test that 
%
% First remove the normalization difference so that they both 
% have exactly the same total power:
%
MeanMTS = mean(MT_Spectrogram,1);
STD_MTS  = std(MT_Spectrogram,0,1);
MeanHan = mean(Han_Spectrogram,1);
STD_Han  = std(Han_Spectrogram,0,1);
% renormalize the Hanning spectrographs
NormHan = sum(MeanMTS)/sum(MeanHan);
%
message = sprintf('Hanning underestimates power by factor of %g',NormHan);
disp(message);
%
MeanHan = NormHan*MeanHan;
STD_Han  = NormHan*STD_Han;
%
OneOne = 10.^(log10(min(STD_MTS)):log10(max(STD_MTS)));
%
figure;
subplot(2,1,1);
semilogy(Frequencies,MeanMTS,'m',Frequencies,MeanHan,'b');
title('Comparison of normalized average Hanning and MT Spectra');
xlabel('Frequency');
ylabel('PSD');
legend('MT spectra','Hanning spectra');
subplot(2,1,2);
semilogy(Frequencies,MeanMTS,'m',Frequencies,MeanHan,'b');
title('Comparison of normalized average Hanning and MT Spectra');
xlabel('Frequency');
ylabel('PSD');
ylim([1e-2 1e7]);
xlim([0 30]);
message = sprintf(['Note that the MT spectral estimate has small upward slopes\n',...
    'near in frequency to the modulated frequency. This is due to the modulation']) ;
disp(message);
%% Now look at STD of Spectral Estimates 
%
figure;
range=find( (Frequencies>fMin).*(Frequencies<fMax));
range2 = [IF1+mt.ConvIndex IF2+mt.ConvIndex];
loglog(MeanMTS(range),STD_MTS(range),'r+', ...
    MeanMTS(range2),STD_MTS(range2),'bo', ...
    MeanHan(range),STD_Han(range),'m+', ...
    MeanHan(range2),STD_Han(range2),'go',...
    OneOne,OneOne,...
    OneOne,OneOne/sqrt(mt.nk));
title('Comparison of Hanning and MT Spectra Variances excluding lines');
xlabel('Mean(PSD)');
ylabel('std(PSD)');
axis([1e-1 1e1 1e-1 1e1]);
legend('MT spectra no line','MT spectra near line',...
    'Hanning spectra no line','Hanning spectra near line',...
    'I','PSD/sqrt(nk)','Location','northwest');
%% Now Look at STD of Hanning vs STD of MT estimator
figure;
loglog(STD_MTS,STD_Han,'r+',OneOne,OneOne,OneOne,sqrt(mt.nk)*OneOne,'g');
title('Comparison of Hanning and MT Spectra Statistics');
xlabel('std(PSD MT)');
ylabel('std(PSD Hanning)');
legend('PSD','I','slope sqrt(nk)','Location','northwest');
axis([1e-2 1e2 1e-2 1e2]);
%% Now look at the SNR distributions near and away from the lines
%
%
range  = find( (Frequencies>30).*(Frequencies<fMax));
range2 = IF2;
%range2 = [IF2+mt.ConvIndex];
tmp = Fstatgraph(:,range);
[cdfSNR_Noise,SNR_Noise] = ecdf(tmp(:));
tmp = Fstatgraph(:,range2);
[cdfSNR_F2,SNR_F2] = ecdf(tmp(:));
figure;
SNRrange = 10.^(log10(min([SNR_F2' SNR_Noise'])):.1:log10((max([SNR_F2' SNR_Noise']))));
loglog(SNR_Noise,cdfSNR_Noise,'r',...
    SNR_F2,cdfSNR_F2,'g',...
    SNRrange,fcdf(SNRrange,2,2*(mt.nk-1)),'b');
xlabel('SNR');
ylabel('CDF');
title({'cumulative distribution functions of SNR',...
    'and ideal F(2,2(nk-1))'});
legend('cdf(SNR_{Noise})','cdf(SNR_{Line})','cdf(F(2,2(nk-1)))','Location','northwest');
ylim([1e-4 2]);