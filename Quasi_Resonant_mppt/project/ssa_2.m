%% Build the SS model
%%%% State variables:
% x1: iL
% x2: Vo

%%%%% Input variables
% u1: Vi - Constant for the array current
% u2: Vd - Diode foreward voltage

% Circuit Parameters
Rds = 45e-3;
R = 50;
L = 148e-6;
C = 6e-6;

%Resonance Point for the converter
Fr = 1/(2*pi*sqrt(L*C))

%%%% input and output params
Vd = 0.9;
Vi = 50;

%%% Linearization point
%d = 0.5;
d = 0.5;
dp = 1-d;

% Following are equations for the d' cycle
K2 = [L 0;
      0 C];
A2 = [0 -1;
      1   -1/R];
B2 = [1 -1;
      0 0];
C2 = [0 1];
D2 = [0 0];

% Following are equations for the d cycle
K1 = [L 0;
      0 C];
A1 = [-Rds 0;
      0     -1/R];
B1 = [1  0;
      0 0];
C1 = [0 1];
D1 = [0 0];

%%%% Averaged params
A = d*A1 + dp*A2;
B = d*B1 + dp*B2;
C = d*C1 + dp*C2;
D = d*D1 + dp*D2;
K = d*K1 + dp*K2;

%%% Dc operating points
U = [Vi; Vd];
X = -inv(A)*B*U;
Y = (-C*inv(A)*B+D)*U;

E = (A1-A2)*X + (B1-B2)*U;
F = (C1-C2)*X + (D1-D2)*U;

B_ss = [B,E]; %%% d_ss is input 3;
D_ss = [D,F];


A = inv(K)*A;
B = inv(K)*B_ss;
C = C;
D = D_ss;

sys = ss(A, B, C, D);