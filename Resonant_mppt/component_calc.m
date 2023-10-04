close all;
requirements;
calcs_and_helpers;

% Chosen based on prev scripts
Qe_max = 0.1212/2; % The min Q needed for the max gain in this design
Ln = 10;

RL_range = [25, 30, 35, 45, 50, 60, 70, 100, 120, 200, 300, 400];%linspace(25, 500, 20);
Re_min_max_gain_rpi = Rpri_from_sec((8/(pi*pi) * Rl_min_max_gain), n);

plot_labels = {};
Wn_trials = logspace(-1 , 1, 1000);


Cr = 1/(2*pi*Qe_max*fs*Re_min_max_gain_rpi) % Find Cr based on max gain at max load
Lr = 1/((2*pi*fs)^2*Cr)
Lm = Ln*Lr

fr2 = 1/(2*pi*sqrt(Cr*Lr))
fr1 = 1/(2*pi*sqrt(Cr*(Lr+Lm)))

Vout = 150;

figure('Name', sprintf('Normalize plot for Ln=%f, Qe_min=%f', Ln, Qe_max))
hold on;
for RL = RL_range
    gain = M(Wn_trials*(fr2), Cr, Lr, Lm, n, RL);
    I_out = Vout/RL;
    min_Vin = Vout / max(gain);
    Iin = I_out*max(gain);
    semilogx(Wn_trials*(fr2), gain);
    plot_labels = [plot_labels sprintf('RL= %f, Iin= %f, min Vin = %f', RL, Iin, min_Vin)];
end

yline(gain_max);
yline(gain_min);


legend(plot_labels);
ylim([0 3]);
set(gca, 'XScale', 'log');
hold off;

save component_vals.mat Ln Qe_max Cr Lr Lm Lm_sec fs n Re_min_max_gain_rpi
