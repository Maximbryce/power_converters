a = 113.53;
b = 2.072;
c = 1.379;

% Need a big inductor
I_ripple_pk_pk = 0.4; % 2A ripple
f = 80; % In Khz

Ie = 14.4; %path length (cm) from datasheet
Ae = 3.6; % Cross section in cm^2
N = 60;

Hpk_pk = N*I_ripple_pk_pk/Ie

% https://www.mag-inc.com/Products/Powder-Cores/Kool-Mu-MAX-Cores/Kool-Mu-MAX-Material-Curves
% Contains B-H curve
B_pk_pk = 0.01;

B_pk = B_pk_pk/2;

% https://www.mag-inc.com/Products/Powder-Cores/Kool-Mu-MAX-Cores/Kool-Mu-MAX-Material-Curves

Loss_density = a*(B_pk^b)*(f)^c

Losses_mW = Loss_density * Ie * Ae


% Reistive
losses_resistive = 0.043` * 5*5


