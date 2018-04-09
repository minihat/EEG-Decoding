from filter import *
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
data_object = get_data(load_file, data_type_name)
# Shift each trial by offset to the left. Last trial will have mirrored end.
shifted_data_object = reframe(stimulus_delay, data_object, sample_rate)
# Apply a bandpass filter and concatenate all trials
filtered_data = bandpass_filt(sample_rate, low_cut, high_cut, shifted_data_object)
# Remove channels listed in garbage_channels
good_channels = channel_remover(filtered_data, garbage_channels)

print("DIM good_channels: " + str(len(good_channels)) + " by " + str(len(good_channels[1])))
# Take the mean of filtered data by trial (now length = min(length(trials)))
#mean_trial_data, slice_width = mean_slicer(shifted_data_object, filtered_data)
# Calculate the bandpower for alpha, beta, etc defined by [band_low, band_high]
#alpha_power_data = windowed_bandpower(mean_trial_data, band_low, band_high, windowsize, windowstep, sample_rate, slice_width)

# Plot the result
#matrix_plotter(alpha_power_data, "alpha bandpower")

sys.stdout.write('Hello World')
