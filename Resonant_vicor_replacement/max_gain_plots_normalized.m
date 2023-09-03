close all;

requirements;
calcs_and_helpers;

Wn_trials = logspace(-3 , 3, 1000);

%Qn_trials = [0, 0.1, 0.2, 0.5 0.8 1 2 5 8 10];

Qn_trials = linspace(0, 2, 100);

Ln_trials = [1 1.5 2 3 4 5 10 20, 30 40];

figure('Name', 'Max gains by Qn')
hold on;

for L = Ln_trials
    results = [];
    for Q = Qn_trials
        % Find the max gain for this
        maximum = max(H(Wn_trials, L, Q));
        results(end+1) = maximum;
    end
    plot(Qn_trials, results);
end

yline(H_min);
yline(H_max);

legend('Ln = 1', 'Ln = 1.5', 'Ln = 2', 'Ln = 3', 'Ln = 4', 'Ln = 5', 'Ln = 10', 'Ln = 20', 'Ln = 30', 'Ln = 40')
ylim([1 5]);
xlabel('Qe')
ylabel('Max Gain')


