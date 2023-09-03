close all;


f0 = 150e+3;

Cr = 10e-9

Lr = 1/((2*pi*f0)^2*Cr)


fs = linspace(100e+3, 150e+3, 100);


plot(fs, fs/f0);