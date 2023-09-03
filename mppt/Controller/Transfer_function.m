%%%%% Plots the estimated transfer function of the MPPT, and a
%%%%% controller both the controller and MPPT transfer funtions gotten from
%%%%% 'Power Electronics, a first course' by Mohan
close all;

Vin = 40;
Iin = 5;
Vo = 120;

R = Vin/Iin; 
L = 418e-6;
Cap = 1.2e-3;
Rc = 100e-3; % Cap series resistance

Fr = 1/(2*pi*sqrt(L*Cap));

P = Vo  / (L*Cap) * tf([Rc*Cap 1], [1 (1/(R*Cap) + Rc/L) 1/(L*Cap)]);

figure('Name', 'Margin plot of power stage')
margin(P)

fc = 2e+3;
wc = 2*pi*fc

gps_fc = -122; %%%%% Change
pm = 60;
theta_boost = -90 + pm - gps_fc;


Gps_fc = db2mag(8.89); %%%% Change
G_duty = 1;

Gc_fc = 1/(Gps_fc * G_duty);

k_boost = tand(45 + theta_boost/4);
fz = fc/k_boost;
fp = k_boost*fc;
kc = Gc_fc*fz*2*pi/k_boost;

wz = fz*2*pi;
wp = fp*2*pi;

Gc1 = tf(kc, [1 0]);
Gc2 = tf([1/wz 1], [1/wp 1]);

Gc = Gc1 * Gc2 * Gc2;

T = feedback(Gc*P, 1);

figure('Name', 'Margin plot of closed loop')
margin(T)

figure('Name', 'Step response of the closed loop response')
step(T)