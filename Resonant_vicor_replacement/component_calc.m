close all;
requirements;
calcs_and_helpers;

% Chosen based on prev scripts
Qe_max = 0.606; % The min Q needed for the max gain in this design
Ln = 1.5;

Io_range = [0.5, 1, 4, 6, 10];%linspace(25, 500, 20);
Re_min_max_gain_rpi = Rpri_from_sec((8/(pi*pi) * Rl_min_max_gain), n);

plot_labels = {};
Wn_trials = logspace(-1 , 1, 1000);


Cr = 1/(2*pi*Qe_max*fs*Re_min_max_gain_rpi) % Find Cr based on max gain at max load
Lr = 1/((2*pi*fs)^2*Cr)
Lm = Ln*Lr

fr2 = 1/(2*pi*sqrt(Cr*Lr))
fr1 = 1/(2*pi*sqrt(Cr*(Lr+Lm)))



figure('Name', sprintf('Normalize plot for Ln=%f, Qe_min=%f', Ln, Qe_max))
hold on;
for Io = Io_range
    RL = Vout_nom/Io;
    gain = M(Wn_trials*(fr2), Cr, Lr, Lm, n, RL);
    semilogx(Wn_trials*(fr2), gain);
    plot_labels = [plot_labels sprintf('Io= %f, RL = %f', Io, RL)];
end

yline(gain_min);
yline(gain_max);

legend(plot_labels);
ylim([0 0.4]);
set(gca, 'XScale', 'log');
hold off;

save component_vals.mat Ln Qe_max Cr Lr Lm fs n Re_min_max_gain_rpi
