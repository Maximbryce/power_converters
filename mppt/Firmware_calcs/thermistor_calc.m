%%%%% Script for setting up fits for the thermistors, uses the .sfit file
%%%%% for the actual fit

close all;
Temp = [0 10 20 30 40 50 60 70] %80 90]
R = [27348 17979 12094 8310.8 5824.9 4158.3 3019.7 2228] %1668.4 1266.7]
R_scalaed = R/10000;

% figure('Name', "temp fit")
% hold on;
% plot(R,Temp)

% N = 9;
% p = polyfit(R, Temp, N)
% 
% R = 200:100:20000;
% 
% Temp_fit = R.^(N).*p(1)+R.^(N-1).*p(2)+R.^(N-2).*p(3)+R.^(N-3).*p(4)+R.^(N-4).*p(5) + R.^(N-5).*p(6) + R.^(N-6).*p(7) + R.^(N-7).*p(8) + R.^(N-8).*p(9) + R.^(N-9).*p(10) %+ R.^(N-10).*p(11);
% plot(R, Temp_fit)