import sys
import scipy.io as spio
import numpy as np
import matplotlib.pyplot as plt
import scipy
from scipy.signal import freqz
from scipy.signal import butter, lfilter, lfilter_zi

from scipy.signal import filtfilt

# Load the mat file with data in struct format
def loadmat(filename):
    '''
    this function should be called instead of direct spio.loadmat
    as it cures the problem of not properly recovering python dictionaries
    from mat files. It calls the function check keys to cure all entries
    which are still mat-objects
    '''
    data = spio.loadmat(filename, struct_as_record=False, squeeze_me=True)
    return _check_keys(data)

def _check_keys(dict):
    '''
    checks if entries in dictionary are mat-objects. If yes
    todict is called to change them to nested dictionaries
    '''
    for key in dict:
        if isinstance(dict[key], spio.matlab.mio5_params.mat_struct):
            dict[key] = _todict(dict[key])
    return dict

def _todict(matobj):
    '''
    A recursive function which constructs from matobjects nested dictionaries
    '''
    dict = {}
    for strg in matobj._fieldnames:
        elem = matobj.__dict__[strg]
        if isinstance(elem, spio.matlab.mio5_params.mat_struct):
            dict[strg] = _todict(elem)
        else:
            dict[strg] = elem
    return dict


def get_data(load_file, data_type_name):
    mat = loadmat(load_file)
    # channel_data will be a list. Every element of the list
    #  is one trial (an ndarray) containing 8 channels by n number of datapoints
    # To get a single decimal datapoint: channel_data[trial][channel][timestep]
    channel_data = []
    for i in range(len(mat['Data'][data_type_name])):
        data = _todict(mat['Data'][data_type_name][i])
        channel_data.append(data['PSUEEGData']['Channels'])
    try:
        trial_type = list(mat['Data']['TrialType'])
    except:
        print("No trial type data found. Returning empty vector for trial_type.")
        trial_type = []
    return channel_data, trial_type

# Shift stimulus to t = 0 for each trial, and reflect the last bit of the final trial to keep lengths nearly equal
def reframe(stimulus_delay, data_object, sample_rate):
    reformatted_data_object = [[[] for i in range(len(data_object[0]))] for i in range(len(data_object))]
    print("Length of reformmatted_data_object: " + str(len(reformatted_data_object)))
    print("Reformatting data to adjust for trail start offset.")
    for trial in range(len(data_object)-1):
        for channel in range(len(data_object[0])):
            print("Writing trial " + str(trial+1) + " channel " + str(channel+1))
            #test = list(data_object[trial][channel][int(stimulus_delay * sample_rate):]) + list(data_object[trial+1][channel][:int(stimulus_delay * sample_rate)])
            #print("Test length: " + str(len(test)))
            reformatted_data_object[trial][channel].append(list(data_object[trial][channel][int(stimulus_delay * sample_rate):]) + list(data_object[trial+1][channel][:int(stimulus_delay * sample_rate)]))
    last_trial = len(data_object) - 1
    for channel in range(len(data_object[last_trial])):
        print("Writing trial " + str(last_trial+1) + " channel " + str(channel+1))
        reformatted_data_object[last_trial][channel].append(list(data_object[last_trial][channel][int(stimulus_delay * sample_rate):]) + list(reversed(data_object[last_trial][channel][-int(stimulus_delay * sample_rate):])))
    return reformatted_data_object


################################################
# Bandpass Filter
################################################
def butter_bandpass(lowcut, highcut, fs, order=5):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return b, a

def butter_bandpass_filter(data, lowcut, highcut, fs, order=5):
    b, a = butter_bandpass(lowcut, highcut, fs, order=order)
    y = lfilter(b, a, data)
    return y

def bandpass_filt(fs, lowcut, highcut, shifted_data_object):
    """
    # Plot the frequency response for a few different orders.
    plt.figure(1)
    plt.clf()
    for order in [3, 6, 9]:
        b, a = butter_bandpass(lowcut, highcut, fs, order=order)
        w, h = freqz(b, a, worN=2000)
        plt.plot((fs * 0.5 / np.pi) * w, abs(h), label="order = %d" % order)

    plt.plot([0, 0.5 * fs], [np.sqrt(0.5), np.sqrt(0.5)],
             '--', label='sqrt(0.5)')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Gain')
    plt.grid(True)
    plt.legend(loc='best')
    plt.show()
    """

    # Concatenate all of the trials
    # all_data has shape(numchannels, sum_time_all_trials)
    all_data = [[] for i in range(len(shifted_data_object[0]))]
    print("Appending data into one large vector.")
    for trial in shifted_data_object:
        print("Iterating trial.")
        for i in range(len(trial)):
            all_data[i] = list(all_data[i]) + list(trial[i][0])
    """
    plt.figure(32)
    plt.clf()
    plt.plot(all_data[0], 'c-', label=("Prefiltered channel data for channel " + str(1)), linewidth=1.5)
    plt.axis('tight')
    plt.legend(loc='upper left')
    """

    # Get the indices used to compose / decompose the all_data matrix
    trial_lengths = []
    for trial_num in range(len(shifted_data_object)):
        trial_lengths.append(len(shifted_data_object[trial_num][0][0]))

    # Plot the function we wish to filter
    T = len(all_data[0])/fs
    nsamples = int(T * fs)
    t = np.linspace(0, T, nsamples, endpoint=False)

    # Filter all of the channels individually
    b, a = butter_bandpass(lowcut, highcut, fs)
    y_filtered = []
    for i in range(len(all_data)):
        x = all_data[i][:nsamples]
        y = filtfilt(b, a, x, padlen = 1000)
        ## Or, lfilter_zi
        #zi = lfilter_zi(b, a)
        #y3, zo = lfilter(b, a, x, zi=zi*x[0])
        y_filtered.append(y)

    """
    plt.figure(33)
    plt.clf()
    plt.plot(y_filtered[0], 'c-', label=("Post-filtered channel data for channel " + str(1)), linewidth=1.5)
    plt.axis('tight')
    plt.legend(loc='upper left')
    plt.show()


    # Plot some of the filtered data
    for i in range(len(y_filtered)):
        plt.figure(2+i)
        plt.clf()
        plt.plot(t, y_filtered[i], 'c-', label=("filtfilt signal channel " + str(i+1)), linewidth=1.5)
        plt.axis('tight')
        plt.legend(loc='upper left')
        plt.show()
    """

    # But we don't want to return y_filtered, we want to return y_filtered separated by trial
    return y_filtered

#####################################
# Bandpower
#####################################
def bandpower(x, fs, fmin, fmax):
    f, Pxx = scipy.signal.periodogram(x, fs=fs)
    ind_min = scipy.argmax(f > fmin) - 1
    ind_max = scipy.argmax(f > fmax) - 1
    return scipy.trapz(Pxx[ind_min: ind_max], f[ind_min: ind_max])

# Compute the alpha bandpower for each of the channels for all time recorded
'''def windowed_bandpower(filtered_data, band_low, band_high, windowsize, fs, slice_width):
    power_data = [[] for k in range(len(filtered_data))]
    windowhalf = int(windowsize/2)
    for i in range(len(filtered_data)):
        for j in range(windowhalf,int(slice_width/fs)-windowhalf,1):
            data_subset = filtered_data[i][(sample_rate*j-(sample_rate*windowhalf)):(sample_rate*j+sample_rate*windowhalf)]
            power_out = bandpower(data_subset,sample_rate,band_low,band_high)
            power_data[i].append(power_out)
            #print("Writing " + str(power_out) + " to power vector " + str(i+1))
    return power_data'''

def windowed_bandpower(filtered_data, band_low, band_high, windowsize, windowstep, fs, slice_width):
    power_data = [[] for k in range(len(filtered_data))]
    windowhalf = windowsize/2
    for i in range(len(filtered_data)):
        #print(slice_width/fs - windowhalf)
        j = windowhalf
        while j <= (slice_width/fs - windowhalf):
            data_subset = filtered_data[i][int(fs*j-(fs*windowhalf)):int(fs*j+fs*windowhalf)]
            power_out = bandpower(data_subset,fs,band_low,band_high)
            power_data[i].append(power_out)
            j += windowstep
            #print("Writing " + str(power_out) + " to power vector " + str(i+1))
    return power_data

def mean_slicer(shifted_data_object, filtered_data):
    indices = []
    for i in range(len(shifted_data_object)):
        indices.append(len(shifted_data_object[i][0][0]))
    print(indices)
    slice_width = min(indices)
    print("Slice_width: " + str(slice_width))
    slices=[list(np.zeros(slice_width)) for i in range(len(filtered_data))]
    slice_width = min(indices)
    for j in range(len(filtered_data)):
        for i in range(len(indices)):
            lower = sum(indices[:i])
            upper = lower + slice_width
            print("Working on channel " + str(i + 1) + " slices with indices " + str(lower) + " to " + str(upper) + ".")
            slices[j] = list(np.array(slices[j]) + np.array(filtered_data[j][lower:upper])/(len(indices)+1))
    return slices, slice_width

def trial_slicer(shifted_data_object, filtered_data):
    indices = []
    for i in range(len(shifted_data_object)):
        indices.append(len(shifted_data_object[i][0][0]))
    print(indices)
    slice_width = min(indices)
    print("Slice_width: " + str(slice_width))
    all_trials = []
    slice_width = min(indices)
    for i in range(len(indices)):
        trial = []
        for j in range(len(filtered_data)):
            lower = sum(indices[:i])
            upper = lower + slice_width
            print("Working on segmenting channel " + str(i + 1) + " slices with indices " + str(lower) + " to " + str(upper) + ".")
            trial.append(filtered_data[j][lower:upper])
        all_trials.append(trial)
    return all_trials, slice_width

def data_subset(dataset, time_window, sample_rate):
    t_low = int(time_window[0]*sample_rate)
    t_high = int(time_window[1]*sample_rate)
    sub_data = []
    for trial_num in range(len(dataset)):
        trial = []
        for channel_num in range(len(dataset[0])):
            trial.append(dataset[trial_num][channel_num][t_low:t_high])
        sub_data.append(trial)
    return sub_data

def trial_type_separator(dataset, trial_labels):
    A = []
    B = []
    for trial_num in range(len(dataset)):
        trial = []
        for channel_num in range(len(dataset[0])):
            trial.append(dataset[trial_num][channel_num])
        if trial_labels[trial_num] == 0:
            A.append(trial)
        else:
            B.append(trial)
    return A, B

def matrix_plotter(plot_data, plot_label):
    for i in range(len(plot_data)):
        plt.figure(i+1)
        plt.clf()
        plt.plot(plot_data[i], 'c-', label=(str(plot_label) + " for channel " + str(i+1)), linewidth=1.5)
        plt.axis('tight')
        plt.legend(loc='upper left')
    plt.show()

def channel_plotter(plot_data, channel_list, plot_title, sample_rate):
    fig, ax = plt.subplots()
    time_vec = np.asarray(list(range(len(plot_data[0]))))/float(sample_rate)
    for channel in range(len(channel_list)):
        line_label = "Channel " + str(channel_list[channel])
        ax.plot(time_vec, plot_data[channel_list[channel]-1], linewidth=2, label=line_label)
    plt.legend(loc='lower right')
    plt.title(str(plot_title))
    plt.xlabel("Time (s)")
    plt.ylabel("EEG Signal")
    plt.show()


def channel_remover(dataset, rm_channels_list):
    for channel_number in reversed(sorted(rm_channels_list)):
        print("removing channel " + str(channel_number))
        dataset = dataset[:channel_number - 1] + dataset[channel_number:]
    return dataset

def apply_CSP_filter(csp_filter, data):
    out_data = np.matmul(csp_filter, data)
    return out_data

def mean_of_channels(data, channel_list):
    ch_sum = np.asarray(data[channel_list[0]-1])
    for i in range(1,len(channel_list)):
        ch_sum = ch_sum + np.asarray(data[channel_list[i]-1])
    mean = ch_sum / len(channel_list)
    return list(mean)

if __name__ == '__main__':
    sample_rate = 1000 #Hz
    load_file = 'BCI_AlphaBlock_Bruce_180125.mat'
    #load_file = 'feb_1_data.mat'
    stimulus_delay = 3 #Seconds
    low_cut = 2 #Hz
    high_cut = 60 #Hz
    # Parameters for calculation of bandpower
    band_low = 7 #Hz
    band_high = 14 #Hz
    windowsize = 3 #seconds
    windowstep = .2 #seconds

    # Load EEG data from .mat file
    data_object = get_data(load_file)
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
