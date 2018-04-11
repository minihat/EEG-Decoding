from filter import *
from CSP import covarianceMatrix as covM
from CSP import spatialFilter
# Compute the CSP matrix given a .mat file with L/R tap EEG data
# Ken Hall 3/28/18

sample_rate = 1000 #Hz
load_file = './BCI2018_Lab0222/AcquisitionCode/BCI_ERDERS_Tap_180215Third.mat'
data_type_name = 'ERDTrialData'
#load_file = 'feb_1_data.mat'
# Reframe data due to taste
stimulus_delay = 0 #Seconds
# Noise bandpass filter parameters
low_cut = 2 #Hz
high_cut = 60 #Hz
# Parameters for calculation of bandpower
band_low = 7 #Hz
band_high = 14 #Hz
windowsize = 3 #seconds
windowstep = .2 #seconds
# A list of channels not to consider in calculations
garbage_channels = [6,7]

# Load EEG data from .mat file
data_object, trial_type = get_data(load_file, data_type_name)
# Shift each trial by offset to the left. Last trial will have mirrored end.
shifted_data_object = reframe(stimulus_delay, data_object, sample_rate)
# Apply a bandpass filter and concatenate all trials
filtered_data = bandpass_filt(sample_rate, low_cut, high_cut, shifted_data_object)
# Remove channels listed in garbage_channels
good_channels = channel_remover(filtered_data, garbage_channels)
# Restructure the data into from shape(channels,time) -> shape(trials,channels,time)
filtered_good_trials, slice_width = trial_slicer(shifted_data_object, good_channels)
# Get subsets of the data at timewindows for A, B, and C type data
at_rest_subset = data_subset(filtered_good_trials, [0,3.5], sample_rate)
action_subset = data_subset(filtered_good_trials, [3.5,8.5], sample_rate)
# Separate trials by label from trial_type variable returned by get_data
A, B = trial_type_separator(action_subset, trial_type)
###########################################################################
#Compute mean covariance matrices
## For type A data
cov_A = covM(A[0])/len(A)
for trial_num in range(1,len(A)):
    cov_A += covM(A[trial_num])/len(A)
## For type B data
cov_B = covM(B[0])/len(B)
for trial_num in range(1,len(B)):
    cov_B += covM(B[trial_num])/len(B)
## FOr type C data
cov_C = covM(at_rest_subset[0])/len(at_rest_subset)
for trial_num in range(1,len(at_rest_subset)):
    cov_C += covM(at_rest_subset[trial_num])/len(at_rest_subset)
# Display the covariance matrices
print("Covariance Matrices:")
print(cov_A, cov_B, cov_C)
# Compute the spatial filters from above covariance matrices
sfa = spatialFilter(cov_A, cov_C)
sfa2 = spatialFilter(cov_C, cov_A)
sfb = spatialFilter(cov_B, cov_C)
sfb2 = spatialFilter(cov_C, cov_B)
print("Spatial Filters:")
print(sfa, sfa2, sfb, sfb2)

# Apply the CSP filters to trial data
csp_a_filtered = apply_CSP_filter(sfa, filtered_good_trials[4]) # fill in trial number

# Plot some of the CSP filtered channels
#channel_plotter(csp_a_filtered, [1,6], "CSP A FILTERED", sample_rate)
# Compute the average of L/R channels, and plot
csp_vec = []
csp_vec.append(mean_of_channels(csp_a_filtered, [1,2,3])) # right channels
csp_vec.append(mean_of_channels(csp_a_filtered, [4,5,6])) # left channels

#channel_plotter(csp_vec, [1,2], "CSP filtered mean channels right (1) and left (2)", sample_rate)
###########################################################################
# Try Bruce's prefabbed transformation matrices
Wb1 = [[0,1,0,0,0,0],[0,0,0,0,1,0]]
Wb2 = [[-1,2,-1,0,0,0],[0,0,0,-1,2,-1]]

Wb1_pred = []
Wb2_pred = []
csp_a_pred = []
for trial in range(len(filtered_good_trials)):
    csp_a = apply_CSP_filter(sfa, filtered_good_trials[trial])

    csp_Wb1 = apply_CSP_filter(Wb1, filtered_good_trials[trial])
    #channel_plotter(csp_Wb1, [1,2], "CSP with Wb1 Filter", sample_rate)

    csp_Wb2 = apply_CSP_filter(Wb2, filtered_good_trials[trial])
    #channel_plotter(csp_Wb2, [1,2], "CSP with Wb2 Filter", sample_rate)

    var_csp_a = [np.var(csp_a[0]), np.var(csp_a[1])]
    var_Wb1 = [np.var(csp_Wb1[0]), np.var(csp_Wb1[1])]
    var_Wb2 = [np.var(csp_Wb2[0]), np.var(csp_Wb2[1])]
    if var_csp_a[0] > var_csp_a[1]:
        csp_a_pred.append(0)
    else:
        csp_a_pred.append(1)
    if var_Wb1[0] > var_Wb1[1]:
        Wb1_pred.append(0)
    else:
        Wb1_pred.append(1)
    if var_Wb2[0] > var_Wb2[1]:
        Wb2_pred.append(0)
    else:
        Wb2_pred.append(1)

def accuracy_report(correct_trial_types, pred_trial_types):
    wrong_pred = 0
    for i in range(len(correct_trial_types)):
        wrong_pred += abs(correct_trial_types[i] - pred_trial_types[i])
    wrong_ratio = float(wrong_pred) / float(len(correct_trial_types))
    accuracy = 100 - (100 * wrong_ratio)
    return accuracy

csp_a_acc = accuracy_report(trial_type, csp_a_pred)
Wb1_acc = accuracy_report(trial_type, Wb1_pred)
Wb2_acc = accuracy_report(trial_type, Wb2_pred)

print("Correct trial types: ")
print(trial_type)
print("cspA predicted trial types: ")
print(csp_a_pred)
print("Accuracy: ", csp_a_acc)
print("Wb1 Predicted trial types: ")
print(Wb1_pred)
print("Accuracy: ", Wb1_acc)
print("Wb2 Predicted trial types: ")
print(Wb2_pred)
print("Accuracy: ", Wb2_acc)



sys.stdout.write('Hello World')
