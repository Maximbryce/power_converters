load run2/component_vals.mat;
requirements;

ws = linspace(2*pi*50e+3, 2*pi*300e+3, 1000);


Xp = (1j*Lm*ws);
Xs = (1j*Lr*ws + 1./(Cr*1j*ws));

H_inf = (Xp)./ (Xs+Xp);
Zo0 = 1./(1./Xs + 1./Xp);
Ziinf = Xp + Xs;
Zi0 = Xs;

figure('Name', 'Input impedence magnitude');
loglog(ws./(2*pi), abs(Zi0))
hold on;
loglog(ws./(2*pi), abs(Ziinf))
ylabel('Impedance')
xlabel('Frequency')
legend('Zin0', 'Zininf');

Isc = (4/pi*Vin_max) ./ Zi0 ./ (sqrt(2));

figure('Name', 'Short circuit current over freq');
loglog(ws, abs(Isc))
hold on;
ylabel('current, rms')
xlabel('Frequency')