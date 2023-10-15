% This file does the calcs for state space averaging as described in
% "Fundamentals of power electronics" 3rd Ed. Robert W. Erickson: Section
% 7.5

close all;
%load('kpi.mat')
%% Build the disturbances. 
t = 0:2e-05:0.2;

%% Build the SS model
%%%% State variables:
% x1: Vc
% x2: iL

%%%%% Input variables
% u1: Vi - Voltage input
% u2: Vd - Constant for the array current

% Circuit Parameters
Rds = ureal('Rds', 35e-3, 'Range', [30e-3, 45e-3,]);
RL = ureal('Rl', 40, 'Range', [30, 100,]);
L = ureal('L', 118e-6, 'Range', [110e-6, 130e-6]);
Cap = ureal('C', 6e-6, 'Percentage',[-20, 20]);

%Resonance Point for the converter
Fr = 1/(2*pi*sqrt(L.NominalValue*Cap.NominalValue))

%%%% input and output params
% Vd = ureal('Vd', 0.94, 'Range',[0.91, 0.96]); %6.081;
Vi = ureal('Vi', 45, 'Range',[20, 80]); %130;

%%% Linearization point
%d = 0.5;
d = ureal('d', 0.5, 'Range',[0.2, 0.8]);
dp = 1-d;

% Following are equations for the d cycle
K1 = [L 0;
      0 Cap];
A1 = [-Rds 0;
      0  -1/(RL)];
B1 = [1;
      0];
C1 = [0 1];
D1 = [0];

% Following are equations for the d' cycle
K2 = [L 0;
      0 Cap];
A2 = [0 -1;
      1  -1/(RL)];
B2 = [1;
      0];
C2 = [0 1];
D2 = [0];

%%%% Averaged params
A = d.NominalValue*A1 + dp.NominalValue*A2;
B = d.NominalValue*B1 + dp.NominalValue*B2;
C = d.NominalValue*C1 + dp.NominalValue*C2;
D = d.NominalValue*D1 + dp.NominalValue*D2;
K = d.NominalValue*K1 + dp.NominalValue*K2;

%%% Dc operating points
U = [Vi];
X = -inv(A)*B*U;
Y = (-C*inv(A)*B+D)*U;

E = (A1-A2)*X + (B1-B2)*U;
F = (C1-C2)*X + (D1-D2)*U;

B_ss = [B,E]; %%% d_ss is input 3;
D_ss = [D,F];

A = inv(K)*A;
B_ss = inv(K)*B_ss;

sys = ss(A, B_ss, C, D_ss);

sys_ctrl = ss(A.NominalValue, inv(K.NominalValue)*E.NominalValue, C, D_ss.NominalValue(:,1));
figure();
margin(sys_ctrl)

%%%%% Make model labels
sys.u = {'Vi', 'Duty'}; 
sys.y = 'Vo'; sys.StateName = {'IL', 'Vo'};

%%% Setup an input vector of constant array power, and a step (ish) change in battery
%%% voltage

% Input step in the 

Vi_input1 = ones(size(t))*Vi.NominalValue;

inputs = [Vi_input1', zeros(size(t))'];

OL1 = lsim(sys.NominalValue, inputs, t);
figure();
plot(t, OL1)

% %% Standard PI
% kpi.u = 'VinSense'; kpi.y = 'Duty';
% fdbk = sumblk('VinSense = Vin + Noise');
% converter_cl_PI = connect(sys, kpi, fdbk, {'Noise', 'Id', 'Vo'}, {'Duty', 'Vin'});
% 
% %%% Sim the controller
% PI1 = lsim(converter_cl_PI.NominalValue, inputDist1, t);
% PI2 = lsim(converter_cl_PI.NominalValue, inputDist2, t);
% PI3 = lsim(converter_cl_PI.NominalValue, inputDist3, t);
% 
% figure('Name', 'Disturbance rejection for PI controller')
% clf, subplot(321)
% plot(t,IdDisturance1,'m', t,VoDistrubance1,'r', t, Noise,'c')
% title('Voltage Disturbance on Input'), ylabel('Vo (V)')
% legend('Input Current Disturbance', 'Input Voltage disturbance', 'Noise','location','SouthEast')
% subplot(323)
% plot(t,OL1(:,1),'b', t, PI1(:,2), 'k')
% title('Input Voltage Disturbance'), ylabel('Vin (V)')
% subplot(325)
% plot(t,zeros(size(t)),'b', t, PI1(:,1), 'k')
% title('Duty Cycle'), xlabel('Time (s)'), ylabel('Duty (%)')
% legend('Open-loop', 'Normal PI','location','SouthEast')
% 
% subplot(322)
% plot(t,IdDisturance2,'m', t,VoDistrubance2,'r', t, Noise,'c')
% title('Current Disturbance on Input'), ylabel('Vo (V)')
% legend('Input Current Disturbance', 'Input Voltage disturbance', 'Noise','location','SouthEast')
% subplot(324)
% plot(t,OL2(:,1),'b', t, PI2(:,2), 'k')
% title('Input Voltage Disturbance'), ylabel('Vin (V)')
% legend('Open-loop', 'Normal PI','location','SouthEast')
% subplot(326)
% plot(t,zeros(size(t)),'b', t, PI2(:,1), 'k')
% title('Duty Cycle'), xlabel('Time (s)'), ylabel('Duty (%)')
% legend('Open-loop', 'Normal PI','location','SouthEast')