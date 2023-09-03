%%%%%%%%% Equations for calculating ZVS
%%%%% Taken from 'Fundamentals of Power Electronics'

fs = 2000000;

u_min = 0.1;
u_max = 0.9;

Lr = 1e-6;
Cr = 1e-9;

f0 = 1/(2*pi*sqrt(Lr*Cr))
F = fs/f0;

R0 = sqrt(Lr/Cr);
output_voltage = 150;
inductor_current = 5;

Js = inductor_current*R0/(output_voltage)

Js_inv = 1/Js;
P = 1/(2*pi)*abs(1/2*Js_inv + pi + asin(Js_inv) + 1/Js_inv*(1+sqrt(1-Js_inv^2)))

u = 1 - F*P

gain = 1/(1-u)