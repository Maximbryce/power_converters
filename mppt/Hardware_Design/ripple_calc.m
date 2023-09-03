%%%% This script was used to compare measured vs actual ripple current
%%%% ratings when measured on hardware

fs = 20000;
duty = 0.5;
L = 418e-6;
vi = 75;
vo = 150;

delta_i = (vo-vi)/(L)*duty/fs


%%% Results
%% calculated (45 in, 88 out): 2.2883
%% measured (45 in, 88 out): 2.380
%% calculated (54.38 in, 106.33 out): 2.7633
%% measured (54.38 in, 106.33 out): 3.080
%% calculated (51.12 in, 99.7 out): 2.9055
%% measured (51.12 in, 99.7 out): 2.900
%% calculated (25.07 in, 48.85 out): 1.4222
%% measured (25.07 in, 48.85 out): 1.600
