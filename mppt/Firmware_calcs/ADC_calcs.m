%%%%%% Script to compare exected and measured values out of the ADC on the
%%%%%% microcontroller

ADC_value = 8541;
OVERSAMPLE_ADC_SCALAR = 4096*16;
vref = 3.3;
read_val = ADC_value / OVERSAMPLE_ADC_SCALAR * vref

voltage = 0.433;
correct_adc_val = voltage / vref * OVERSAMPLE_ADC_SCALAR
error = (correct_adc_val-ADC_value)/ADC_value*100
expected_voltage = 20.99 * 4.22/200