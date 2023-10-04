% This file does the calcs for state space averaging as described in
% "Fundamentals of power electronics" 3rd Ed. Robert W. Erickson: Section
% 7.5


%%%% Maxim Erickson EE5235 Final Project submission

% close all;
load('kpi.mat')
%% Build the disturbances. 
t = 0:2e-05:0.2;

% Noise
noise_dist = makedist('Normal','mu',0,'sigma',0.1);
rng('default');  % For reproducibility
Noise = random(noise_dist,size(t));
% Pulse which goes down 6V, from 0-0.125 sec
%%% This pulse is kinda slow bc it's iherintly limited by the speed of the
%%% object which is drawing the current (a person in this case)

VoDistrubance1 = zeros(size(t));
VoDistrubance1(1:6.25e+3) = -3*(1-cos(16*pi*t(1:6.25e+3)));
IdDisturance1 = zeros(size(t));
inputDist1 = [Noise', IdDisturance1', VoDistrubance1'];


%%% Input disturbance on the input current which drops the current down by
%%% 3A in 12.5 ms (probobly faster than would be expected)
VoDistrubance2 = zeros(size(t));
IdDisturance2 = zeros(size(t));
IdDisturance2(1:6.25e+2) = -1.5*(1-cos(160*pi*t(1:6.25e+2)));
inputDist2 = [Noise', IdDisturance2', VoDistrubance2'];

%%% Combined disturbance
VoDistrubance3 = zeros(size(t));
VoDistrubance3(1:6.25e+3) = -3*(1-cos(16*pi*t(1:6.25e+3)));
IdDisturance3 = zeros(size(t));
IdDisturance3(6.25e+2*2:6.25e+2*3) = -1.5*(1-cos(160*pi*t(6.25e+2*2:6.25e+2*3)));
inputDist3 = [Noise', IdDisturance3', VoDistrubance3'];

%% Build the SS model
%%%% State variables:
% x1: Vc
% x2: iL

%%%%% Input variables
% u1: Id - Constant for the array current
% u2: Vo - Voltage output

% Circuit Parameters
Rd = ureal('Rd', 453, 'Range', [10, 1000]);
Rds = ureal('Rds', 7e-3, 'Range', [6e-3, 15e-3,]);
Rl = ureal('Rl', 40e-3, 'Range', [30e-3, 100e-3,]);
L = ureal('L', 418e-6, 'Range', [380e-6, 438e-6]);
C = ureal('C', 1.2e-3, 'Percentage',[-20, 20]);

%Resonance Point for the converter
Fr = 1/(2*pi*sqrt(L.NominalValue*C.NominalValue))

%%%% input and output params
Id = ureal('Id', 6.081, 'Range',[1, 6.3]); %6.081;
Vo = ureal('Vo', 130, 'Range',[100, 150]); %130;

%%% Linearization point
%d = 0.5;
d = ureal('d', 0.5, 'Range',[0.2, 0.8]);
dp = 1-d;

% Following are equations for the d cycle
K1 = [C 0;
      0 L];
A1 = [-1/Rd -1;
      1     -(Rds + Rl)];
B1 = [1 0;
      0 0];
C1 = [1 0];
D1 = [0 0];

% Following are equations for the d' cycle
K2 = [C 0;
      0 L];
A2 = [-1/Rd -1;
      1     -(Rds + Rl)];
B2 = [1  0;
      0 -1];
C2 = [1 0];
D2 = [0 0];

%%%% Averaged params
A = d*A1 + dp*A2;
B = d*B1 + dp*B2;
C = d*C1 + dp*C2;
D = d*D1 + dp*D2;
K = d*K1 + dp*K2;

%%% Dc operating points
U = [Id; Vo];
X = -inv(A)*B*U;
Y = (-C*inv(A)*B+D)*U;

E = (A1-A2)*X + (B1-B2)*U;
F = (C1-C2)*X + (D1-D2)*U;

B_ss = [B,E]; %%% d_ss is input 3;
D_ss = [D,F];

sys = ss(inv(K)*A, inv(K)*B_ss, C, D_ss);

%%%%% Make model labels
sys.u = {'Id', 'Vo', 'Duty'}; 
sys.y = 'Vin'; sys.StateName = {'Vin', 'Il'};

%%% Setup an input vector of constant array power, and a step (ish) change in battery
%%% voltage

OL1 = lsim(sys.NominalValue, [inputDist1(:,[2,3]), zeros(size(t))'], t);
OL2 = lsim(sys.NominalValue, [inputDist2(:,[2,3]), zeros(size(t))'], t);
OL3 = lsim(sys.NominalValue, [inputDist3(:,[2,3]), zeros(size(t))'], t);

%% Standard PI
kpi.u = 'VinSense'; kpi.y = 'Duty';
fdbk = sumblk('VinSense = Vin + Noise');
converter_cl_PI = connect(sys, kpi, fdbk, {'Noise', 'Id', 'Vo'}, {'Duty', 'Vin'});

%%% Sim the controller
PI1 = lsim(converter_cl_PI.NominalValue, inputDist1, t);
PI2 = lsim(converter_cl_PI.NominalValue, inputDist2, t);
PI3 = lsim(converter_cl_PI.NominalValue, inputDist3, t);

figure('Name', 'Disturbance rejection for PI controller')
clf, subplot(321)
plot(t,IdDisturance1,'m', t,VoDistrubance1,'r', t, Noise,'c')
title('Voltage Disturbance on Input'), ylabel('Vo (V)')
legend('Input Current Disturbance', 'Input Voltage disturbance', 'Noise','location','SouthEast')
subplot(323)
plot(t,OL1(:,1),'b', t, PI1(:,2), 'k')
title('Input Voltage Disturbance'), ylabel('Vin (V)')
subplot(325)
plot(t,zeros(size(t)),'b', t, PI1(:,1), 'k')
title('Duty Cycle'), xlabel('Time (s)'), ylabel('Duty (%)')
legend('Open-loop', 'Normal PI','location','SouthEast')

subplot(322)
plot(t,IdDisturance2,'m', t,VoDistrubance2,'r', t, Noise,'c')
title('Current Disturbance on Input'), ylabel('Vo (V)')
legend('Input Current Disturbance', 'Input Voltage disturbance', 'Noise','location','SouthEast')
subplot(324)
plot(t,OL2(:,1),'b', t, PI2(:,2), 'k')
title('Input Voltage Disturbance'), ylabel('Vin (V)')
legend('Open-loop', 'Normal PI','location','SouthEast')
subplot(326)
plot(t,zeros(size(t)),'b', t, PI2(:,1), 'k')
title('Duty Cycle'), xlabel('Time (s)'), ylabel('Duty (%)')
legend('Open-loop', 'Normal PI','location','SouthEast')


%% Hinf design

% weights

% Sensor noise
%Wn = tf([0.1, 0.001*100000*2*pi], [1, 400000*2*pi]);
Wn = ss(0.1);
%Wn = 1/(Bn);

%%% Controller bound
% Anything Over 100hz is probobly too much effort
%%% Bk = tf([0.001, 1*(100*2*pi)], [1, (100*2*pi)]);
Wk = makeweight(0.001, 300*2*pi, 1.1); % Higher weight on higher control bandwidths

%%% Cl weight
cl_weight = makeweight(20,300*2*pi,0.01);

%%% Input Current disturbance. Low frequency distribances are high, but no
%%% high frequency disturbances
WId = makeweight(4,200*2*pi,0.01); %ss(2);

%%% Output Voltage disturbance. Low frequency distribances are high, but no
%%% high frequency disturbances
WVo = makeweight(10,100*2*pi,0.01); %ss(10);

%%% Make a bode plot of the weights
figure
bode(Wk, cl_weight, WId, WVo, Wn)
legend('Wk', 'cl_weight', 'WId', 'WVo', 'Wn')

%%%%% Connection
Wn.u = 'Noise'; Wn.y = 'Wn';
Wk.u = 'Duty'; Wk.y = 'Wk';
WId.u = 'Id_dist'; WId.y = 'Id';
WVo.u = 'Vo_dist'; WVo.y = 'Vo';
cl_weight.u = 'Vin'; cl_weight.y = 'WCL';
fdbk = sumblk('ViSense = Vin + Wn');

%%% new system model
converter_weighted = connect(Wn, Wk, sys, WId, WVo, cl_weight, fdbk, {'Noise', 'Id_dist', 'Vo_dist', 'Duty'}, {'Wk', 'WCL', 'ViSense'});

[Kinf, Hinf_syn_CL, Hinf_syn_gamma] = hinfsyn(converter_weighted.NominalValue, 1, 1);
Hinf_syn_gamma

fdbk = sumblk('VinSense = Vin + Noise');
Kinf.u = 'VinSense'; Kinf.y = 'Duty';
converter_cl_hinf = connect(sys, Kinf, fdbk, {'Noise', 'Id', 'Vo'}, {'Duty', 'Vin'});

figure('Name', 'CL for input rejection')
bode(converter_cl_hinf.NominalValue)

%%%% Sim the controller
CL_Hinf1 = lsim(converter_cl_hinf.NominalValue, inputDist1, t);
CL_Hinf2 = lsim(converter_cl_hinf.NominalValue, inputDist2, t);

figure('Name', 'Disturbance rejection')
subplot(321)
plot(t,IdDisturance1,'m', t,VoDistrubance1,'r', t, Noise,'c')
title('Voltage Disturbance on input'), ylabel('Vo (V)')
legend('Input Current Disturbance', 'Input Voltage disturbance', 'Noise','location','SouthEast')

subplot(323)
plot(t,OL1(:,1),'b',t, CL_Hinf1(:,2),'g', t, PI1(:,2), 'k')
title('Input Voltage Disturbance'), ylabel('Vin (V)')
legend('Open-loop','Robust design', 'Normal PI','location','SouthEast')

subplot(325)
plot(t,zeros(size(t)),'b',t,CL_Hinf1(:,1),'g', t, PI1(:,1), 'k')
title('Duty Cycle'), xlabel('Time (s)'), ylabel('Duty (%)')
legend('Open-loop','Robust design', 'Normal PI','location','SouthEast')

%%%% PLot second disturbance
subplot(322)
plot(t,IdDisturance2,'m', t,VoDistrubance2,'r', t, Noise,'c')
title('Current Disturbance on output'), ylabel('Vo (V)')
legend('Input Current Disturbance', 'Input Voltage disturbance', 'Noise','location','SouthEast')

subplot(324)
plot(t,OL2(:,1),'b',t, CL_Hinf2(:,2),'g', t, PI2(:,2), 'k')
title('Input Voltage Disturbance'), ylabel('Vin (V)')
legend('Open-loop','Robust design', 'Normal PI','location','SouthEast')

subplot(326)
plot(t,zeros(size(t)),'b',t,CL_Hinf2(:,1),'g', t, PI2(:,1), 'k')
title('Duty Cycle'), xlabel('Time (s)'), ylabel('Duty (%)')
legend('Open-loop','Robust design', 'Normal PI','location','SouthEast')


%%%%%%%% Combined disturbances
CL_Hinf3 = lsim(converter_cl_hinf.NominalValue, inputDist3, t);

figure('Name', 'Disturbance rejection of Hinf controller with duble disturbance')
subplot(311)
plot(t, IdDisturance3,'m', t, VoDistrubance3,'r', t, Noise,'c')
title('Voltage Disturbance on input'), ylabel('Vo (V)')
legend('Input Current Disturbance', 'Input Voltage disturbance', 'Noise','location','SouthEast')

subplot(312)
plot(t,OL3(:,1),'b',t, CL_Hinf3(:,2),'g', t, PI3(:,2), 'k')
title('Input Voltage Disturbance'), ylabel('Vin (V)')
legend('Open-loop','Robust design', 'Normal PI','location','SouthEast')

subplot(313)
plot(t,zeros(size(t)),'b',t,CL_Hinf3(:,1),'g', t, PI3(:,1), 'k')
title('Duty Cycle'), xlabel('Time (s)'), ylabel('Duty (%)')
legend('Open-loop','Robust design', 'Normal PI','location','SouthEast')


%% Check robust perfomance

figure('Name', 'Robust perfomance of Hinf controller')
% Uncertain closed-loop model with balanced H-infinity controller
plotoptions = timeoptions('cstprefs');
plotoptions.YLimMode = 'manual';
plotoptions.YLim = [-2e-1, 2e-1];
lsimplot(usample(converter_cl_hinf, 100), 'b', converter_cl_hinf.NominalValue, 'r', inputDist1, t, plotoptions)
title('Nominal design')
legend('Variations','Nominal','location','SouthEast')

figure('Name', 'Controller comparison')
bodemag(kpi, Kinf)
legend('PI', 'Hinf')

[STABMARG,DESTABUNC,INFO] = robstab(converter_cl_hinf);
STABMARG

%% Robust MU design - NOT NECESSARY

% [Krob,rpMU] = musyn(converter_weighted,1,1)
% 
% Krob.u = 'Vin'; Krob.y = 'Duty';
% converter_cl_MU = connect(sys, Krob, {'Id', 'Vo'}, {'Duty', 'Vin'});
% 
% 
% %%% Set a random variable starting point
% rng('default')
% 
% figure('Name', 'Robust perfomance')
% % Uncertain closed-loop model with balanced H-infinity controller
% plotoptions = timeoptions('cstprefs');
% plotoptions.YLimMode = 'manual';
% plotoptions.YLim = [-1e-1, 1e-1];
% lsimplot(usample(converter_cl_MU, 100), 'b', converter_cl_MU.NominalValue, 'r', inputDist, t, plotoptions)
% title('Nominal design')
% legend('Variations','Nominal','location','SouthEast')
% 
% figure('Name', 'Controller comparison')
% bodemag(kpi, Kinf, Krob)
% legend('PI', 'Hinf', 'Mu')



