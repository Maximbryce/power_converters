%%%% Script to see the rate at which ADC results are gotten for different
%%%% sample times and ADC clock rates with different oversamples

adc_freq = (52.333e+6)/2;
switching_freq = 20e+3;

sampling_cycles = 6.5;
conversion_cycles = 12.5;
oversample = 4;
buffer_size = 250;

total_sample_cycles = conversion_cycles + sampling_cycles;

raw_sample_freq = adc_freq / total_sample_cycles;

sample_freq = raw_sample_freq/oversample

samples_per_period = sample_freq / switching_freq

raw_samples_per_period = raw_sample_freq / switching_freq

num_cycles_per_buffer = buffer_size/samples_per_period

time_to_fill_buffer = buffer_size/sample_freq;

