%%%%%%% Plots current values and attempts to filter them for testing to see
%%%%%%% if filters of some kind would work for filtering current
%%%%%%% meausrements off the G4 ADC

adc_freq = 53.333e+6;

sampling_cycles =6.5;
conversion_cycles = 12.5;
total_sample_cycles = conversion_cycles + sampling_cycles;

raw_sample_freq = adc_freq / total_sample_cycles;

oversample = 1;

sample_freq = raw_sample_freq/oversample;

sample_period = 1/sample_freq;

current_signal = timetable(current_values, 'SampleRate', sample_freq);

lowpass(current_values, 100000, sample_freq)

% bandpass(current_values, [17000 23000], sample_freq)

