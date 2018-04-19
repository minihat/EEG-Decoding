%% Pass to this function the unfiltered, uncropped signal with all 8 channels after the trial. 
%It should output the trial type!!!
function type = classify_trial(eeg_uf)

%     cow = load('transformLeft.mat');
%     W = cow.W_left

    W = ones(2, 16);

    fs=1000;
    cutoff = [6 15];
    [num,den] = butter(2,cutoff*2/fs, 'bandpass');
    eeg = filtfilt(num, den, transpose(eeg_uf));

    size(eeg)
    Z = W*transpose(eeg);
    
    threshold = 0;
    theta = 1;
    type = sign(theta*log10(var(transpose(Z(:,1))) + threshold));

    if type == 0
        type = -1;
    end
    

   
end


