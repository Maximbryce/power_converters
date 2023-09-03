% This file does the calcs for state spae averaging as described in
% "Fundamentals of power electronics" 3rd Ed. Robert W. Erickson: Section
% 7.5


%%%% State variables:
% x1: Vc
% x2: iL


% Circuit Parameters
Rd = 453;
L = 418e-6;
C = 1.2e-6;
Id = 6.081;
Vo = 130;

% Following are equations for the d cycle
K1 = [C 0;
     0 L];
A1 = [-1/Rd -1;
      1     -1];
B1 = [1 0;
     0 0];
C1 = [1 0];
D1 = [0 0];

% Following are equations for the d' cycle
K2 = [C 0;
     0 L];
A2 = [-1/Rd -1;
      1     -1];
B2 = [1 0;
     0 -1];
C2 = [1 0];
D2 = [0 0];


