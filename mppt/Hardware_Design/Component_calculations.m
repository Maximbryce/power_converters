%%%%%% Script to calculate component sizing for the MPPT hardware

%Gate Resistor
% Based off equation in: https://www.analog.com/media/en/technical-documentation/data-sheets/adum4221_4221-1_4221-2.pdf

%Rsw = 
%Rgate = 
%Ltrace = 
%Cgs = 
% This value should be lower than 1 (Q factor for an RLC circuit) so that
% it's underdamped
%Q = 1/ (Rsw + Rgate) * sqrt(Ltrace/cgs)


% Calculating the inductor size

% % 10-30% is best for size
max_output_current = 2;
output_ripple_current = max_output_current/10;
Fsw = 40000;
Vin = 40;
Vout = 100;
efficiency = .90;
dutycycle = 1 - (Vin* efficiency/Vout)

% in A
inductor_ripple_current = (0.2 * max_output_current * Vout) /Vin

L = (Vin * (Vout - Vin)) / (inductor_ripple_current * Fsw * Vout)

Cout = (max_output_current * dutycycle) / (Fsw * Vout)
% Inductor sizing from:
% https://www.ti.com.cn/cn/lit/an/slva372c/slva372c.pdf?ts=1659917022710&ref_url=https%253A%252F%252Fwww.google.com%252F
