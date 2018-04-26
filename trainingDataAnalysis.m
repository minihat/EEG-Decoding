%% Procedure: run training session, send data to this analysis program which will 
%% output the left and right transformation matrices. Then run the game aquisition 
%% program which will classify each second of data. 

clear, clc
Data1 = load('gluckmanData.mat');
Data = Data1.Data;
% clear Data1;
Data.ERDTrialData = transpose(Data.ERDTrialData);
n = 0;

%% Step 1 ------------------
trial_type = Data.TrialType;
time_index = zeros(4, 30);
for i = 1:30
    time_index(1, i) = Data.ERDTrialData(i).TimePoints(1);
    time_index(2, i) = Data.ERDTrialData(i).TimePoints(2);
    time_index(3, i) = Data.ERDTrialData(i).TimePoints(3); 
    time_index(4, i) = Data.ERDTrialData(i).TimePoints(4);
end

trial_info = [trial_type;time_index];

clear time_index
clear trial_type
clear i

%trial_info is a 5x30 matrix where the column indicates data for that
%trial, and row indicates the following information: row1 = trial type,
%row2 = time of relaxation presentation, row3 = arrow presentation, row 4 =
%tap request, and row 5 = end of trial

%% Step 2 -------------------- detect artifacts and remove them
%% Step 3 - Filters

%eeg(i).a is a structure with 30 data elements each containing data from 6
%relevant channels
for i = 1:30
    eeg(i).a = Data.ERDTrialData(i).PSUEEG.Channels([1, 2, 3, 4, 5], :);
    no_csp(i).a = eeg(i).a([2, 5], :);
end


%Filter sequence start
cutoff = [6 15];
state = [];
fs = 1000;
[num,den] = butter(2 ,cutoff*2/fs, 'bandpass');
[garbage, state] = filter(num, den, fliplr(eeg(1).a), state, 2);
for i = 1:30
    [eeg(i).a, state] = filter(num, den, eeg(i).a, state, 2);
end
%Filter sequence end

clear garbage
clear num
clear den
clear cutoff
clear state
clear i
clear action
%% Part 5 -- Compute bandpower on segment for all time for all channels 
%% CSP Math -- average covariance for 2 segments covc and covab. Pass these into series of manipulations until W is calculated. Then apply W to all time. 
covc = zeros(5,5);
cov_a = zeros(5,5);
cov_b = zeros(5,5);

left_count =0;
right_count = 0;

for i = 1:30
    trial = trial_info(1, i);
    covc = covc + eeg(i).a(:,[trial_info(2,i) - 2000:trial_info(2,i)])*eeg(i).a(:,[trial_info(2,i) - 2000:trial_info(2,i)])';
    if trial == 0
        cov_a = cov_a + eeg(i).a(:,[trial_info(3,i):5000 + trial_info(3,i)])*eeg(i).a(:,[trial_info(3,i):5000 + trial_info(3,i)])';
        left_count = left_count + 1;
    else
        cov_b = cov_b + eeg(i).a(:,[trial_info(3,i):5000 + trial_info(3,i)])*eeg(i).a(:,[trial_info(3,i):5000 + trial_info(3,i)])';
        right_count = right_count + 1;
    end
end

covc = covc./ (left_count + right_count);
cov_a = cov_a./ (left_count);
cov_b = cov_b./(right_count);

W_pre = CSP_From_Cov(covc, cov_a);
W_left = W_pre([1,5],:);
W_pre = CSP_From_Cov(covc, cov_b);
W_right = W_pre([1,5],:);

save('transformLeft.mat', 'W_left')
save('transformRight.mat', 'W_right')

% Z_right and Z_left are the transformed channels
for i = 1:30
Z(i).left = W_left*eeg(i).a;
Z(i).right = W_right*eeg(i).a;
end


j = 1;
n = n + 1;
figure(n)
subplot(2,1,1)
    plot((1:size(Z(j).left, 2)), Z(j).left(1,:));
    hold on
    plot((1:size(Z(j).right, 2)), Z(j).right(2,:));
    hold off
    title('Transformed Left Type')
    
 subplot(2,1,2)
    plot((1:size(Z(j).left,2)), Z(j).left(2,:));
    hold on
    plot((1:size(Z(j).right,2)), Z(j).right(1,:));
    hold off
    title('Transformed Right Type')
    
clear j
clear i
clear W_pre
%% Part 6 bandpower  -- goal is to plot bandpower for 2 second overlapping intervals from t - 4:t+7
band_power_left = zeros(2, 6, 30);
band_power_right = zeros(2, 6, 30);
segment = [-3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7];
for i = 1:29 
   action = trial_info(3,i);
   for  j = 1:2
       a = Z(i).left(:,:);
       b = Z(i+1).left(:,:);
       dataLeft = [a b];
       a = Z(i).right(:,:);
       b = Z(i+1).right(:,:);
       dataRight = [a b];
       for k = 1:9
            band_power_left(j, k, i) = mean(dataLeft(j,[action + segment(k)*1000:action + (segment(k)+1)*1000]).^2);
            band_power_right(j, k, i) = mean(dataRight(j, [action + segment(k)*1000:action + (segment(k)+1)*1000]).^2);
       end
   end
end

mBP_LL = 0; 
mBP_LR = 0;
mBP_RR = 0;
mBP_RL = 0;
for i = 1:30
    if trial_info(1, i) == 0
       mBP_LL = mBP_LL + mean(band_power_left(1, :, i));
       mBP_RL = mBP_RL + mean(band_power_left(2, :, i));
    else 
        mBP_LR =  mBP_LR + mean(band_power_left(1, :, i));
        mBP_RR = mBP_RR + mean(band_power_left(2, :, i));
    end
end
mBP_LL = mBP_LL./15;
mBP_LR = mBP_LR./15;
mBP_RR = mBP_RR./15;
mBP_RL = mBP_RL./15;

left = find(trial_info(1,:), 30); 
right = find(trial_info(1,:)<1, 30);
%%
n = n + 1;
fig(n).h = figure(n);
fig(n).a(1) = subplot(2,2,1)
    semilogy(1:9,squeeze(band_power_left(1,:,left)),'r*',...
             1:9, mean(band_power_left(1,:,left), 3), 'b*');
    title('Left Type Trial, Left Type Channel')
fig(n).a(2) = subplot(2,2,3)
    semilogy(1:9,squeeze(band_power_left(2,:, left)), 'r*',...
             1:9, mean(band_power_left(2,:,left), 3), 'b*');
    title('Left Type Trial, Right Type Behavior')
linkaxes(fig(n).a(:),'xy');

subplot(2,2,2)
    semilogy(1:9,squeeze(band_power_left(1,:,right)),'r*',...
             1:9, mean(band_power_left(1,:,right), 3), 'b*');
    title('Right Type Trial, Left Type Channel')
subplot(2,2,4)
    semilogy(1:9,squeeze(band_power_left(2,:,right)), 'r*',...
             1:9, mean(band_power_left(2,:,right), 3), 'b*');
    title('Right Type Trial, Right Type Behavior')
%%
n = n + 1;
fig(n).h = figure(n);
fig(n).a(1) = subplot(2,2,1)
    semilogy(1:9,squeeze(band_power_right(1,:,left)),'r*',...
             1:9, mean(band_power_right(1,:,left), 3), 'b*');
    title('Left Type Trial, Left Type Channel')
fig(n).a(2) = subplot(2,2,3)
    semilogy(1:9,squeeze(band_power_right(2,:, left)), 'r*',...
             1:9, mean(band_power_right(2,:,left), 3), 'b*');
    title('Left Type Trial, Right Type Behavior')
linkaxes(fig(n).a(:),'xy');

subplot(2,2,2)
    semilogy(1:9,squeeze(band_power_right(1,:,right)),'r*',...
             1:9, mean(band_power_right(1,:,right), 3), 'b*');
    title('Right Type Trial, Left Type Channel')
subplot(2,2,4)
    semilogy(1:9,squeeze(band_power_right(2,:,right)), 'r*',...
             1:9, mean(band_power_right(2,:,right), 3), 'b*');
    title('Right Type Trial, Right Type Behavior')

%%   
clear a 
clear b
clear data
clear i
clear j
clear k
clear action
clear segment
clear data_right
clear data_left

%% check

x = zeros(1,30);
y = zeros(1,30);
z = zeros(1,30);
for i = 1:30
    x(i) = Z(i).left(1,:)*(Z(i).left(1,:))';
    y(i) = Z(i).left(2,:)*(Z(i).left(2,:))';
    z(i) = x(i)/y(i);
    if z(i) >= 3.5
            disp([num2str(i), ' Left ']);  %move left
    elseif z(i) >3.3 && z(i) <3.5
            disp([num2str(i), ' None']);    %none
    elseif z(i) <= 3.3
             disp([num2str(i), ' Right']);    %move right
    end
end



