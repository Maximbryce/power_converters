close all;
Lm = 9000; %20e-6;
Llp = 20e-6;
lls = 0; %30e-6;


Cout = 100e-6;
Cs = 4e-6;
Rload = 1;
Re = 8/(pi^2)*Rload;

ws = logspace(10,10e+6);

fr1 = 1/(2*pi*sqrt(Cs*Llp)) % Resonant frequency at high load (Low Re)
fr2 = 1/(2*pi*sqrt(Cs*(Llp + Lm))) % Resonant frequency at low load (High Re)

fs = logspace(3, 7, 1000);
ws = 2*pi*fs;

n = 1; %% turns ratio

Zin0 = abs(1./(Cs*1j*ws) + Llp*1j*ws);
Zininf = abs(1./(Cs*1j*ws) + Llp*1j*ws + Lm*1j*ws);

H_jw = abs(1./(1+(Re + Lm*1j*ws)./(Re*Lm.*1j*ws).*(1./(Cs*1j*ws) + Llp*1j*ws)));

figure('Name', 'Input impedence magnitude');
loglog(ws, Zin0)
hold on;
loglog(ws, Zininf)
ylabel('Impedance')
xlabel('Frequency')
legend('Zin0', 'Zininf');

M = n*H_jw/2;

figure('Name', 'Gain of the converter vs freq');
loglog(ws, M)
ylabel('Gain')
xlabel('Frequency')
