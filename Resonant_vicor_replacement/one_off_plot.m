close all;
requirements;
calcs_and_helpers;
load component_vals;


Qn_range = linspace(0, 1, 11);

plot_labels = {};
Wn_trials = logspace(-1 , 1, 1000);


fr2 = 1/(2*pi*sqrt(Cr*Lr))
fr1 = 1/(2*pi*sqrt(Cr*(Lr+Lm)))


Io_range = [0.5, 1, 4, 6, 10];%linspace(25, 500, 20);

plot_labels = {};
Wn_trials = logspace(-1 , 1, 1000);

Vin_trial = 130;

figure('Name', sprintf('Normalize plot for Ln=%f, Qe_min=%f', Ln, Qe_max))
hold on;
for Io = Io_range
    RL = Vout_nom/Io;
    gain = M(Wn_trials*(fr2), Cr, Lr, Lm, n, RL);
    semilogx(Wn_trials*(fr2), gain*Vin_trial);
    plot_labels = [plot_labels sprintf('Io= %f, RL = %f', Io, RL)];
end

legend(plot_labels);
ylim([22,26]);
set(gca, 'XScale', 'log');
hold off;
