%%% For a specified switching frequency, plots the required infuctor size


Vin = linspace(10,90, 90-10+1);
Vout = linspace(90,150, 150-90+1);

inductor_sizing = zeros(length(Vin), length(Vout));

for i = 1:length(Vin)
    for j = 1:length(Vout)
        if(Vin(i) >= Vout(j)-10)
            inductor_sizing(i,j) = 0;
        else
        inductor_sizing(i,j) = find_inductor_size(Vin(i), Vout(j), 2) * 10^6;
        end
    end
end

figure('Name', 'Inductor size for different input and output voltages, 2A allowed ripple current')
surf(Vout, Vin, inductor_sizing)
xlabel("Voltage Ouput")
ylabel("Voltage Input")
zlabel("Inductor size (uH)")
colorbar('westoutside')


function L = find_inductor_size(Vin, Vout, input_current)
Fsw = 20000;
Duty = (Vout - Vin)/Vout;
L = (Vin*Duty)/(input_current*1*Fsw);
end
