requirements;
calcs_and_helpers;

max_RL = Vout_max/Iin_min;
min_RL = Vout_min/Iin_max;

figure();
[Fs, RL] = meshgrid(linspace(50000, 200000, 100), linspace(min_RL, max_RL, 100));


conv_gain = M(Fs, Cr, Lr, Lm, n, RL);

surf(Fs, RL, conv_gain)
zlim([-6, 6])