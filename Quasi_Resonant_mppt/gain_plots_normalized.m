close all;

calcs_and_helpers;

Wn_trials = logspace(-3 , 3, 1000);

Qn_trials = [0, 0.1, 0.2, 0.5 0.8 1 2 5 8 10];

Ln_trials = [1 5 10 20, 30 40];


for L = Ln_trials
    figure('Name', sprintf('Gains by Qn for Ln = %.0f', L))
    hold on;
    for Q = Qn_trials
        semilogx(Wn_trials, H(Wn_trials, L, Q))
    end
    legend('Qn = 0', 'Qn = 0.1', 'Qn = 0.2', 'Qn = 0.5', 'Qn = 0.8', 'Qn = 1', 'Qn = 2', 'Qn = 5', 'Qn = 8', 'Qn = 10')
    set(gca, 'XScale', 'log');
    ylim([0 3]);
    xlabel('Frequency')
    ylabel('Gain')
end


