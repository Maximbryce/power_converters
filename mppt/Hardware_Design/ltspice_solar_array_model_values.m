%%%%% This script generated values for LTSpice simulations to find the
%%%%% parameter values for simulating the array in ltspice

num_cells_series = 60;

voc = 0.71 * num_cells_series;
vmp = 0.59 * num_cells_series;
isc =  6.08;
imp = 5.69;
temp = 25;
Illum = 1000;

rs = (voc - vmp) / (16*imp)
rsh = 5*vmp / (isc - imp)

a_n = 1.3*voc/0.7

vt = ((1.38*10^(-23)) * (273+temp)) / (1.6*10^(-19))
io = ((rs + rsh)*isc - voc)/(rsh*exp(voc/(a_n*vt)))
ipv = Illum/1000 * isc * (rsh+rs)/rsh