from filter2 import *
# Compute the alpha wave bandpower for an EEG signal stored in EEGData struct in .mat files
# Ken Hall 3/28/18

sample_rate = 1000 #Hz
load_file = '412_2.mat'
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

# Load EEG data from .mat file
data_object, labels = get_data(load_file, data_type_name)
# Shift each trial by offset to the left. Last trial will have mirrored end.
shifted_data_object = reframe(stimulus_delay, data_object, sample_rate)
# Apply a bandpass filter and concatenate all trials
filtered_data = bandpass_filt(sample_rate, low_cut, high_cut, shifted_data_object)
# Take the mean of filtered data by trial (now length = min(length(trials)))
mean_trial_data, slice_width = mean_slicer(shifted_data_object, filtered_data)
# Calculate the bandpower for alpha, beta, etc defined by [band_low, band_high]
alpha_power_data = windowed_bandpower(mean_trial_data, band_low, band_high, windowsize, windowstep, sample_rate, slice_width)

# Plot the result
matrix_plotter(alpha_power_data, "alpha bandpower")

sys.stdout.write('Hello World')
