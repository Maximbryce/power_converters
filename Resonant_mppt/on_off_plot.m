close all;
requirements;
calcs_and_helpers;

Qn_range = linspace(0, 1, 11);

plot_labels = {};
Wn_trials = logspace(-1 , 1, 1000);


Cr = 375e-9;
Lr = 3e-6;
Lm = 10e-6;

fr2 = 1/(2*pi*sqrt(Cr*Lr))
fr1 = 1/(2*pi*sqrt(Cr*(Lr+Lm)))


figure('Name', 'One off plot');
hold on;
for Q = Qn_range
    semilogx(Wn_trials*(fr2), H(Wn_trials, Ln, Q))
    plot_labels = [plot_labels sprintf('Qn = %f, RL = %f', Q, Rl_from_Qe(Lr, Cr, Q, n))];
end

legend(plot_labels);
ylim([0 3]);
set(gca, 'XScale', 'log');