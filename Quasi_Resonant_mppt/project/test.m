close all;
figure
opt = stepDataOptions('StepAmplitude',-8);

step(sys, opt)