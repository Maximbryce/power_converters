calcs_and_helpers;

Vin_max = 160;
Vin_min = 90;
Vin_nom = 130;

Vout_max = 26;
Vout_min = 22;
Vout_nom = 24;

Iout_max = 10;
Iout_min = 0.3;

Rl_min_max_gain = Vout_nom / Iout_max;

max_output_power = Vout_max*Iout_max;

fs = 150e+3;
n = 1/3.3;

H_max = H_back_calc(Vin_min, Vout_max, n);
H_min = H_back_calc(Vin_max, Vout_min, n);

gain_max = Vout_max / Vin_min;
gain_min = Vout_min / Vin_max;


% H_gain_sweep = linspace(H_min, H_max);
% 
% input_ratio_sweep = linspace(Vin_min/Iin_max , Vin_max/Iin_min, 10);
% 
% figure('Name', 'Output load as a function for gain for different Vin/Iin ratios')
% hold on;
% plot_labels = {};
% for input_ratio = input_ratio_sweep
%     plot(H_gain_sweep, ((n*H_gain_sweep).^2 .* input_ratio));
%     plot_labels = [plot_labels sprintf('Vin/Iin = %f', input_ratio)];
% end
% 
% max_vin = Vout_max ./ (H_gain_sweep * n);
% yyaxis right;
% plot(H_gain_sweep, max_vin)
% plot_labels = [plot_labels, 'Maximum Vin over gain'];
% 
% legend(plot_labels);
